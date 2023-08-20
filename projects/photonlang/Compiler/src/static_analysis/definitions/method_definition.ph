import 'System/Reflection/Metadata';
import { MetadataReader } from 'System/Reflection/Metadata';
import { ClassMethodNode } from '../../compilation/cst/other/class_method_node.ph';
import { FunctionArgumentsDeclarationNode } from '../../compilation/cst/other/function_arguments_declaration_node.ph';

export class MethodDefinition {
    public isConstructor: bool;
    public arguments: FunctionArgumentsDeclarationNode;
    public name: string;

    constructor(isConstructor: bool, args: FunctionArgumentsDeclarationNode, name: string) {
        this.isConstructor = isConstructor;
        this.arguments = args;
        this.name = name;
    }

    public static FromClassMethodNode(classMethodNode: ClassMethodNode): MethodDefinition {
        return new MethodDefinition(classMethodNode.isConstructor, classMethodNode.arguments, classMethodNode.name);
    }

    public static FromMethodDefinition(methodDef: dynamic, metadataReader: MetadataReader): MethodDefinition {
        return new MethodDefinition(false, null, metadataReader.GetString(methodDef.Name));
    }
}
