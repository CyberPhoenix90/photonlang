import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { VariableDeclarationListNode } from '../other/variable_declaration_list_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class ForStatementNode extends StatementNode {
    public static ParseForStatement(lexer: Lexer): LogicalCodeUnit {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.FOR));
        units.AddRange(lexer.GetPunctuation('('));
        if (!lexer.IsPunctuation(';')) {
            if (lexer.IsOneOfKeywords(<string>[Keywords.CONST, Keywords.LET])) {
                units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.CONST, Keywords.LET]));
                units.Add(VariableDeclarationListNode.ParseVariableDeclarationList(lexer));
            } else {
                units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
            }
        }

        if (lexer.IsKeyword(Keywords.OF)) {
            units.AddRange(lexer.GetKeyword(Keywords.OF));
            units.Add(ExpressionNode.ParseExpression(lexer));
        } else {
            units.AddRange(lexer.GetPunctuation(';'));
            units.Add(ExpressionNode.ParseExpression(lexer));
            units.AddRange(lexer.GetPunctuation(';'));
            units.Add(ExpressionNode.ParseExpression(lexer));
        }
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer));

        return new ForStatementNode(units);
    }
}
