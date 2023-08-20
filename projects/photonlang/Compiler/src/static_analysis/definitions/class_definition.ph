import { ClassNode } from '../../compilation/cst/statements/class_node.ph';
import 'System/Reflection/Metadata';
import { TypeAttributes } from 'System/Reflection';
import { TypeDefinition, MetadataReader, HandleKind, TypeReferenceHandle, TypeDefinitionHandle, EntityHandle } from 'System/Reflection/Metadata';
import { MethodDefinition } from './method_definition.ph';
import Collections from 'System/Collections/Generic';

export class ClassDefinition {
    public readonly name: string;
    public readonly isExported: bool;
    public readonly isAbstract: bool;
    public readonly extends: string | null;
    public readonly methods: MethodDefinition[];

    constructor(name: string, isExported: bool, isAbstract: bool, extendsName: string | null, methods: MethodDefinition[]) {
        this.name = name;
        this.isExported = isExported;
        this.isAbstract = isAbstract;
        this.extends = extendsName;
        this.methods = methods;
    }

    public static FromClassNode(classNode: ClassNode): ClassDefinition {
        const m = new Collections.List<MethodDefinition>();
        for (const method of classNode.methods) {
            m.Add(MethodDefinition.FromClassMethodNode(method));
        }

        return new ClassDefinition(classNode.name, classNode.isExported, classNode.isAbstract, classNode.extendsNode?.name, m.ToArray());
    }

    public static FromTypeDefinition(typeDefinition: TypeDefinition, metadataReader: MetadataReader): ClassDefinition {
        const name = metadataReader.GetString(typeDefinition.Name);
        const isExported = typeDefinition.Attributes.HasFlag(TypeAttributes.Public);
        const isAbstract = typeDefinition.Attributes.HasFlag(TypeAttributes.Abstract);
        const ext = typeDefinition.BaseType.IsNil ? null : ClassDefinition.GetTypeNameFromHandle(metadataReader, typeDefinition.BaseType);
        const methods = new Collections.List<MethodDefinition>();

        for (const methodHandle of typeDefinition.GetMethods()) {
            const methodDef = metadataReader.GetMethodDefinition(methodHandle);
            methods.Add(MethodDefinition.FromMethodDefinition(methodDef, metadataReader));
        }

        return new ClassDefinition(name, isExported, isAbstract, ext, methods.ToArray());
    }

    private static GetTypeNameFromHandle(metadataReader: MetadataReader, handle: EntityHandle): string | null {
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
