import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class EnumMemberNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetNthTokenByType(this, 0, TokenType.IDENTIFIER).value;
    }

    public get value(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public static ParseEnumMember(lexer: Lexer): EnumMemberNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsPunctuation('(')) {
            units.AddRange(lexer.GetPunctuation('('));
            units.Add(ExpressionNode.ParseExpression(lexer));
            units.AddRange(lexer.GetPunctuation(')'));
        }

        return new EnumMemberNode(units);
    }
}
