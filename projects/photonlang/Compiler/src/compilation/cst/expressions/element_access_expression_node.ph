import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';

export class ElementAccessExpressionNode extends ExpressionNode {
    public get identifier(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get index(): ExpressionNode {
        return CSTHelper.GetNthChildByType<ExpressionNode>(this, 1);
    }

    public static ParseElementAccessExpression(lexer: Lexer, expression: ExpressionNode): ElementAccessExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('['));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(']'));

        return new ElementAccessExpressionNode(units);
    }
}
