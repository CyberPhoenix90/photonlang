import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class IdentifierExpressionNode extends ExpressionNode {
    public static ParseIdentifierExpression(lexer: Lexer): IdentifierExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.THIS)) {
            units.AddRange(lexer.GetKeyword(Keywords.THIS));
        } else {
            units.AddRange(lexer.GetIdentifier());
        }

        return new IdentifierExpressionNode(units);
    }
}
