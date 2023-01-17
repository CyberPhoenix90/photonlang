import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class UnaryExpressionNode extends ExpressionNode {
    public get operation(): string {
        return CSTHelper.GetFirstTokenByType(this, TokenType.PUNCTUATION).value;
    }

    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public static ParseUnaryExpression(lexer: Lexer): UnaryExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetOneOfPunctuation(<string>['!', '++', '--', '-']));
        units.Add(ExpressionNode.ParseExpression(lexer));
        return new UnaryExpressionNode(units);
    }
}
