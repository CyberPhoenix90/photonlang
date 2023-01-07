import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class ExpressionStatementNode extends StatementNode {
    public static ParseExpressionStatement(lexer: Lexer): ExpressionStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(';'));
        return new ExpressionStatementNode(units);
    }
}
