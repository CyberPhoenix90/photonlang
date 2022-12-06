import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { AnalyzedProject } from './analyzed_project.ph';

export class StaticAnalyzer {
    public readonly projectMap: Collections.Dictionary<string, AnalyzedProject>;

    constructor() {
        this.projectMap = new Collections.Dictionary<string, AnalyzedProject>();
    }

    public AddProject(project: ProjectSettings): void {
        this.projectMap.Add(project.name, new AnalyzedProject(project));
    }
}
