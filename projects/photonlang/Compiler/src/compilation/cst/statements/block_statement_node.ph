import { Lexer } from '../../parsing/lexer.ph';
import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class BlockStatementNode extends StatementNode {
    public static ParseBlockStatement(lexer: Lexer): BlockStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('{'));
        while (!lexer.IsPunctuation('}')) {
            units.Add(StatementNode.ParseStatement(lexer));
        }
        units.AddRange(lexer.GetPunctuation('}'));

        return new BlockStatementNode(units);
    }
}
