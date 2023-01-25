import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';

export type Declaration = ClassNode | StructNode | EnumNode;

export abstract class Project {
    public abstract IdentifierToDeclaration(identifier: IdentifierExpressionNode): Declaration;
}
