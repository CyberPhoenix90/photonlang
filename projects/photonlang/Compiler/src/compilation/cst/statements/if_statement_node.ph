import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';

export class IfStatementNode extends StatementNode {
    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get thenStatement(): StatementNode {
        return CSTHelper.GetFirstChildByType<StatementNode>(this);
    }

    public get elseStatement(): StatementNode {
        return CSTHelper.GetNthChildByType<StatementNode>(this, 1);
    }

    public static ParseIfStatement(lexer: Lexer): IfStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.IF));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer, false));
        if (lexer.IsKeyword(Keywords.ELSE)) {
            units.AddRange(lexer.GetKeyword(Keywords.ELSE));
            units.Add(StatementNode.ParseStatement(lexer, false));
        }

        return new IfStatementNode(units);
    }
}
