import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';

export class MatchCaseNode extends CSTNode {
    public get isDefault(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.DEFAULT) != null;
    }

    public get isInstanceOf(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.INSTANCEOF) != null;
    }

    public get expression(): ExpressionNode | undefined {
        const exp = CSTHelper.GetFirstChildByType<ExpressionNode>(this);
        if (exp != this.result) {
            return exp;
        } else {
            return null;
        }
    }

    public get type(): TypeExpressionNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public get result(): ExpressionNode {
        return CSTHelper.GetLastChildByType<ExpressionNode>(this);
    }

    public static ParseMatchCase(lexer: Lexer): MatchCaseNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.DEFAULT)) {
            units.AddRange(lexer.GetKeyword(Keywords.DEFAULT));
        } else if (lexer.IsKeyword(Keywords.INSTANCEOF)) {
            units.AddRange(lexer.GetKeyword(Keywords.INSTANCEOF));
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
            if (!lexer.IsPunctuation('=>')) {
                units.Add(ExpressionNode.ParseExpression(lexer));
            }
        } else {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation('=>'));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new MatchCaseNode(units);
    }
}
