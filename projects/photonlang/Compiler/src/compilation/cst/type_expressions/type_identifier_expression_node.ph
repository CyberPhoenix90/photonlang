import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from './type_expression_node.ph';

export class TypeIdentifierExpressionNode extends TypeExpressionNode {
    public static ParseTypeIdentifierExpression(lexer: Lexer): TypeIdentifierExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetIdentifier());
        return new TypeIdentifierExpressionNode(units);
    }
}
