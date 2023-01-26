import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class YieldStatementNode extends StatementNode {
    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get isBreak(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.BREAK) != null;
    }

    public static ParseYieldStatement(lexer: Lexer): YieldStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.YIELD));

        if (lexer.IsKeyword(Keywords.BREAK)) {
            units.AddRange(lexer.GetKeyword(Keywords.BREAK));
        } else {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation(';'));

        return new YieldStatementNode(units);
    }
}
