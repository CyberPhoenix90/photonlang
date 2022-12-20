import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { TypeExpressionNode } from './type_expression_node.ph';

export class ParenthesizedTypeExpressionNode extends TypeExpressionNode {
    public static ParseParenthesizedTypeExpression(lexer: Lexer): ParenthesizedTypeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));

        return new ParenthesizedTypeExpressionNode(units);
    }
}
