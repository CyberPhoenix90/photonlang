//@ts-nocheck
import { Logger, LogLevel } from 'Logging/src/logging';
import { Exception, Environment, AppDomain, UnhandledExceptionEventHandler, UnhandledExceptionEventArgs } from 'System';
import { Path, File, Directory } from 'System/IO';
import { Assembler } from 'PhotonCompiler/src/compilation/assembler';
import { ProjectSettings } from 'PhotonCompiler/src/project_settings';
import { StaticAnalyzer } from 'PhotonCompiler/src/static_analysis/static_analyzer';
import { JsonConvert } from 'Newtonsoft/Json';
import Collections from 'System/Collections/Generic';
import 'System/Linq';

class EntryPoint {
    public static Main(args: string[]): void {
        const logger = new Logger(LogLevel.INFO);

        logger.stdOut = true;
        if (args.Contains('--verbose')) {
            logger.logLevel = LogLevel.DEBUG;
        }

        const currentDomain = AppDomain.CurrentDomain;
        currentDomain.UnhandledException += new UnhandledExceptionEventHandler((sender: object, args: UnhandledExceptionEventArgs) => {
            const e = args.ExceptionObject as Exception;
            logger.Error('Unhandled Exeption : ' + e.Message);
        });

        const projectSettings = EntryPoint.LoadProjectSettings(Directory.GetCurrentDirectory(), logger);

        if (projectSettings != null) {
            logger.Debug(`Project settings: ${projectSettings}`);
            const assembly = new Assembler(projectSettings, new StaticAnalyzer());
            assembly.Parse();
            assembly.Validate();
            assembly.Emit();
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
            const projectSettings = JsonConvert.DeserializeObject<ProjectSettings>(projectSettingsJson);
            projectSettings.projectPath = projectPath;

            projectSettings.projectReferences ??= <string>[];
            projectSettings.nuget ??= new Collections.Dictionary<string, string>();

            return projectSettings;
        } else {
            logger.Error(`No project settings file found at ${projectSettingsPath}`);
            return null;
        }
    }
}

EntryPoint.Main(Environment.GetCommandLineArgs());
