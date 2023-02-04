import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { BlockStatementNode } from './block_statement_node.ph';
import { TypeDeclarationNode } from '../other/type_declaration_node.ph';
import { Keywords } from '../../../project_management/keywords.ph';
import { CatchClauseNode } from '../other/catch_clause_node.ph';
import { FinallyClauseNode } from '../other/finally_clause_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class TryStatementNode extends StatementNode {
    public get body(): BlockStatementNode {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public get catchClauses(): Collections.IEnumerable<CatchClauseNode> {
        return CSTHelper.GetChildrenByType<CatchClauseNode>(this);
    }

    public get finallyClause(): FinallyClauseNode | undefined {
        return CSTHelper.GetFirstChildByType<FinallyClauseNode>(this);
    }

    public static ParseTryStatement(lexer: Lexer): TryStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.TRY));
        units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        while (lexer.IsKeyword(Keywords.CATCH)) {
            units.Add(CatchClauseNode.ParseCatchClause(lexer));
        }

        if (lexer.IsKeyword(Keywords.FINALLY)) {
            units.Add(FinallyClauseNode.ParseFinallyClause(lexer));
        }
        return new TryStatementNode(units);
    }
}
