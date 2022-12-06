import Collections from 'System/Collections/Generic';

export enum AssemblyType {
    Library,
    Executable,
}

export struct ProjectSettings {
    projectPath: string;
    outdir: string;
    entrypoint: string;
    assemblyType: AssemblyType;
    name: string;
    sources:string[];
    projectReferences: string[];
    nuget: Collections.Dictionary<string, string>;
    version: string;
}
