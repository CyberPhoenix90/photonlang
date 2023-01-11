import { Logger } from 'Logging/src/logging';
import { ProjectSettings } from '../project_settings.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';
import { Path, Directory, File } from 'System/IO';
import { StringBuilder } from 'System/Text';
import { AssemblyType } from '../project_settings.ph';
import 'System/Linq';
import { String, Exception } from 'System';
import { AnalyzedProject } from '../static_analysis/analyzed_project.ph';
import { FileNode } from '../compilation/cst/file_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { ImportStatementNode } from '../compilation/cst/statements/import_statement_node.ph';
import { StatementNode } from '../compilation/cst/statements/statement.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { BlockStatementNode } from '../compilation/cst/statements/block_statement_node.ph';
import { ClassVariableNode } from '../compilation/cst/other/class_variable_node.ph';
import { ClassPropertyNode } from '../compilation/cst/other/class_property_node.ph';
import { ClassMethodNode } from '../compilation/cst/other/class_method_node.ph';
import { TypeDeclarationNode } from '../compilation/cst/other/type_declaration_node.ph';
import { TypeExpressionNode } from '../compilation/cst/type_expressions/type_expression_node.ph';
import { ExpressionNode } from '../compilation/cst/expressions/expression_node.ph';
import { ExpressionStatementNode } from '../compilation/cst/statements/expression_statement_node.ph';
import { FunctionArgumentsDeclarationNode } from '../compilation/cst/other/function_arguments_declaration_node.ph';

export class CSharpTranspiler {
    private logger: Logger;
    private readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: AnalyzedProject;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, project: AnalyzedProject, logger: Logger) {
        this.logger = logger;
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.project = project;
    }

    public Emit(): void {
        this.logger.Debug(`Transpiling project ${this.projectSettings.name} to C#`);

        const outputFolder = Path.GetFullPath(Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir));
        Directory.CreateDirectory(outputFolder);

        const projectFile = new StringBuilder();
        const projectFileOutputPath = Path.GetFullPath(Path.Join(outputFolder, this.projectSettings.name + '.csproj'));

        projectFile.Append(`
        <Project Sdk=""Microsoft.NET.Sdk"">
          <PropertyGroup>
            <TargetFramework>net6.0</TargetFramework>
            <ImplicitUsings>disable</ImplicitUsings>
            <Nullable>enable</Nullable>
            `);
        if (this.projectSettings.assemblyType == AssemblyType.Executable) {
            projectFile.Append('<OutputType>Exe</OutputType>');
        }
        projectFile.Append(`</PropertyGroup>


          <ItemGroup>
            `);
        projectFile.Append(
            String.Join(
                '\n',
                this.projectSettings.projectReferences.Select((library) => '<ProjectReference Include="../' + library + ' />'),
            ),
        );
        projectFile.Append(
            String.Join(
                '\n',
                this.projectSettings.nuget.Select((library) => '<PackageReference Include="' + library.Key + ' Version="' + library.Value + ' />'),
            ),
        );
        projectFile.Append(`
          </ItemGroup>

        </Project>
        `);

        File.WriteAllText(projectFileOutputPath, projectFile.ToString());

        for (const file of this.project.fileNodes.Values) {
            const outputFilePath = Path.GetFullPath(Path.Join(outputFolder, file.path.Replace(".ph", ".cs")));
            const fileContents = this.EmitFile(file);
            Directory.CreateDirectory(Path.GetDirectoryName(outputFilePath));
            File.WriteAllText(outputFilePath, fileContents);
        }
    }

    private EmitFile(file: FileNode): string {
        const isEntryPoint = this.projectSettings.entrypoint == file.path;

        const sb = new StringBuilder();

        const ambientStatements = file.Statements.Where(
            (s) => s instanceof EnumNode || s instanceof StructNode || s instanceof ClassNode || s instanceof TypeAliasStatementNode,
        ).ToList();
        const ImportStatements = file.Statements.Where((s) => s instanceof ImportStatementNode).ToList();
        const globalStatements = file.Statements.Where((s) => !ambientStatements.Contains(s) && !ImportStatements.Contains(s)).ToList();
        if (globalStatements.Count() > 0 && (!isEntryPoint || this.projectSettings.assemblyType == AssemblyType.Library)) {
            throw new Exception('Global statements are only allowed in entrypoint files of executable projects');
        }

        for (const statement of ImportStatements) {
            this.TranslateStatement(statement, sb);
        }

        sb.Append('namespace ' + this.projectSettings.name + '.' + file.path.Replace('.ph', '').Replace('/', '.') + ';\n');

        if (isEntryPoint) {
            sb.Append('class Program { static async System.Threading.Tasks.Task Main(string[] args) {');

            for (const statement of globalStatements) {
                this.TranslateStatement(statement, sb);
            }

            sb.Append('})');
        }
        for (const ambient of ambientStatements) {
            this.TranslateStatement(ambient, sb);
        }

        return sb.ToString();
    }

    private TranslateStatement(statementNode: StatementNode, output: StringBuilder): void {
        if (statementNode instanceof BlockStatementNode) {
            output.Append("{");
            for (const statement of statementNode.statements) {
                this.TranslateStatement(statement, output);
            }
            output.Append("}");
        } else if (statementNode instanceof ImportStatementNode) {
            this.TranslateImportStatement(statementNode, output);
        } else if (statementNode instanceof ClassNode) {
            this.TranslateClassDeclarationNode(statementNode, output);
        } else if (statementNode instanceof ExpressionStatementNode) {
            this.TranslateExpressionStatementNode(statementNode, output);
        }

        output.Append(`\n`);
    }

    private TranslateClassDeclarationNode(classNode: ClassNode, output: StringBuilder): void {
        if (classNode.isExported) {
            output.Append("public ");
        }

        if (classNode.isAbstract) {
            output.Append("abstract ");
        }

        output.Append("class " + classNode.name + " ");

        if (classNode.extendsNode != null) {
            output.Append("extends " + classNode.extendsNode.name + " ");
        }

        if (classNode.implementsNode != null) {
            output.Append("implements " + String.Join(", ", classNode.implementsNode.identifiers) + " ");
        }

        if (classNode.usesNode != null) {
            output.Append("uses " + String.Join(", ", classNode.usesNode.identifiers) + " ");
        }

        output.Append("{");

        for (const variable of classNode.variables) {
            this.TranslateVariableDeclarationNode(variable, output);
        }

        for (const property of classNode.properties) {
            this.TranslatePropertyDeclarationNode(property, output);
        }

        for (const method of classNode.methods) {
            this.TranslateMethodDeclarationNode(method, classNode, output);
        }
    }

    private TranslateVariableDeclarationNode(variableNode: ClassVariableNode, output: StringBuilder): void {
        if (variableNode.accessor != null) {
            output.Append(variableNode.accessor.accessor + " ");
        }

        if (variableNode.isStatic) {
            output.Append("static ");
        }

        if (variableNode.isReadonly) {
            output.Append("readonly ");
        }

        this.TranslateTypeDeclarationNode(variableNode.type, output);

        output.Append(" " + variableNode.name + " ");

        if (variableNode.initializer != null) {
            this.TranslateExpressionNode(variableNode.initializer, output);
        }

        output.Append(";");
    }

    private TranslatePropertyDeclarationNode(propertyNode: ClassPropertyNode, output: StringBuilder): void {
        if (propertyNode.accessor != null) {
            output.Append(propertyNode.accessor.accessor + " ");
        }

        if (propertyNode.isStatic) {
            output.Append("static ");
        }
    }

    private TranslateMethodDeclarationNode(methodNode: ClassMethodNode, ownerClass: ClassNode, output: StringBuilder): void {
        if (methodNode.accessor != null) {
            output.Append(methodNode.accessor.accessor + " ");
        }

        if (methodNode.isStatic) {
            output.Append("static ");
        }

        if (methodNode.isAbstract) {
            output.Append("abstract ");
        }

        if (methodNode.isAsync) {
            output.Append("async ");
        }

        if (!methodNode.isConstructor) {
            this.TranslateTypeDeclarationNode(methodNode.returnType, output);
            output.Append(" " + methodNode.name);
        } else {
            output.Append(ownerClass.name);
        }

        this.TranslateFunctionArgumentsDeclarationNode(methodNode.arguments, output);

        if (methodNode.isAbstract) {
            output.Append(";");
        } else {
            this.TranslateStatement(methodNode.body, output);
        }

        output.Append(`\n`);
    }

    private TranslateFunctionArgumentsDeclarationNode(argumentsNode: FunctionArgumentsDeclarationNode, output: StringBuilder): void {
        output.Append("(");
        // for (const argument of argumentsNode.arguments) {
        //     this.TranslateFunctionArgumentDeclarationNode(argument, output);
        // }
        output.Append(")");
    }

    private TranslateTypeDeclarationNode(typeNode: TypeDeclarationNode, output: StringBuilder): void {
        this.TranslateTypeExpressionNode(typeNode.type, output);
    }

    private TranslateTypeExpressionNode(typeNode: TypeExpressionNode, output: StringBuilder): void {
        output.Append(typeNode.GetText());
    }

    private TranslateExpressionStatementNode(expressionStatementNode: ExpressionStatementNode, output: StringBuilder): void {
        this.TranslateExpressionNode(expressionStatementNode.expression, output);
        output.Append(";");
    }

    private TranslateExpressionNode(expressionNode: ExpressionNode, output: StringBuilder): void {
        output.Append(expressionNode.GetText());
    }

    private TranslateImportStatement(statementNode: ImportStatementNode, output: StringBuilder): void {
        let path: string;
        if (statementNode.importPath.StartsWith(".")) {
            path = this.projectSettings.name + "." + Path.GetRelativePath(this.projectSettings.projectPath, Path.GetFullPath(Path.Join(Path.GetRelativePath(this.projectSettings.projectPath, Path.GetDirectoryName(statementNode.GetFile())), statementNode.importPath))).Replace(".ph", "").Replace("/", ".");
        }
        else {
            path = statementNode.importPath.Replace("/", ".");
        }

        if (statementNode.namespaceImport != null) {
            output.Append("using " + statementNode.namespaceImport + " = " + path.Replace("/", ".") + ";");
        }
        else if (statementNode.importSpecifiers.Count() > 0) {
            for (const imported of statementNode.importSpecifiers) {
                output.Append("using " + (imported.alias ?? imported.name) + " = " + path.Replace("/", ".") + "." + imported.name + ";");
            }
        }
        else {
            output.Append("using " + path.Replace("/", ".") + ";");
        }
    }
}
