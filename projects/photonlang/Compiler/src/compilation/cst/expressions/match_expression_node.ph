import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { MatchCaseNode } from '../other/match_case_node.ph';

export class MatchExpressionNode extends ExpressionNode {
    public static ParseMatchExpression(lexer: Lexer): MatchExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword('match'));
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
