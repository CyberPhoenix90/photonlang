import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { AnalyzedProject } from './analyzed_project.ph';
import { Logger } from 'Logging/src/logging';

export class StaticAnalyzer {
    private readonly projectMap: Collections.Dictionary<string, AnalyzedProject>;
    private logger: Logger;

    constructor(logger: Logger) {
        this.logger = logger;
        this.projectMap = new Collections.Dictionary<string, AnalyzedProject>();
    }

    public AddProject(project: ProjectSettings): void {
        this.projectMap.Add(project.name, new AnalyzedProject(project, this.logger));
    }

    public GetProject(projectName: string): AnalyzedProject {
        return this.projectMap[projectName];
    }
}
