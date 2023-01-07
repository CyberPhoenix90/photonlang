import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class GenericTypeExpressionNode extends TypeExpressionNode {
    public static ParseGenericTypeExpression(expression: TypeExpressionNode, lexer: Lexer): GenericTypeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('<'));
        while (true) {
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
            if (lexer.IsPunctuation('>')) {
                break;
            }

            units.AddRange(lexer.GetPunctuation(','));
        }
        units.AddRange(lexer.GetPunctuation('>'));

        return new GenericTypeExpressionNode(units);
    }
}
