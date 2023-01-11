import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class NewExpressionNode extends ExpressionNode {
    public static ParseNewExpression(lexer: Lexer): NewExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.NEW));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new NewExpressionNode(units);
    }
}