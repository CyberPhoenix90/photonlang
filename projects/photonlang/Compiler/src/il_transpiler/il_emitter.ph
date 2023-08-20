import { Logger } from 'Logging/src/logging';
import { Directory, File, Path } from 'System/IO';
import 'System/Linq';
import { StringBuilder } from 'System/Text';
import { ProjectFileEmit } from '../emit/projectfile.ph';
import { ParsedProject } from '../project_management/parsed_project.ph';
import { AssemblyType, ProjectSettings } from '../project_settings.ph';
import { Environment, Exception } from 'System';
import { FileNode } from '../compilation/cst/file_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { FunctionStatementNode } from '../compilation/cst/statements/function_statement_node.ph';
import { ImportStatementNode } from '../compilation/cst/statements/import_statement_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { IlNodeTranslator } from './il_node_translator.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';

export class ILEmitter {
    private logger: Logger;
    private readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: ParsedProject;
    private readonly translator: IlNodeTranslator;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, project: ParsedProject, logger: Logger) {
        this.logger = logger;
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.project = project;
    }

    public Emit(): void {
        this.logger.Debug(`Compiling project ${this.projectSettings.name}`);

        const outputFolder = Path.GetFullPath(Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir));
        Directory.CreateDirectory(outputFolder);

        for (const file of this.project.fileNodes.Values) {
            const outputFilePath = Path.GetFullPath(Path.Join(outputFolder, file.path.Replace('.ph', '.cs')));
            const fileContents = this.EmitFile(file);
            Directory.CreateDirectory(Path.GetDirectoryName(outputFilePath));
            if (!Environment.GetCommandLineArgs().Contains('--no-emit')) {
                File.WriteAllText(outputFilePath, fileContents);
            }
        }
    }

    private EmitFile(file: FileNode): string {
        const isEntryPoint = this.projectSettings.entrypoint == file.path;

        const sb = new StringBuilder();

        const ambientStatements = file.statements
            .Where(
                (s) =>
                    s instanceof EnumNode ||
                    s instanceof FunctionStatementNode ||
                    s instanceof StructNode ||
                    s instanceof ClassNode ||
                    s instanceof TypeAliasStatementNode,
            )
            .ToList();
        const ImportStatements = file.statements.Where((s) => s instanceof ImportStatementNode).ToList();
        const globalStatements = file.statements.Where((s) => !ambientStatements.Contains(s) && !ImportStatements.Contains(s)).ToList();
        if (globalStatements.Count() > 0 && (!isEntryPoint || this.projectSettings.assemblyType == AssemblyType.Library)) {
            throw new Exception('Global statements are only allowed in entrypoint files of executable projects');
        }

        for (const statement of ImportStatements) {
            this.translator.TranslateStatement(statement, sb);
        }

        sb.Append('namespace ' + this.projectSettings.name.Replace('-', '_') + '.' + file.path.Replace('.ph', '').Replace('/', '.') + ';\n');

        if (isEntryPoint) {
            sb.Append('class Program { static async System.Threading.Tasks.Task Main(string[] args) {');

            for (const statement of globalStatements) {
                this.translator.TranslateStatement(statement, sb);
            }

            sb.Append('}');
            sb.Append('}');
            sb.AppendLine();
        }
        for (const ambient of ambientStatements) {
            this.translator.TranslateStatement(ambient, sb);
        }

        return sb.ToString();
    }
}
