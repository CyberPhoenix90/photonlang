import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class ContinueStatementNode extends StatementNode {
    public static ParseContinueStatement(lexer: Lexer): ContinueStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.CONTINUE));
        units.AddRange(lexer.GetPunctuation(';'));
        return new ContinueStatementNode(units);
    }
}
