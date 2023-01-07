import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class PostfixUnaryExpressionNode extends ExpressionNode {
    public static ParsePostfixUnaryExpression(lexer: Lexer, expression: ExpressionNode): PostfixUnaryExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetOneOfPunctuation(<string>['++', '--']));

        return new PostfixUnaryExpressionNode(units);
    }
}
