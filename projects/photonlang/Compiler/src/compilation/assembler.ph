import { ProjectSettings } from '../project_settings.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';

export class Assembler {
    public readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer) {
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.staticAnalyzer.AddProject(projectSettings);
    }

    public Parse(): void {
        const project = this.staticAnalyzer.GetProject(this.projectSettings.name);
        project.Parse();
    }
    public Validate(): void {}
    public Emit(): void {}
}
