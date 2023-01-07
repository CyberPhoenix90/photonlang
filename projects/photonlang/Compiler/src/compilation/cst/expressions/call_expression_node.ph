import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';

export class CallExpressionNode extends ExpressionNode {
    public static ParseCallExpression(lexer: Lexer, expression: ExpressionNode): CallExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);

        if (lexer.IsPunctuation('<')) {
            units.AddRange(lexer.GetPunctuation('<'));
            while (!lexer.IsPunctuation('>')) {
                units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
                if (!lexer.IsPunctuation('>')) {
                    units.AddRange(lexer.GetPunctuation(','));
                }
            }
            units.AddRange(lexer.GetPunctuation('>'));
        }

        units.AddRange(lexer.GetPunctuation('('));
        while (!lexer.IsPunctuation(')')) {
            units.Add(ExpressionNode.ParseExpression(lexer));
            if (lexer.IsPunctuation(',')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }
        units.AddRange(lexer.GetPunctuation(')'));

        return new CallExpressionNode(units);
    }
}
