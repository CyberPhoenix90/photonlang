import Collections from 'System/Collections/Generic';
import { File, Path } from 'System/IO';

export enum AssemblyType {
    Library("library"),
    Executable("executable"),
}

export struct DependencyConfig {
    version: string;
    excludeAssets: string;
}

export struct ProjectSettings {
    projectSDK: string;
    targetFramework:string;
    projectPath: string;
    outdir: string;
    entrypoint: string;
    assemblyType: string;
    name: string;
    sources:string[];
    projectReferences: ProjectSettings[];
    nuget: Collections.Dictionary<string, DependencyConfig>;
    version: string;

    public get csprojPath(): string {
        const outputFolder = Path.GetFullPath(Path.Join(this.projectPath, this.outdir));
        const projectFileOutputPath = Path.GetFullPath(Path.Join(outputFolder, this.name + '.csproj'));

        return projectFileOutputPath;
    }
}

export struct ProjectModel {
    projectSDK: string;
    targetFramework:string;
    projectPath: string;
    outdir: string;
    entrypoint: string;
    assemblyType: string;
    name: string;
    sources:string[];
    projectReferences: string[];
    nuget: Collections.Dictionary<string, DependencyConfig>;
    version: string;
}
