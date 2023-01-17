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
import { ReturnStatementNode } from '../compilation/cst/statements/return_statement_node.ph';
import { BreakStatementNode } from '../compilation/cst/statements/break_statement_node.ph';
import { ContinueStatementNode } from '../compilation/cst/statements/continue_statement_node.ph';
import Collections from 'System/Collections/Generic';
import { VariableDeclarationListNode } from '../compilation/cst/other/variable_declaration_list_node.ph';
import { VariableDeclarationStatementNode } from '../compilation/cst/statements/variable_declaration_statement_node.ph';
import { IfStatementNode } from '../compilation/cst/statements/if_statement_node.ph';
import { WhileStatementNode } from '../compilation/cst/statements/while_statement_node.ph';
import { EmptyStatementNode } from '../compilation/cst/statements/empty_statement_node.ph';
import { LockStatementNode } from '../compilation/cst/statements/lock_statement_node.ph';
import { YieldStatementNode } from '../compilation/cst/statements/yield_statement_node.ph';
import { StructVariableNode } from '../compilation/cst/other/struct_variable_node.ph';
import { StructMethodNode } from '../compilation/cst/other/struct_method_node.ph';
import { StructPropertyNode } from '../compilation/cst/other/struct_property_node.ph';
import { GetterSetterStruct } from './getter_setter_struct.ph';
import { GetterSetterClass } from './getter_setter_class.ph';
import { FunctionArgumentDeclarationNode } from '../compilation/cst/other/function_argument_declaration_node.ph';
import { TryStatementNode } from '../compilation/cst/statements/try_statement_node.ph';
import { ParenthesizedExpressionNode } from '../compilation/cst/expressions/parenthesized_expression_node.ph';
import { ThrowExpressionNode } from '../compilation/cst/expressions/throw_expression_node.ph';
import { ElementAccessExpressionNode } from '../compilation/cst/expressions/element_access_expression_node.ph';
import { TernaryExpressionNode } from '../compilation/cst/expressions/ternary_expression_node.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { StringLiteralNode } from '../compilation/cst/expressions/string_literal_node.ph';
import { CallExpressionNode } from '../compilation/cst/expressions/call_expression_node.ph';
import { GenericsDeclarationNode } from '../compilation/cst/other/generics_declaration_node.ph';
import { CSTHelper } from '../compilation/cst/cst_helper.ph';
import { ForStatementNode } from '../compilation/cst/statements/for_statement_node.ph';
import { ForEachStatementNode } from '../compilation/cst/statements/foreach_statement_node.ph';
import { InitializerNode } from '../compilation/cst/other/initializer_node.ph';
import { InstanceOfExpressionNode } from '../compilation/cst/expressions/instance_of_expression_node.ph';
import { BinaryExpressionNode } from '../compilation/cst/expressions/binary_expression_node.ph';
import { ArrowExpressionNode } from '../compilation/cst/expressions/arrow_expression_node.ph';
import { PropertyAccessExpressionNode } from '../compilation/cst/expressions/property_access_expression_node.ph';
import { Regex } from 'System/Text/RegularExpressions';
import { NewExpressionNode } from '../compilation/cst/expressions/new_expression_node.ph';
import { TypeUnionExpressionNode } from '../compilation/cst/type_expressions/type_union_expression_node.ph';
import { UnaryExpressionNode } from '../compilation/cst/expressions/unary_expression_node.ph';
import { ArrayLiteralNode } from '../compilation/cst/expressions/array_literal_node.ph';
import { DelegateTypeExpressionNode } from '../compilation/cst/type_expressions/delegate_type_expression_node.ph';
import { AsExpressionNode } from '../compilation/cst/expressions/as_expression_node.ph';

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
            const outputFilePath = Path.GetFullPath(Path.Join(outputFolder, file.path.Replace('.ph', '.cs')));
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
            output.Append('{');
            output.Append(`\n`);
            for (const statement of statementNode.statements) {
                this.TranslateStatement(statement, output);
            }
            output.Append('}');
        } else if (statementNode instanceof ImportStatementNode) {
            this.TranslateImportStatement(statementNode, output);
        } else if (statementNode instanceof ClassNode) {
            this.TranslateClassDeclarationNode(statementNode, output);
        } else if (statementNode instanceof StructNode) {
            this.TranslateStructDeclarationNode(statementNode, output);
        } else if (statementNode instanceof ExpressionStatementNode) {
            this.TranslateExpressionStatementNode(statementNode, output);
        } else if (statementNode instanceof ReturnStatementNode) {
            this.TranslateReturnStatementNode(statementNode, output);
        } else if (statementNode instanceof BreakStatementNode) {
            this.TranslateBreakStatementNode(statementNode, output);
        } else if (statementNode instanceof ContinueStatementNode) {
            this.TranslateContinueStatementNode(statementNode, output);
        } else if (statementNode instanceof VariableDeclarationStatementNode) {
            this.TranslateVariableDeclarationStatement(statementNode, output);
        } else if (statementNode instanceof IfStatementNode) {
            this.TranslateIfStatementNode(statementNode, output);
        } else if (statementNode instanceof WhileStatementNode) {
            this.TranslateWhileStatementNode(statementNode, output);
        } else if (statementNode instanceof EmptyStatementNode) {
        } else if (statementNode instanceof LockStatementNode) {
            this.TranslateLockStatementNode(statementNode, output);
        } else if (statementNode instanceof YieldStatementNode) {
            this.TranslateYieldStatementNode(statementNode, output);
        } else if (statementNode instanceof TryStatementNode) {
            this.TranslateTryStatementNode(statementNode, output);
        } else if (statementNode instanceof ForStatementNode) {
            this.TranslateForStatementNode(statementNode, output);
        } else if (statementNode instanceof ForEachStatementNode) {
            this.TranslateForEachStatementNode(statementNode, output);
        } else if (statementNode instanceof TypeAliasStatementNode) {
            this.TranslateTypeAliasStatementNode(statementNode, output);
        }
        output.Append(`\n`);
    }

    private TranslateTypeAliasStatementNode(statementNode: TypeAliasStatementNode, output: StringBuilder): void {
        if (statementNode.type instanceof DelegateTypeExpressionNode) {
            if (statementNode.isExported) {
                output.Append('public ');
            }

            output.Append('delegate ');
            this.TranslateTypeExpressionNode((statementNode.type as DelegateTypeExpressionNode).returnType, output);
            output.Append(' ');
            output.Append(statementNode.name);
            this.TranslateFunctionArgumentsDeclarationNode((statementNode.type as DelegateTypeExpressionNode).arguments, output);
            output.Append(`;\n`);
        }
    }

    private TranslateNewExpressionNode(newExpressionNode: NewExpressionNode, output: StringBuilder): void {
        output.Append('new ');
        this.TranslateExpressionNode(newExpressionNode.expression, output);
    }

    private TranslateForStatementNode(forStatementNode: ForStatementNode, output: StringBuilder): void {
        output.Append('for (');
        if (forStatementNode.iteratorIdentifier != null) {
            this.TranslateExpressionNode(forStatementNode.iteratorIdentifier, output);
            this.TranslateInitializerNode(forStatementNode.initializer, output);
        } else if (forStatementNode.iteratorDeclaration != null) {
            this.TranslateVariableDeclarationListNode(forStatementNode.iteratorDeclaration, output);
        }
        output.Append('; ');
        if (forStatementNode.condition != null) {
            this.TranslateExpressionNode(forStatementNode.condition.value, output);
        }
        output.Append('; ');
        if (forStatementNode.increment != null) {
            this.TranslateExpressionNode(forStatementNode.increment.value, output);
        }
        output.Append(') ');
        this.TranslateStatement(forStatementNode.body, output);
    }

    private TranslateForEachStatementNode(forEachStatementNode: ForEachStatementNode, output: StringBuilder): void {
        output.Append('foreach (');
        if (forEachStatementNode.iteratorIdentifier != null) {
            this.TranslateExpressionNode(forEachStatementNode.iteratorIdentifier, output);
        } else if (forEachStatementNode.iteratorDeclaration != null) {
            this.TranslateVariableDeclarationListNode(forEachStatementNode.iteratorDeclaration, output);
        }

        output.Append(' in ');

        this.TranslateExpressionNode(forEachStatementNode.iterable, output);
        output.Append(') ');
        this.TranslateStatement(forEachStatementNode.body, output);
    }

    private TranslateTryStatementNode(statementNode: TryStatementNode, output: StringBuilder): void {
        output.Append('try ');
        this.TranslateStatement(statementNode.body, output);
        for (const catchClause of statementNode.catchClauses) {
            output.Append('catch (');
            if (catchClause.type != null) {
                this.TranslateTypeDeclarationNode(catchClause.type, output);
                output.Append(' ');
                output.Append(catchClause.name);
            } else {
                output.Append('System.Exception __unused');
            }
            output.Append(') ');
            this.TranslateStatement(catchClause.body, output);
        }
        if (statementNode.finallyClause != null) {
            output.Append('finally ');
            this.TranslateStatement(statementNode.finallyClause.body, output);
        }
    }

    private TranslateYieldStatementNode(statementNode: YieldStatementNode, output: StringBuilder): void {
        output.Append('yield return ');
        this.TranslateExpressionNode(statementNode.expression, output);
        output.Append(';');
    }

    private TranslateLockStatementNode(statementNode: LockStatementNode, output: StringBuilder): void {
        output.Append('lock (');
        this.TranslateExpressionNode(statementNode.expression, output);
        output.Append(') ');
        this.TranslateStatement(statementNode.body, output);
    }

    private TranslateWhileStatementNode(statementNode: WhileStatementNode, output: StringBuilder): void {
        output.Append('while (');
        this.TranslateExpressionNode(statementNode.expression, output);
        output.Append(') ');
        this.TranslateStatement(statementNode.body, output);
    }

    private TranslateIfStatementNode(statementNode: IfStatementNode, output: StringBuilder): void {
        output.Append('if (');
        this.TranslateExpressionNode(statementNode.expression, output);
        output.Append(') ');
        this.TranslateStatement(statementNode.thenStatement, output);
        if (statementNode.elseStatement != null) {
            output.Append(' else ');
            this.TranslateStatement(statementNode.elseStatement, output);
        }
    }

    private TranslateVariableDeclarationStatement(statementNode: VariableDeclarationStatementNode, output: StringBuilder): void {
        const declarations = statementNode.declarationList;

        this.TranslateVariableDeclarationListNode(declarations, output);

        output.Append(`;`);
    }

    private TranslateVariableDeclarationListNode(declarationList: VariableDeclarationListNode, output: StringBuilder): void {
        const declarations = declarationList.declarations;

        for (const declaration of declarations) {
            if (declaration.arrayBinding != null) {
                let index = 0;
                const tmpName = '_tmp' + declaration.arrayBinding.elements.First().name;
                output.Append('var ' + tmpName + ' = ');
                if (declaration.initializer != null) {
                    this.TranslateExpressionNode(declaration.initializer.value, output);
                    output.Append(';');
                } else {
                    throw new Exception(
                        'Array binding without initializer not supported in ' +
                            declarationList.GetFile() +
                            ':' +
                            declarationList.GetLine() +
                            ':' +
                            declarationList.GetColumn(),
                    );
                }

                for (const binding of declaration.arrayBinding.elements) {
                    output.Append('var ');
                    output.Append(binding.name + ' = ' + tmpName + '[' + index + ']');
                    index++;
                    output.Append(';');
                }
            } else {
                if (declaration.type != null) {
                    this.TranslateTypeDeclarationNode(declaration.type, output);
                    output.Append(' ');
                } else {
                    output.Append('var ');
                }
                output.Append(declaration.name + ' ');
                if (declaration.initializer != null) {
                    this.TranslateInitializerNode(declaration.initializer, output);
                }
            }
        }
    }

    private TranslateInitializerNode(initializer: InitializerNode, output: StringBuilder): void {
        output.Append('= ');
        this.TranslateExpressionNode(initializer.value, output);
    }

    private TranslateContinueStatementNode(statementNode: ContinueStatementNode, output: StringBuilder): void {
        output.Append('continue;');
    }

    private TranslateBreakStatementNode(statementNode: BreakStatementNode, output: StringBuilder): void {
        output.Append('break;');
    }

    private TranslateReturnStatementNode(statementNode: ReturnStatementNode, output: StringBuilder): void {
        output.Append('return ');
        if (statementNode.expression != null) {
            this.TranslateExpressionNode(statementNode.expression, output);
        }
        output.Append(';');
    }

    private TranslateStructDeclarationNode(structNode: StructNode, output: StringBuilder): void {
        if (structNode.isExported) {
            output.Append('public ');
        }

        output.Append('class ' + structNode.name + ' {');
        output.Append(`\n`);

        if (structNode.implementsNode != null) {
            output.Append('implements ' + String.Join(', ', structNode.implementsNode.identifiers) + ' ');
        }

        output.Append('{');
        output.Append(`\n`);

        for (const variable of structNode.variables) {
            this.TranslateStructVariableDeclarationNode(variable, output);
        }

        const propertyByName = new Collections.Dictionary<string, GetterSetterStruct>();
        for (const property of structNode.properties) {
            if (propertyByName.ContainsKey(property.name)) {
                if (property.isGet) {
                    propertyByName[property.name] = new GetterSetterStruct(property, propertyByName[property.name].setter);
                } else {
                    propertyByName[property.name] = new GetterSetterStruct(propertyByName[property.name].getter, property);
                }
            } else {
                if (property.isGet) {
                    propertyByName[property.name] = new GetterSetterStruct(property, null);
                } else {
                    propertyByName[property.name] = new GetterSetterStruct(null, property);
                }
            }
        }

        for (const property of propertyByName) {
            this.TranslateStructPropertyDeclarationNode(property.Value.getter, property.Value.setter, output);
        }

        for (const method of structNode.methods) {
            this.TranslateStructMethodDeclarationNode(method, structNode, output);
        }
    }

    private TranslateClassDeclarationNode(classNode: ClassNode, output: StringBuilder): void {
        if (classNode.isExported) {
            output.Append('public ');
        }

        if (classNode.isAbstract) {
            output.Append('abstract ');
        }

        output.Append('class ' + classNode.name + ' ');

        if (classNode.extendsNode != null) {
            output.Append(': ' + classNode.extendsNode.name + ' ');
        }

        if (classNode.implementsNode != null) {
            output.Append('implements ' + String.Join(', ', classNode.implementsNode.identifiers) + ' ');
        }

        // if (classNode.usesNode != null) {
        //     output.Append('uses ' + String.Join(', ', classNode.usesNode.identifiers) + ' ');
        // }

        output.Append('{');
        output.Append(`\n`);

        for (const variable of classNode.variables) {
            this.TranslateClassVariableNode(variable, output);
        }

        const propertyByName = new Collections.Dictionary<string, GetterSetterClass>();
        for (const property of classNode.properties) {
            if (propertyByName.ContainsKey(property.name)) {
                if (property.isGet) {
                    propertyByName[property.name] = new GetterSetterClass(property, propertyByName[property.name].setter);
                } else {
                    propertyByName[property.name] = new GetterSetterClass(propertyByName[property.name].getter, property);
                }
            } else {
                if (property.isGet) {
                    propertyByName[property.name] = new GetterSetterClass(property, null);
                } else {
                    propertyByName[property.name] = new GetterSetterClass(null, property);
                }
            }
        }

        for (const property of propertyByName) {
            this.TranslatePropertyDeclarationNode(property.Value.getter, property.Value.setter, output);
        }

        for (const method of classNode.methods) {
            this.TranslateMethodDeclarationNode(method, classNode, output);
        }

        output.Append('}');
    }

    private TranslateStructVariableDeclarationNode(variableNode: StructVariableNode, output: StringBuilder): void {
        if (variableNode.accessor != null) {
            output.Append(variableNode.accessor.accessor + ' ');
        } else {
            output.Append(`public `);
        }

        if (variableNode.isStatic) {
            output.Append('static ');
        }

        if (variableNode.isReadonly) {
            output.Append('readonly ');
        }

        this.TranslateTypeDeclarationNode(variableNode.type, output);

        output.Append(' ' + variableNode.name + ' ');

        if (variableNode.initializer != null) {
            output.Append(' = ');
            this.TranslateExpressionNode(variableNode.initializer.value, output);
        }

        output.Append(';');
    }

    private TranslateStructPropertyDeclarationNode(getter: StructPropertyNode, setter: StructPropertyNode, output: StringBuilder): void {
        let accessor: string;
        if (getter != null && setter != null) {
            if (getter.isStatic != setter.isStatic) {
                throw new Exception('Getter and setter staticness do not match');
            }

            if (getter.isAbstract != setter.isAbstract) {
                throw new Exception('Getter and setter abstractness do not match');
            }

            if (getter.type.GetText() != setter.type.GetText()) {
                throw new Exception('Getter and setter types do not match');
            }

            if (getter.accessor.accessor != setter.accessor.accessor) {
                // Get the least restrictive accessor
                if (getter.accessor.accessor == 'public' || setter.accessor.accessor == 'public') {
                    accessor = 'public';
                } else if (getter.accessor.accessor == 'protected' && setter.accessor.accessor == 'protected') {
                    accessor = 'protected';
                } else {
                    accessor = 'private';
                }
            } else {
                accessor = getter.accessor.accessor;
            }
        } else {
            accessor = getter?.accessor.accessor ?? setter?.accessor.accessor ?? 'public';
        }

        const baseDefinition = getter ?? setter;

        output.Append('    ');
        output.Append(accessor + ' ');
        if (baseDefinition.isStatic) {
            output.Append('static ');
        }
        if (baseDefinition.isAbstract) {
            output.Append('abstract ');
        }
        this.TranslateTypeDeclarationNode(baseDefinition.type, output);
        output.Append(' ');
        output.Append(baseDefinition.name);
        output.Append(' { ');
        if (getter != null) {
            output.Append('get ');
            this.TranslateStatement(getter.body, output);
        }
        if (setter != null) {
            output.Append('set ');
            // if (setter.argumentName != "value") {

            //     var inject = new VariableDeclarationStatement(
            //         new List<LogicalCodeUnit>()
            //         {
            //             new VariableDeclarationList(
            //                 new List<LogicalCodeUnit>()
            //                 {
            //                     new Token(TokenType.Keyword, "const", 0, 0, 0, 0, ""),

            //                     new VariableDeclarationNode(
            //                         new List<LogicalCodeUnit>()
            //                         {
            //                             new IdentifierNode(new List<LogicalCodeUnit>() { new Token(TokenType.Identifier, setter.argumentName, 0, 0, 0, 0, "") }),
            //                             new Token(TokenType.Punctuation, ":", 0, 0, 0, 0, ""),
            //                             new TypeExpressionNode(new List<LogicalCodeUnit>() { new IdentifierNode(new List<LogicalCodeUnit>() { new Token(TokenType.Identifier, setter.type.Text, 0, 0, 0, 0, "") }) })
            //                         }
            //                     )
            //                 }
            //             )
            //         }
            //     );
            //     setter.body.children.Insert(1, inject);
            // }
            this.TranslateStatement(setter.body, output);
        }
        output.Append('}');
        output.Append(`\n`);
    }

    private TranslateStructMethodDeclarationNode(methodNode: StructMethodNode, ownerClass: StructNode, output: StringBuilder): void {
        if (methodNode.accessor != null) {
            output.Append(methodNode.accessor.accessor + ' ');
        } else {
            output.Append('public ');
        }

        if (methodNode.isStatic) {
            output.Append('static ');
        }

        if (methodNode.isAbstract) {
            output.Append('abstract ');
        }

        if (methodNode.isAsync) {
            output.Append('async ');
        }

        if (!methodNode.isConstructor) {
            this.TranslateTypeDeclarationNode(methodNode.returnType, output);
            output.Append(' ' + methodNode.name);
        } else {
            output.Append(ownerClass.name);
        }

        if (methodNode.generics != null) {
            this.TranslateGenericsDeclarationNode(methodNode.generics, output);
        }

        this.TranslateFunctionArgumentsDeclarationNode(methodNode.arguments, output);

        if (methodNode.generics != null && methodNode.generics.arguments.ToList().Exists((x) => x.constraint != null)) {
            output.Append(' where');
            for (const generic of methodNode.generics.arguments) {
                if (generic.constraint == null) {
                    continue;
                }

                output.Append(generic.name + ' : ');
                this.TranslateTypeExpressionNode(generic.constraint, output);
            }
        }

        if (methodNode.isAbstract) {
            output.Append(';');
        } else {
            if (methodNode.isConstructor) {
                let superCall: ExpressionStatementNode | null = null;
                for (const statement of methodNode.body.statements) {
                    if (statement instanceof ExpressionStatementNode) {
                        const call = CSTHelper.FindIn<CallExpressionNode>(statement);
                        const identifier = call.identifier;
                        if (identifier != null && identifier instanceof IdentifierExpressionNode) {
                            if (identifier.name == 'super') {
                                output.Append(' : ');
                                this.TranslateExpressionNode(call, output);
                                output.Append(' ');
                                if (superCall != null) {
                                    throw new Exception('Multiple super calls in constructor');
                                } else {
                                    superCall = statement;
                                }
                            }
                        }
                    }
                }
                if (superCall != null) {
                    methodNode.body.children.Remove(superCall);
                }
            }

            this.TranslateStatement(methodNode.body, output);
        }

        output.Append(`\n`);
    }

    private TranslateGenericsDeclarationNode(genericsNode: GenericsDeclarationNode, output: StringBuilder): void {
        const args = genericsNode.arguments.ToArray();
        output.Append('<');
        for (let i = 0; i < args.Length; i++) {
            if (i > 0) {
                output.Append(', ');
            }

            const generic = args[i];
            output.Append(generic.name);
        }

        output.Append('>');
    }

    private TranslateClassVariableNode(variableNode: ClassVariableNode, output: StringBuilder): void {
        if (variableNode.accessor != null) {
            output.Append(variableNode.accessor.accessor + ' ');
        } else {
            output.Append('public ');
        }

        if (variableNode.isStatic) {
            output.Append('static ');
        }

        if (variableNode.isReadonly) {
            output.Append('readonly ');
        }

        this.TranslateTypeDeclarationNode(variableNode.type, output);

        output.Append(' ' + variableNode.name + ' ');

        if (variableNode.initializer != null) {
            output.Append(' = ');
            this.TranslateExpressionNode(variableNode.initializer.value, output);
        }

        output.Append(';');
        output.Append(`\n`);
    }

    private TranslatePropertyDeclarationNode(getter: ClassPropertyNode, setter: ClassPropertyNode, output: StringBuilder): void {
        let accessor: string;
        if (getter != null && setter != null) {
            if (getter.isStatic != setter.isStatic) {
                throw new Exception('Getter and setter staticness do not match');
            }

            if (getter.isAbstract != setter.isAbstract) {
                throw new Exception('Getter and setter abstractness do not match');
            }

            if (getter.type.GetText() != setter.type.GetText()) {
                throw new Exception('Getter and setter types do not match');
            }

            if (getter.accessor.accessor != setter.accessor.accessor) {
                // Get the least restrictive accessor
                if (getter.accessor.accessor == 'public' || setter.accessor.accessor == 'public') {
                    accessor = 'public';
                } else if (getter.accessor.accessor == 'protected' && setter.accessor.accessor == 'protected') {
                    accessor = 'protected';
                } else {
                    accessor = 'private';
                }
            } else {
                accessor = getter.accessor.accessor;
            }
        } else {
            accessor = getter?.accessor.accessor ?? setter?.accessor.accessor ?? 'public';
        }

        const baseDefinition = getter ?? setter;

        output.Append('    ');
        output.Append(accessor + ' ');
        if (baseDefinition.isStatic) {
            output.Append('static ');
        }
        if (baseDefinition.isAbstract) {
            output.Append('abstract ');
        }
        this.TranslateTypeDeclarationNode(baseDefinition.type, output);
        output.Append(' ');
        output.Append(baseDefinition.name);
        output.Append(' { ');
        if (getter != null) {
            output.Append('get ');
            this.TranslateStatement(getter.body, output);
        }
        if (setter != null) {
            output.Append('set ');
            // if (setter.argumentName != "value") {

            //     var inject = new VariableDeclarationStatement(
            //         new List<LogicalCodeUnit>()
            //         {
            //             new VariableDeclarationList(
            //                 new List<LogicalCodeUnit>()
            //                 {
            //                     new Token(TokenType.Keyword, "const", 0, 0, 0, 0, ""),

            //                     new VariableDeclarationNode(
            //                         new List<LogicalCodeUnit>()
            //                         {
            //                             new IdentifierNode(new List<LogicalCodeUnit>() { new Token(TokenType.Identifier, setter.argumentName, 0, 0, 0, 0, "") }),
            //                             new Token(TokenType.Punctuation, ":", 0, 0, 0, 0, ""),
            //                             new TypeExpressionNode(new List<LogicalCodeUnit>() { new IdentifierNode(new List<LogicalCodeUnit>() { new Token(TokenType.Identifier, setter.type.Text, 0, 0, 0, 0, "") }) })
            //                         }
            //                     )
            //                 }
            //             )
            //         }
            //     );
            //     setter.body.children.Insert(1, inject);
            // }
            this.TranslateStatement(setter.body, output);
        }
        output.Append('}');
        output.Append(`\n`);
    }

    private TranslateMethodDeclarationNode(methodNode: ClassMethodNode, ownerClass: ClassNode, output: StringBuilder): void {
        if (methodNode.accessor != null) {
            output.Append(methodNode.accessor.accessor + ' ');
        } else {
            output.Append('public ');
        }

        if (methodNode.isStatic) {
            output.Append('static ');
        }

        if (methodNode.isAbstract) {
            output.Append('abstract ');
        }

        if (methodNode.isAsync) {
            output.Append('async ');
        }

        if (!methodNode.isConstructor) {
            this.TranslateTypeDeclarationNode(methodNode.returnType, output);
            output.Append(' ' + methodNode.name);
        } else {
            output.Append(ownerClass.name);
        }

        this.TranslateFunctionArgumentsDeclarationNode(methodNode.arguments, output);

        if (methodNode.isAbstract) {
            output.Append(';');
        } else {
            this.TranslateStatement(methodNode.body, output);
        }

        output.Append(`\n`);
    }

    private TranslateFunctionArgumentsDeclarationNode(argumentsNode: FunctionArgumentsDeclarationNode, output: StringBuilder): void {
        output.Append('(');
        let first = true;
        for (const argument of argumentsNode.arguments) {
            if (!first) {
                output.Append(', ');
            }
            this.TranslateFunctionArgumentDeclarationNode(argument, output);
            first = false;
        }
        output.Append(')');
    }

    private TranslateFunctionArgumentDeclarationNode(argumentNode: FunctionArgumentDeclarationNode, output: StringBuilder): void {
        if (argumentNode.type != null) {
            this.TranslateTypeDeclarationNode(argumentNode.type, output);
            if (argumentNode.isOptional) {
                output.Append('?');
            }
        }
        output.Append(' ' + argumentNode.identifier.name);

        if (argumentNode.initializer != null) {
            output.Append(' = ');
            this.TranslateExpressionNode(argumentNode.initializer.value, output);
        }
    }

    private TranslateTypeDeclarationNode(typeNode: TypeDeclarationNode, output: StringBuilder): void {
        this.TranslateTypeExpressionNode(typeNode.type, output);
    }

    private TranslateTypeExpressionNode(typeNode: TypeExpressionNode, output: StringBuilder): void {
        if (typeNode instanceof TypeUnionExpressionNode) {
            if (typeNode.left.GetText().Trim() == 'null' || typeNode.left.GetText().Trim() == 'undefined') {
                this.TranslateTypeExpressionNode(typeNode.right, output);
                output.Append('?');
            } else if (typeNode.right.GetText().Trim() == 'null' || typeNode.right.GetText().Trim() == 'undefined') {
                this.TranslateTypeExpressionNode(typeNode.left, output);
                output.Append('?');
            } else {
                throw new Exception('Cannot translate union type ' + typeNode.GetText());
            }
        } else {
            output.Append(typeNode.GetText());
        }
    }

    private TranslateExpressionStatementNode(expressionStatementNode: ExpressionStatementNode, output: StringBuilder): void {
        this.TranslateExpressionNode(expressionStatementNode.expression, output);
        output.Append(';');
    }

    private TranslateExpressionNode(expressionNode: ExpressionNode, output: StringBuilder): void {
        if (expressionNode instanceof ParenthesizedExpressionNode) {
            output.Append('(');
            this.TranslateExpressionNode(expressionNode.value, output);
            output.Append(')');
        } else if (expressionNode instanceof PropertyAccessExpressionNode) {
            this.TranslateExpressionNode(expressionNode.obj, output);
            if (expressionNode.isOptional) {
                output.Append('?.');
            } else {
                output.Append('.');
            }
            this.TranslateExpressionNode(expressionNode.property, output);
        } else if (expressionNode instanceof NewExpressionNode) {
            this.TranslateNewExpressionNode(expressionNode, output);
        } else if (expressionNode instanceof AsExpressionNode) {
            this.TranslateAsExpressionNode(expressionNode, output);
        } else if (expressionNode instanceof UnaryExpressionNode) {
            this.TranslateUnaryExpressionNode(expressionNode, output);
        } else if (expressionNode instanceof ThrowExpressionNode) {
            output.Append('throw ');
            this.TranslateExpressionNode(expressionNode.value, output);
        } else if (expressionNode instanceof BinaryExpressionNode) {
            this.TranslateExpressionNode(expressionNode.left, output);
            output.Append(' ' + expressionNode.operation + ' ');
            this.TranslateExpressionNode(expressionNode.right, output);
        } else if (expressionNode instanceof ArrowExpressionNode) {
            this.TranslateFunctionArgumentsDeclarationNode(expressionNode.arguments, output);
            output.Append(' => ');
            if (expressionNode.body != null) {
                this.TranslateStatement(expressionNode.body, output);
            } else {
                this.TranslateExpressionNode(expressionNode.expression, output);
            }
        } else if (expressionNode instanceof InstanceOfExpressionNode) {
            this.TranslateExpressionNode(expressionNode.expression, output);
            output.Append(' is ');
            this.TranslateTypeExpressionNode(expressionNode.type, output);
        } else if (expressionNode instanceof ArrayLiteralNode) {
            this.TranslateArrayLiteralNode(expressionNode, output);
        } else if (expressionNode instanceof ElementAccessExpressionNode) {
            this.TranslateExpressionNode(expressionNode.identifier, output);
            output.Append('[');
            this.TranslateExpressionNode(expressionNode.index, output);
            output.Append(']');
        } else if (expressionNode instanceof TernaryExpressionNode) {
            this.TranslateExpressionNode(expressionNode.condition, output);
            output.Append(' ? ');
            this.TranslateExpressionNode(expressionNode.trueExpression, output);
            output.Append(' : ');
            this.TranslateExpressionNode(expressionNode.falseExpression, output);
        } else if (expressionNode instanceof IdentifierExpressionNode) {
            if (expressionNode.name == 'super') {
                output.Append('base');
            } else {
                output.Append(expressionNode.name);
            }
        } else if (expressionNode instanceof CallExpressionNode) {
            this.TranslateExpressionNode(expressionNode.identifier, output);
            let first = true;
            if (expressionNode.genericCall != null) {
                output.Append('<');
                for (const type of expressionNode.genericCall.types) {
                    if (!first) {
                        output.Append(', ');
                    }
                    first = false;
                    this.TranslateTypeExpressionNode(type, output);
                }
                output.Append('>');
            }
            output.Append('(');
            first = true;
            for (const arg of expressionNode.arguments.arguments) {
                if (!first) {
                    output.Append(', ');
                }
                first = false;
                this.TranslateExpressionNode(arg, output);
            }
            output.Append(')');
        } else if (expressionNode instanceof StringLiteralNode) {
            if (expressionNode.value.StartsWith('`')) {
                let stringContent = expressionNode.unquotedValue;

                // Temporary until stateful lexer is implemented
                const regex = new Regex('\\$\\{([^}]+)\\}');
                stringContent = regex.Replace(stringContent, (m) => '{(' + m.Groups[1].Value + ')}');

                const translated = stringContent.Replace('\\', '\\\\').Replace('\r', '\\r').Replace('\t', '\\t').Replace('\0', '\\0').Replace("'", '"');
                output.Append('@$"' + translated + '"');
            } else {
                const value = expressionNode.value;
                if (value[0] == "'"[0]) {
                    output.Append(
                        '"' +
                            value
                                .Substring(1, value.Length - 2)
                                .Replace('\\', '\\\\')
                                .Replace('"', '\\"')
                                .Replace('\n', '\\n')
                                .Replace('\r', '\\r')
                                .Replace('\t', '\\t')
                                .Replace('\0', '\\0') +
                            '"',
                    );
                } else {
                    output.Append(value);
                }
            }
        } else {
            output.Append(expressionNode.GetText());
        }
    }

    private TranslateAsExpressionNode(expressionNode: AsExpressionNode, output: StringBuilder): void {
        this.TranslateExpressionNode(expressionNode.expression, output);
        output.Append(' as ');
        this.TranslateTypeExpressionNode(expressionNode.type, output);
    }

    private TranslateArrayLiteralNode(arrayLiteralNode: ArrayLiteralNode, output: StringBuilder): void {
        output.Append('new ');
        if (arrayLiteralNode.type != null) {
            this.TranslateTypeExpressionNode(arrayLiteralNode.type, output);
        } else {
            output.Append('string');
        }
        output.Append(' {');
        let first = true;
        for (const element of arrayLiteralNode.elements) {
            if (!first) {
                output.Append(', ');
            }
            first = false;
            this.TranslateExpressionNode(element, output);
        }
        output.Append('}');
    }

    private TranslateUnaryExpressionNode(expression: UnaryExpressionNode, output: StringBuilder): void {
        output.Append(expression.operation);
        this.TranslateExpressionNode(expression.expression, output);
    }

    private TranslateImportStatement(statementNode: ImportStatementNode, output: StringBuilder): void {
        let path: string;
        if (statementNode.importPath.StartsWith('.')) {
            path =
                this.projectSettings.name +
                '.' +
                Path.GetRelativePath(
                    this.projectSettings.projectPath,
                    Path.GetFullPath(
                        Path.Join(
                            Path.GetRelativePath(this.projectSettings.projectPath, Path.GetDirectoryName(statementNode.GetFile())),
                            statementNode.importPath,
                        ),
                    ),
                )
                    .Replace('.ph', '')
                    .Replace('/', '.');
        } else {
            path = statementNode.importPath.Replace('/', '.');
        }

        if (statementNode.namespaceImport != null) {
            output.Append('using ' + statementNode.namespaceImport + ' = ' + path.Replace('/', '.') + ';');
        } else if (statementNode.importSpecifiers.Count() > 0) {
            for (const imported of statementNode.importSpecifiers) {
                output.Append('using ' + (imported.alias ?? imported.name) + ' = ' + path.Replace('/', '.') + '.' + imported.name + ';');
            }
        } else {
            output.Append('using ' + path.Replace('/', '.') + ';');
        }
    }
}
