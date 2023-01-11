import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';

export class IdentifierExpressionNode extends ExpressionNode {

    public get name(): string {
        return CSTHelper.GetFirstCodingToken(this).value;
    }

    public static ParseIdentifierExpression(lexer: Lexer): IdentifierExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword()) {
            units.AddRange(lexer.GetKeyword());
        } else {
            units.AddRange(lexer.GetIdentifier());
        }

        return new IdentifierExpressionNode(units);
    }
}
