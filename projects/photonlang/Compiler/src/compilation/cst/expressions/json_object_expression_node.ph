import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { JSONPropertyNode } from '../other/json_property_node.ph';

export class JSONObjectExpressionNode extends ExpressionNode {
    public static ParseJSONObjectExpression(lexer: Lexer): JSONObjectExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('{'));
        while (!lexer.IsPunctuation('}')) {
            units.Add(JSONPropertyNode.ParseJSONProperty(lexer));
            if (!lexer.IsPunctuation('}')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }
        units.AddRange(lexer.GetPunctuation('}'));

        return new JSONObjectExpressionNode(units);
    }
}
