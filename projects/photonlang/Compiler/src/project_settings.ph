import Collections from 'System/Collections/Generic';

export enum AssemblyType {
    Library("library"),
    Executable("executable"),
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
    nuget: Collections.Dictionary<string, string>;
    version: string;
}
