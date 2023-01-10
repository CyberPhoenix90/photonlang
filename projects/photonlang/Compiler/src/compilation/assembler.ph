import { Logger } from 'Logging/src/logging';
import { ProjectSettings } from '../project_settings.ph';
import { AnalyzedProject } from '../static_analysis/analyzed_project.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';
import { CSharpTranspiler } from '../transpiler/csharp_transpiler.ph';

export class Assembler {
    public readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: AnalyzedProject;
    private readonly logger: Logger;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, logger: Logger) {
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.logger = logger;
        this.staticAnalyzer.AddProject(projectSettings);
    }

    public Parse(): void {
        const project = this.staticAnalyzer.GetProject(this.projectSettings.name);
        project.Parse();
    }
    public Validate(): void {}
    public Emit(): void {
        const project = this.staticAnalyzer.GetProject(this.projectSettings.name);
        this.logger.Debug(`Emitting assembly for project ${this.projectSettings.name}`);
        const transpiler = new CSharpTranspiler(this.projectSettings, this.staticAnalyzer, project, this.logger);
        transpiler.Emit();
    }
}
