import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class BinaryExpressionNode extends ExpressionNode {
    public get left(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get operation(): string {
        return CSTHelper.GetFirstTokenByType(this, TokenType.PUNCTUATION).value;
    }

    public get right(): ExpressionNode {
        return CSTHelper.GetLastChildByType<ExpressionNode>(this);
    }

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
                '??=',
            ],
            ),
        );
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new BinaryExpressionNode(units);
    }
}
