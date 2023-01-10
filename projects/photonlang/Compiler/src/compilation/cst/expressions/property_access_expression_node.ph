import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class PropertyAccessExpressionNode extends ExpressionNode {
    public static ParsePropertyAccessExpression(lexer: Lexer, expression: ExpressionNode): PropertyAccessExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetOneOfPunctuation(['.', '?.']));
        if (lexer.IsKeyword()) {
            units.AddRange(lexer.GetKeyword());
        } else {
            units.AddRange(lexer.GetIdentifier());
        }

        return new PropertyAccessExpressionNode(units);
    }
}
