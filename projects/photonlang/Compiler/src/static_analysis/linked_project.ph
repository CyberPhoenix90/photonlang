import { LogicalCodeUnit } from '../compilation/cst/basic/logical_code_unit.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { Declaration } from './project.ph';
import { Project } from './project.ph';

export class LinkedProject extends Project {
    public IdentifierToDeclaration(identifier: IdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null {
        return null;
    }
}
