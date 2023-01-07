import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { BlockStatementNode } from './block_statement_node.ph';
import { TypeDeclarationNode } from '../other/type_declaration_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class TryStatementNode extends StatementNode {
    public static ParseTryStatement(lexer: Lexer): TryStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.TRY));
        units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        if (lexer.IsKeyword(Keywords.CATCH)) {
            units.AddRange(lexer.GetKeyword(Keywords.CATCH));
            if (lexer.IsPunctuation('(')) {
                units.AddRange(lexer.GetPunctuation('('));
                units.Add(ExpressionNode.ParseExpression(lexer));
                units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
                units.AddRange(lexer.GetPunctuation(')'));
            }

            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        }

        if (lexer.IsKeyword(Keywords.FINALLY)) {
            units.AddRange(lexer.GetKeyword(Keywords.FINALLY));
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        }
        return new TryStatementNode(units);
    }
}
