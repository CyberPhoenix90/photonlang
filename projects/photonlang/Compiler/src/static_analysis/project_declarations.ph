import Collections from 'System/Collections/Generic';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { NamespaceModel } from './namespace_model.ph';

export class ProjectDeclarations {
    public readonly classDeclarations: Collections.Dictionary<NamespaceModel, ClassNode>;
    public readonly enumDeclarations: Collections.Dictionary<NamespaceModel, EnumNode>;
    // public readonly structDeclarations: Collections.Dictionary<NamespaceModel, StructDeclaration>;
    // public readonly tupleDeclarations: Collections.Dictionary<NamespaceModel, TupleDeclaration>;
    // public readonly mixinDeclarations: Collections.Dictionary<NamespaceModel, MixinDeclaration>;
    // public readonly interfaceDeclarations: Collections.Dictionary<NamespaceModel, InterfaceDeclaration>;
    // public readonly typeAliasDeclarations: Collections.Dictionary<NamespaceModel, TypeAliasDeclaration>;
    // public readonly functionDeclarations: Collections.Dictionary<NamespaceModel, FunctionDeclaration>;
    // public readonly variableDeclarations: Collections.Dictionary<NamespaceModel, VariableDeclaration>;

    public constructor() {
        this.classDeclarations = new Collections.Dictionary<NamespaceModel, ClassNode>();
        this.enumDeclarations = new Collections.Dictionary<NamespaceModel, EnumNode>();
    }

    public AddClassDeclaration(classDeclaration: ClassNode): void {
        const namespaceModel = NamespaceModel.FromCST(classDeclaration);
        this.classDeclarations.Add(namespaceModel, classDeclaration);
    }

    public AddEnumDeclaration(enumNode: EnumNode): void {
        const namespaceModel = NamespaceModel.FromCST(enumNode);
        this.enumDeclarations.Add(namespaceModel, enumNode);
    }
}
