import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class TypePropertyAccessExpressionNode extends TypeExpressionNode {
    public static ParseTypePropertyAccessExpression(expression: TypeExpressionNode, lexer: Lexer): TypePropertyAccessExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('.'));
        units.AddRange(lexer.GetIdentifier());

        return new TypePropertyAccessExpressionNode(units);
    }
}
