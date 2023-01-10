import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class JSONPropertyNode extends CSTNode {
    public static ParseJSONProperty(lexer: Lexer): JSONPropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        units.AddRange(lexer.GetPunctuation(':'));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new JSONPropertyNode(units);
    }
}
