import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class UnaryExpressionNode extends ExpressionNode {
    public static ParseUnaryExpression(lexer: Lexer): UnaryExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetOneOfPunctuation(<string>['!', '++', '--', '-']));
        units.Add(ExpressionNode.ParseExpression(lexer));
        return new UnaryExpressionNode(units);
    }
}
