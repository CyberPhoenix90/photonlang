import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class BreakStatementNode extends StatementNode {
    public static ParseBreakStatement(lexer: Lexer): BreakStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword('break'));
        units.AddRange(lexer.GetPunctuation(';'));
        return new BreakStatementNode(units);
    }
}
