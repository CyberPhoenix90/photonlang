//@ts-nocheck
import { Logger, LogLevel } from 'Logger/src/logger';
import { Exception, Environment, AppDomain, UnhandledExceptionEventHandler, UnhandledExceptionEventArgs } from 'System';
import { Path, File, Directory } from 'System/IO';
import { PhotonAssember } from 'PhotonCompiler/src/compiler';
import { ProjectSettings } from 'PhotonCompiler/src/project_settings';
import { JsonConvert } from 'Newtonsoft/Json';
import Collections from 'System/Collections/Generic';
import 'System/Linq';

class EntryPoint {
    static Main(args: string[]): void {
        Logger.stdOut = true;
        if (args.Contains('--verbose')) {
            Logger.logLevel = LogLevel.DEBUG;
            Logger.Debug('Verbose');
        } else {
            Logger.logLevel = LogLevel.INFO;
        }

        const currentDomain = AppDomain.CurrentDomain;
        currentDomain.UnhandledException += new UnhandledExceptionEventHandler((sender: object, args: UnhandledExceptionEventArgs) => {
            const e = (args as Exception).ExceptionObject;
            Logger.Error('Unhandled Exeption : ' + e.Message);
        });

        const projectSettings = this.LoadProjectSettings(Directory.GetCurrentDirectory());

        if (projectSettings != null) {
            Logger.Debug(`Project settings: ${projectSettings}`);
            const assembly = new PhotonAssember(projectSettings);
            assembly.parse();
            assembly.validate();
            assembly.emit();
        } else {
            Logger.Error('No project settings found');
        }
    }

    private static LoadProjectSettings(projectPath: string): ProjectSettings {
        Logger.Debug(`Loading project settings from ${projectPath}`);
        //Find photon.json in the project folder and parse it
        const projectSettingsPath = Path.Join(projectPath, 'photon.json');
        if (File.Exists(projectSettingsPath)) {
            Logger.Debug(`Found project settings file at ${projectSettingsPath}`);
            const projectSettingsJson = File.ReadAllText(projectSettingsPath);
            const projectSettings = JsonConvert.DeserializeObject<ProjectSettings>(projectSettingsJson);
            projectSettings.projectPath = projectPath;

            projectSettings.projectReferences ??= <string>[];
            projectSettings.nuget ??= new Collections.Dictionary<string, string>();

            return projectSettings;
        } else {
            Logger.Error(`No project settings file found at ${projectSettingsPath}`);
            return null;
        }
    }
}

EntryPoint.Main(Environment.GetCommandLineArgs());
