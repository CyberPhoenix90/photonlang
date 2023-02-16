import { Logger } from 'Logging/src/logging';
import { File, Path } from 'System/IO';
import { StringBuilder } from 'System/Text';
import { StaticAnalyzer } from '../project_management/static_analyzer.ph';
import { ProjectSettings } from '../project_settings.ph';
import { AssemblyType } from '../project_settings.ph';
import { ParsedProject } from '../project_management/parsed_project.ph';
import 'System/Linq';

export class ProjectFileEmit {
    private logger: Logger;
    private readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: ParsedProject;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, project: ParsedProject, logger: Logger) {
        this.logger = logger;
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.project = project;
    }

    public Generate(): StringBuilder {
        const projectFile = new StringBuilder();
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
            string.Join(
                '\n',
                this.projectSettings.projectReferences.Select((library) => '<ProjectReference Include="../' + library + '" />'),
            ),
        );
        projectFile.Append(
            string.Join(
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

        return projectFile;
    }

    public GetProjectFilePath(): string {
        const outputFolder = Path.GetFullPath(Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir));
        const projectFileOutputPath = Path.GetFullPath(Path.Join(outputFolder, this.projectSettings.name + '.csproj'));

        return projectFileOutputPath;
    }

    public Emit(): void {
        const projectFile = this.Generate();
        const projectFileOutputPath = this.GetProjectFilePath();

        if (!File.Exists(projectFileOutputPath) || File.ReadAllText(projectFileOutputPath) != projectFile.ToString()) {
            File.WriteAllText(projectFileOutputPath, projectFile.ToString());
        }
    }
}
