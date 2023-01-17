import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';

export class FinallyClauseNode extends CSTNode {
    public get body(): BlockStatementNode {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public static ParseFinallyClause(lexer: Lexer): FinallyClauseNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.FINALLY));
        units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        return new FinallyClauseNode(units);
    }
}
