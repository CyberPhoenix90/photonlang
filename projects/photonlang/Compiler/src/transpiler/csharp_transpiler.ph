import { Logger } from 'Logging/src/logging';
import { ProjectSettings } from '../project_settings.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';
import { Path, Directory, File } from 'System/IO';
import { StringBuilder } from 'System/Text';
import { AssemblyType } from '../project_settings.ph';
import 'System/Linq';
import { String, Exception, Environment } from 'System';
import { ParsedProject } from '../static_analysis/parsed_project.ph';
import { FileNode } from '../compilation/cst/file_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { ImportStatementNode } from '../compilation/cst/statements/import_statement_node.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { ProcessStartInfo, Process } from 'System/Diagnostics';
import { CSharpNodeTranslator } from './csharp_node_translator.ph';
import { Project } from 'Microsoft/Build/Evaluation';

export class CSharpTranspiler {
    private logger: Logger;
    private readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: ParsedProject;
    private readonly translator: CSharpNodeTranslator;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, project: ParsedProject, logger: Logger) {
        this.logger = logger;
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.project = project;
        this.translator = new CSharpNodeTranslator(this.staticAnalyzer, this.projectSettings);
    }

    public Emit(): void {
        this.logger.Debug(`Transpiling project ${this.projectSettings.name} to C#`);

        const outputFolder = Path.GetFullPath(Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir));
        Directory.CreateDirectory(outputFolder);

        const projectFile = new StringBuilder();
        const projectFileOutputPath = Path.GetFullPath(Path.Join(outputFolder, this.projectSettings.name + '.csproj'));
        const sdk = this.projectSettings.projectSDK ?? 'Microsoft.NET.Sdk';
        const targetFramework = this.projectSettings.targetFramework ?? 'net7.0';

        projectFile.Append(`
        <Project Sdk=""${sdk}"">
          <PropertyGroup>
            <TargetFramework>${targetFramework}</TargetFramework>
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
                this.projectSettings.projectReferences.Select((library) => '<ProjectReference Include="../' + library + '" />'),
            ),
        );
        projectFile.Append(
            String.Join(
                '\n',
                this.projectSettings.nuget.Select((library) => {
                    const version = library.Value.version;
                    const excludeAssets = library.Value.excludeAssets;
                    let result = '<PackageReference Include="' + library.Key + '" Version="' + version + '"';
                    if (excludeAssets != null) {
                        result += ' ExcludeAssets="' + excludeAssets + '"';
                    }

                    result += ' />';

                    return result;
                }),
            ),
        );
        projectFile.Append(`
          </ItemGroup>

        </Project>
        `);

        if (File.ReadAllText(projectFileOutputPath) != projectFile.ToString()) {
            File.WriteAllText(projectFileOutputPath, projectFile.ToString());
        }

        const msProj = new Project(projectFileOutputPath);

        for (const file of this.project.fileNodes.Values) {
            const outputFilePath = Path.GetFullPath(Path.Join(outputFolder, file.path.Replace('.ph', '.cs')));
            const fileContents = this.EmitFile(file);
            Directory.CreateDirectory(Path.GetDirectoryName(outputFilePath));
            if (!Environment.GetCommandLineArgs().Contains('--no-emit')) {
                File.WriteAllText(outputFilePath, fileContents);
            }
        }

        this.logger.Debug(`Formatting ${this.projectSettings.name}`);
        const process = new ProcessStartInfo();
        process.WorkingDirectory = Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir);
        process.FileName = 'dotnet';
        process.Arguments = `format ${this.projectSettings.name}.csproj`;

        Process.Start(process).WaitForExit();
    }

    private EmitFile(file: FileNode): string {
        const isEntryPoint = this.projectSettings.entrypoint == file.path;

        const sb = new StringBuilder();

        const ambientStatements = file.statements
            .Where((s) => s instanceof EnumNode || s instanceof StructNode || s instanceof ClassNode || s instanceof TypeAliasStatementNode)
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
