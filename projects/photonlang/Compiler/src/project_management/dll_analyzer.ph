import { File } from 'System/IO';
import 'System/Reflection/Metadata';
import Collections from 'System/Collections/Generic';
import { PEReader } from 'System/Reflection/PortableExecutable';

export class DLLAnalyzer {
    public readonly assemblyDefinition: AssemblyDefinition;
    public readonly typeDefinitions: TypeDefinition[];
    private readonly metadataReader: MetadataReader;

    constructor(dll: string) {
        const stream = File.OpenRead(dll);
        const peReader = new PEReader(stream);
        this.metadataReader = peReader.GetMetadataReader();
        this.assemblyDefinition = this.metadataReader.GetAssemblyDefinition();

        const typeDefs = new Collections.List<TypeDefinition>();
        for (const typeDefinitionHandle of this.metadataReader.TypeDefinitions) {
            typeDefs.Add(this.metadataReader.GetTypeDefinition(typeDefinitionHandle));
        }

        this.typeDefinitions = typeDefs.ToArray();
    }
}
