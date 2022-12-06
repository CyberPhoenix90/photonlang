import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { FileNode } from '../compilation/ast/file_node.ph';
import { LocalFileSystem } from 'FileSystem/src/local_file_system';
import { Logger } from 'Logging/src/logging';

export class AnalyzedProject {
    public readonly project: ProjectSettings;
    public fileNodes: Collections.Dictionary<string, FileNode>;
    public sources: Collections.List<string>;
    private logger: Logger;

    constructor(project: ProjectSettings, logger: Logger) {
        this.project = project;
        this.logger = logger;
        this.fileNodes = new Collections.Dictionary<string, FileNode>();
        this.ResolveSources();
    }

    private ResolveSources(): void {
        const result = new Collections.List<string>();
        for (const source of this.project.sources) {
            if (source.Contains('*')) {
                this.logger.Verbose(`Globbing ${source} at ${this.project.projectPath}`);
                const matches = LocalFileSystem.Instance.Glob(this.project.projectPath, source);
                result.AddRange(matches);
            } else {
                result.Add(source);
            }
        }

        this.logger.Verbose(`Found ${result.Count} sources`);

        this.sources = result;
    }
}