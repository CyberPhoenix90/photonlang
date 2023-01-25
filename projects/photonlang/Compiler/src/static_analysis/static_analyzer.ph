import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { Logger } from 'Logging/src/logging';
import { LinkedProject } from './linked_project.ph';
import { ParsedProject } from './parsed_project.ph';

export class StaticAnalyzer {
    public readonly mainProject: ParsedProject;
    public readonly projectMap: Collections.Dictionary<string, LinkedProject>;
    private logger: Logger;

    constructor(logger: Logger, projectSettings: ProjectSettings) {
        this.logger = logger;
        this.projectMap = new Collections.Dictionary<string, LinkedProject>();
        this.mainProject = new ParsedProject(projectSettings, logger);
    }
}
