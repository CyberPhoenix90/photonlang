import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class CatchClauseNode extends CSTNode {
    public get name(): IdentifierExpressionNode | undefined {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get type(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get body(): BlockStatementNode {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public static ParseCatchClause(lexer: Lexer): CatchClauseNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.CATCH));
        if (lexer.IsPunctuation('(')) {
            units.AddRange(lexer.GetPunctuation('('));
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
            units.AddRange(lexer.GetPunctuation(')'));
        }

        units.Add(BlockStatementNode.ParseBlockStatement(lexer));

        return new CatchClauseNode(units);
    }
}
