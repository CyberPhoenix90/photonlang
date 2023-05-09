import { ClassNode } from '../../compilation/cst/statements/class_node.ph';
import 'System/Reflection/Metadata';
import { TypeAttributes } from 'System/Reflection';
import { TypeDefinition, MetadataReader, HandleKind, TypeReferenceHandle, TypeDefinitionHandle, EntityHandle } from 'System/Reflection/Metadata';

export class ClassDefinition {
    public readonly name: string;
    public readonly isExported: bool;
    public readonly isAbstract: bool;
    public readonly extends: string | null;

    constructor(name: string, isExported: bool, isAbstract: bool, extendsName: string | null) {
        this.name = name;
        this.isExported = isExported;
        this.isAbstract = isAbstract;
        this.extends = extendsName;
    }

    public static FromClassNode(classNode: ClassNode): ClassDefinition {
        return new ClassDefinition(classNode.name, classNode.isExported, classNode.isAbstract, classNode.extendsNode?.name);
    }

    public static FromTypeDefinition(typeDefinition: TypeDefinition, metadataReader: MetadataReader): ClassDefinition {
        const name = metadataReader.GetString(typeDefinition.Name);
        const isExported = typeDefinition.Attributes.HasFlag(TypeAttributes.Public);
        const isAbstract = typeDefinition.Attributes.HasFlag(TypeAttributes.Abstract);
        const ext = typeDefinition.BaseType.IsNil ? null : ClassDefinition.GetTypeNameFromHandle(metadataReader, typeDefinition.BaseType);

        return new ClassDefinition(name, isExported, isAbstract, ext);
    }

    static GetTypeNameFromHandle(metadataReader: MetadataReader, handle: EntityHandle): string | null {
        if (handle.Kind == HandleKind.TypeDefinition) {
            const typeDef = metadataReader.GetTypeDefinition(handle as TypeDefinitionHandle);
            return metadataReader.GetString(typeDef.Name);
        } else if (handle.Kind == HandleKind.TypeReference) {
            const typeRef = metadataReader.GetTypeReference(handle as TypeReferenceHandle);
            return metadataReader.GetString(typeRef.Name);
        }
        return null;
    }
}
