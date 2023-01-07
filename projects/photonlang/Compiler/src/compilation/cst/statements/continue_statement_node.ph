import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class ContinueStatementNode extends StatementNode {
    public static ParseContinueStatement(lexer: Lexer): ContinueStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword('continue'));
        units.AddRange(lexer.GetPunctuation(';'));
        return new ContinueStatementNode(units);
    }
}
