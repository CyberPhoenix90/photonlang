import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class BinaryExpressionNode extends ExpressionNode {
    public static ParseBinaryExpression(lexer: Lexer, expression: ExpressionNode): BinaryExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(
            lexer.GetOneOfPunctuation(
                //prettier-ignore
                <string>[
                '=',
                '+=',
                '-=',
                '*=',
                '/=',
                '%=',
                '<<=',
                '>>=',
                '>>>=',
                '&=',
                '^=',
                '|=',
                '==',
                '+',
                '-',
                '*',
                '/',
                '%',
                '<<',
                '>>',
                '>>>',
                '&',
                '^',
                '|',
                '&&',
                '||',
                '!=',
                '<',
                '>',
                '<=',
                '>=',
                '??',
            ],
            ),
        );
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new BinaryExpressionNode(units);
    }
}
