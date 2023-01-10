import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class MatchCaseNode extends CSTNode {
    public static ParseMatchCase(lexer: Lexer): MatchCaseNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.DEFAULT)) {
            units.AddRange(lexer.GetKeyword(Keywords.DEFAULT));
        } else {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation('=>'));
        units.Add(ExpressionNode.ParseExpression(lexer));

        return new MatchCaseNode(units);
    }
}
