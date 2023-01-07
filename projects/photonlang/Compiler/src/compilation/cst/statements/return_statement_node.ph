import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class ReturnStatementNode extends StatementNode {
    public static ParseReturnStatement(lexer: Lexer): ReturnStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword('return'));

        if (lexer.IsPunctuation(';') == false) {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation(';'));
        return new ReturnStatementNode(units);
    }
}
