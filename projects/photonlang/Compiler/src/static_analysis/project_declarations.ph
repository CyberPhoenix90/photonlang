import Collections from 'System/Collections/Generic';
import { ClassNode } from '../compilation/ast/statements/class_node.ph';
import { NamespaceModel } from './namespace_model.ph';

export class ProjectDeclarations {
    public readonly classDeclarations: Collections.Dictionary<NamespaceModel, ClassNode>;
    // public readonly structDeclarations: Collections.Dictionary<NamespaceModel, StructDeclaration>;
    // public readonly tupleDeclarations: Collections.Dictionary<NamespaceModel, TupleDeclaration>;
    // public readonly mixinDeclarations: Collections.Dictionary<NamespaceModel, MixinDeclaration>;
    // public readonly interfaceDeclarations: Collections.Dictionary<NamespaceModel, InterfaceDeclaration>;
    // public readonly typeAliasDeclarations: Collections.Dictionary<NamespaceModel, TypeAliasDeclaration>;
    // public readonly functionDeclarations: Collections.Dictionary<NamespaceModel, FunctionDeclaration>;
    // public readonly enumDeclarations: Collections.Dictionary<NamespaceModel, EnumDeclaration>;
    // public readonly variableDeclarations: Collections.Dictionary<NamespaceModel, VariableDeclaration>;
}
