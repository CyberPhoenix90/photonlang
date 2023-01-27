import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';

export class LockStatementNode extends StatementNode {
    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get body(): StatementNode {
        return CSTHelper.GetFirstChildByType<StatementNode>(this);
    }

    public static ParseLockStatement(lexer: Lexer): LockStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.LOCK));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer, false));

        return new LockStatementNode(units);
    }
}
