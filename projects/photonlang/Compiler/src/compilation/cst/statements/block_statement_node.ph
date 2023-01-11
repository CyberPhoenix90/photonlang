import { Lexer } from '../../parsing/lexer.ph';
import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';

export class BlockStatementNode extends StatementNode {

    public get statements(): Collections.IEnumerable<StatementNode> {
        return CSTHelper.GetChildrenByType<StatementNode>(this);
    }

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
