import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';

export class RangeExpressionNode extends ExpressionNode {
    public static ParseRangeExpression(lexer: Lexer, expression: ExpressionNode): RangeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('..'));
        if (lexer.IsPunctuation("^")) {
            units.AddRange(lexer.GetPunctuation("^"));
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        return new RangeExpressionNode(units);
    }
}