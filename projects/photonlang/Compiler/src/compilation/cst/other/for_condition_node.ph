import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class ForConditionNode extends CSTNode {

    public get value(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public static ParseForCondition(lexer: Lexer): ForConditionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new ForConditionNode(units);
    }
}