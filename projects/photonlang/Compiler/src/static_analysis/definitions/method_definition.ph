import 'System/Reflection/Metadata';
import { MetadataReader } from 'System/Reflection/Metadata';
import { ClassMethodNode } from '../../compilation/cst/other/class_method_node.ph';
import { FunctionArgumentsDeclarationNode } from '../../compilation/cst/other/function_arguments_declaration_node.ph';

export class MethodDefinition {
    public isConstructor: bool;
    public arguments: FunctionArgumentsDeclarationNode;
    public name: string;

    public static FromClassMethodNode(classMethodNode: ClassMethodNode): MethodDefinition {
        return new MethodDefinition();
    }

    public static FromMethodDefinition(methodDef: dynamic, metadataReader: MetadataReader): MethodDefinition {
        return new MethodDefinition();
    }
}
