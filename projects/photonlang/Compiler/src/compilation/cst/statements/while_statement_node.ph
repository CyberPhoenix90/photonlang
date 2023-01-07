import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class WhileStatementNode extends StatementNode {
    public static ParseWhileStatement(lexer: Lexer): WhileStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword('while'));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer));

        return new WhileStatementNode(units);
    }
}
