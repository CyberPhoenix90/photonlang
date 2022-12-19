import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { Int32, Double } from 'System';

export class NumberLiteralNode extends ExpressionNode {
    public get value(): int {
        return Int32.Parse(CSTHelper.GetFirstTokenByType(this, TokenType.NUMBER).value);
    }

    public get valueDouble(): double {
        return Double.Parse(CSTHelper.GetFirstTokenByType(this, TokenType.NUMBER).value);
    }

    public get isInteger(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.NUMBER).value.IndexOf('.') == -1;
    }

    public static ParseNumberLiteral(lexer: Lexer): NumberLiteralNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetNumber());
        return new NumberLiteralNode(units);
    }
}
