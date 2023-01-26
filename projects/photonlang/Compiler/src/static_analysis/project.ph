import { LogicalCodeUnit } from '../compilation/cst/basic/logical_code_unit.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { VariableDeclarationNode } from '../compilation/cst/other/variable_declaration_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';

export type Declaration = ClassNode | StructNode | EnumNode | VariableDeclarationNode;

export abstract class Project {
    public abstract IdentifierToDeclaration(identifier: IdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null;
}
