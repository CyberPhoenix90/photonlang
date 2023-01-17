import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';

export class TernaryExpressionNode extends ExpressionNode {
    public get condition(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get trueExpression(): ExpressionNode {
        return CSTHelper.GetNthChildByType<ExpressionNode>(this, 1);
    }

    public get falseExpression(): ExpressionNode {
        return CSTHelper.GetNthChildByType<ExpressionNode>(this, 2);
    }

    public static ParseTernaryExpression(lexer: Lexer, expression: ExpressionNode): TernaryExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('?'));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(':'));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new TernaryExpressionNode(units);
    }
}
