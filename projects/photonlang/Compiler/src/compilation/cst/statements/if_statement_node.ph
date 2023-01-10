import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class IfStatementNode extends StatementNode {
    public static ParseIfStatement(lexer: Lexer): IfStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.IF));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer));
        if (lexer.IsKeyword(Keywords.ELSE)) {
            units.AddRange(lexer.GetKeyword(Keywords.ELSE));
            units.Add(StatementNode.ParseStatement(lexer));
        }

        return new IfStatementNode(units);
    }
}
