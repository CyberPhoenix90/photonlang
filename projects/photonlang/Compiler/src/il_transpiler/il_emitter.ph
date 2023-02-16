import { Logger } from 'Logging/src/logging';
import { Directory, Path } from 'System/IO';
import 'System/Linq';
import { ProjectFileEmit } from '../emit/projectfile.ph';
import { ParsedProject } from '../project_management/parsed_project.ph';
import { StaticAnalyzer } from '../project_management/static_analyzer.ph';
import { ProjectSettings } from '../project_settings.ph';

export class ILEmitter {
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

    public Emit(): void {
        this.logger.Debug(`Compiling project ${this.projectSettings.name}`);

        const outputFolder = Path.GetFullPath(Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir));
        Directory.CreateDirectory(outputFolder);
        new ProjectFileEmit(this.projectSettings, this.staticAnalyzer, this.project, this.logger).Emit();
    }
}
