import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class ThrowExpressionNode extends ExpressionNode {
    public static ParseThrowExpression(lexer: Lexer): ThrowExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.THROW));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new ThrowExpressionNode(units);
    }
}
