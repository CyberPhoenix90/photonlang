import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class ReturnStatementNode extends StatementNode {
    public get expression(): ExpressionNode | undefined {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public static ParseReturnStatement(lexer: Lexer): ReturnStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.RETURN));

        if (lexer.IsPunctuation(';') == false) {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation(';'));
        return new ReturnStatementNode(units);
    }
}
