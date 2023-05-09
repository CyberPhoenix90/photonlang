import 'System/Reflection';

export class DLLAnalyzer {
    public readonly assemblyDefinition: Assembly;

    constructor(mlc: MetadataLoadContext, dll: string) {
        this.assemblyDefinition = mlc.LoadFromAssemblyPath(dll);
    }
}
