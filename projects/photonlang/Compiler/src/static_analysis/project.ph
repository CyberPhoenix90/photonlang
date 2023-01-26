import { LogicalCodeUnit } from '../compilation/cst/basic/logical_code_unit.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { VariableDeclarationNode } from '../compilation/cst/other/variable_declaration_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { TypeIdentifierExpressionNode } from '../compilation/cst/type_expressions/type_identifier_expression_node.ph';

export type Declaration = ClassNode | StructNode | EnumNode | VariableDeclarationNode | TypeAliasStatementNode;

export abstract class Project {
    public abstract IdentifierToDeclaration(identifier: TypeIdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null;

    public abstract IdentifierToDeclaration(identifier: IdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null;
}
