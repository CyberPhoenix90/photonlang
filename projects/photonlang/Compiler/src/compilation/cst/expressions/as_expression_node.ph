import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class AsExpressionNode extends ExpressionNode {
    public static ParseAsExpression(lexer: Lexer, expression: ExpressionNode): AsExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetKeyword(Keywords.AS));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));

        return new AsExpressionNode(units);
    }
}