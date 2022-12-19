import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class ParenthesizedExpressionNode extends ExpressionNode {
    public static ParseParenthesizedExpression(lexer: Lexer): ParenthesizedExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));

        return new ParenthesizedExpressionNode(units);
    }
}
