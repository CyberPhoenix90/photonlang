import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { FileNode } from '../compilation/ast/file_node.ph';
import { LocalFileSystem } from 'FileSystem/src/local_file_system';

export class AnalyzedProject {
    public readonly project: ProjectSettings;
    public fileNodes: Collections.Dictionary<string, FileNode>;
    public sources: Collections.List<string>;

    constructor(project: ProjectSettings) {
        this.project = project;
        this.fileNodes = new Collections.Dictionary<string, FileNode>();
    }

    private ResolveSources(): void {
        const result = new Collections.List<string>();
        for (const source of this.project.sources) {
            if (source.Contains('*')) {
                // Logger.Debug($"Globbing {source} at {projectSettings.projectPath}");
                const matches = LocalFileSystem.Instance.Glob(this.project.projectPath, source);
                result.AddRange(matches);
            } else {
                result.Add(source);
            }
        }

        // Logger.Debug($"Found {result.Count} sources");

        this.sources = result;
    }
}
