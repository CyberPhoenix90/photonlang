import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';

export class EmptyStatementNode extends StatementNode {
    public static ParseEmptyStatement(lexer: Lexer): EmptyStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation(';'));

        return new EmptyStatementNode(units);
    }
}
