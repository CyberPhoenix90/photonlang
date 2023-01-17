import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { TokenType } from '../basic/token.ph';

export class TypeAliasStatementNode extends StatementNode {
    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this)?.name;
    }

    public get type(): TypeExpressionNode {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.EXPORT) != null;
    }

    public static ParseTypeAliasStatement(lexer: Lexer): TypeAliasStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword(Keywords.EXPORT));
        }

        units.AddRange(lexer.GetKeyword('type'));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        units.AddRange(lexer.GetPunctuation('='));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new TypeAliasStatementNode(units);
    }
}
