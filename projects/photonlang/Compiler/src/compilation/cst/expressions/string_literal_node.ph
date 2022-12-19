import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class StringLiteralNode extends ExpressionNode {
    public get value(): string {
        return CSTHelper.GetFirstTokenByType(this, TokenType.STRING).value;
    }

    public get unquotedValue(): string {
        return this.value[1..^1];
    }

    public static ParseStringLiteral(lexer: Lexer): StringLiteralNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetString());
        return new StringLiteralNode(units);
    }
}
