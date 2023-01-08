import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { TypeDeclarationNode } from '../other/type_declaration_node.ph';
import { IdentifierExpressionNode } from './identifier_expression_node.ph';

export class ArrowExpressionNode extends ExpressionNode {
    public static ParseArrowExpression(lexer: Lexer): ArrowExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('('));
        while (true) {
            if (lexer.IsPunctuation(')')) {
                break;
            }
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
            if(lexer.IsPunctuation(':')) {
                units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
            }
            if (!lexer.IsPunctuation(')')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }
        units.AddRange(lexer.GetPunctuation(')'));
        units.AddRange(lexer.GetPunctuation('=>'));
        if (lexer.IsPunctuation('{')) {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        } else {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        return new ArrowExpressionNode(units);
    }
}
