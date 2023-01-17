import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';

export class ParenthesizedExpressionNode extends ExpressionNode {
    public get value(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public static ParseParenthesizedExpression(lexer: Lexer): ParenthesizedExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));

        return new ParenthesizedExpressionNode(units);
    }
}
