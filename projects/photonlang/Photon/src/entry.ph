import { Logger, LogLevel } from 'Logging/src/logging';
import { Exception, Environment, AppDomain, UnhandledExceptionEventHandler, UnhandledExceptionEventArgs } from 'System';
import { Path, File, Directory } from 'System/IO';
import { Assembler } from 'PhotonCompiler/src/compilation/assembler';
import { ProjectSettings, ProjectModel, DependencyConfig } from 'PhotonCompiler/src/project_settings';
import { StaticAnalyzer } from 'PhotonCompiler/src/project_management/static_analyzer';
import { JsonConvert } from 'Newtonsoft/Json';
import Collections from 'System/Collections/Generic';
import { ParsedArguments } from 'ArgumentParser/src/argument_parser';
import 'System/Linq';

class EntryPoint {
    public static Main(args: string[]): void {
        const parsedArgs = new ParsedArguments(args);
        const logger = new Logger(LogLevel.INFO);

        logger.stdOut = true;
        if (parsedArgs.GetArgumentAsBoolOrDefault('verbose', false)) {
            logger.logLevel = LogLevel.VERBOSE;
        }

        const currentDomain = AppDomain.CurrentDomain;
        currentDomain.UnhandledException += new UnhandledExceptionEventHandler((sender: object, args: UnhandledExceptionEventArgs) => {
            const e = args.ExceptionObject as Exception;
            logger.Error('Unhandled Exeption : ' + e.Message);
        });

        const projectSettings = EntryPoint.LoadProjectSettings(Directory.GetCurrentDirectory(), logger);

        if (projectSettings != null) {
            logger.Debug(`Project settings: ${projectSettings}`);
            const assembly = new Assembler(projectSettings, new StaticAnalyzer(logger, projectSettings), logger);
            assembly.Parse();
            assembly.Validate();
            assembly.Emit();
            assembly.Build();
        } else {
            logger.Error('No project settings found');
        }
    }

    private static LoadProjectSettings(projectPath: string, logger: Logger): ProjectSettings {
        logger.Debug(`Loading project settings from ${projectPath}`);
        //Find photon.json in the project folder and parse it
        const projectSettingsPath = Path.Join(projectPath, 'photon.json');
        if (File.Exists(projectSettingsPath)) {
            logger.Debug(`Found project settings file at ${projectSettingsPath}`);
            const projectSettingsJson = File.ReadAllText(projectSettingsPath);
            const projectModel = JsonConvert.DeserializeObject<ProjectModel>(projectSettingsJson);
            projectModel.projectPath = projectPath;
            projectModel.projectReferences ??= <string>[];
            projectModel.nuget ??= new Collections.Dictionary<string, DependencyConfig>();

            return EntryPoint.ResolveProject(
                projectModel,
                projectModel.projectReferences
                    .Select((projectReference) => EntryPoint.LoadProjectSettings(Path.GetFullPath(Path.Join(projectPath, projectReference)), logger))
                    .ToArray(),
                logger,
            );
        } else {
            logger.Error(`No project settings file found at ${projectSettingsPath}`);
            return null;
        }
    }

    private static ResolveProject(projectModel: ProjectModel, references: ProjectSettings[], logger: Logger): ProjectSettings {
        const projectSettings = new ProjectSettings();
        projectSettings.name = projectModel.name;
        projectSettings.projectPath = projectModel.projectPath;
        projectSettings.projectSDK = projectModel.projectSDK ?? 'Microsoft.NET.Sdk';
        projectSettings.targetFramework = projectModel.targetFramework ?? 'net7.0';
        projectSettings.assemblyType = projectModel.assemblyType;
        projectSettings.projectReferences = references;
        projectSettings.sources = projectModel.sources;
        projectSettings.nuget = projectModel.nuget;
        projectSettings.outdir = projectModel.outdir;
        projectSettings.entrypoint = projectModel.entrypoint;
        projectSettings.version = projectModel.version;

        return projectSettings;
    }
}

EntryPoint.Main(Environment.GetCommandLineArgs());
