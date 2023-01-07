import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class IfStatementNode extends StatementNode {
    public static ParseIfStatement(lexer: Lexer): IfStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword('if'));
        units.AddRange(lexer.GetPunctuation('('));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer));
        if (lexer.IsKeyword('else')) {
            units.AddRange(lexer.GetKeyword('else'));
            units.Add(StatementNode.ParseStatement(lexer));
        }

        return new IfStatementNode(units);
    }
}
