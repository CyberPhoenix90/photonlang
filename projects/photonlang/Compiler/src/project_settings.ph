import Collections from 'System/Collections/Generic';

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
    projectReferences: string[];
    nuget: Collections.Dictionary<string, DependencyConfig>;
    version: string;
}
