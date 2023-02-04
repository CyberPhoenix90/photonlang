import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { MatchCaseNode } from '../other/match_case_node.ph';
import { ExpressionNode } from './expression_node.ph';

export class MatchExpressionNode extends ExpressionNode {
    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get cases(): Collections.IEnumerable<MatchCaseNode> {
        return CSTHelper.GetChildrenByType<MatchCaseNode>(this);
    }

    public static ParseMatchExpression(lexer: Lexer): MatchExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.MATCH));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.AddRange(lexer.GetPunctuation('{'));
        while (!lexer.IsPunctuation('}')) {
            units.Add(MatchCaseNode.ParseMatchCase(lexer));
            if (!lexer.IsPunctuation('}')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }
        units.AddRange(lexer.GetPunctuation('}'));

        return new MatchExpressionNode(units);
    }
}
