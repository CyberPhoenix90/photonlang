import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { VariableDeclarationListNode } from '../other/variable_declaration_list_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';

export class ForEachStatementNode extends StatementNode {
    public get body(): StatementNode {
        return CSTHelper.GetFirstChildByType<StatementNode>(this);
    }

    public get iteratorIdentifier(): IdentifierExpressionNode | undefined {
        const identifier = CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
        if (identifier != this.iterable) {
            return identifier;
        } else {
            return null;
        }
    }

    public get iteratorDeclaration(): VariableDeclarationListNode | undefined {
        return CSTHelper.GetFirstChildByType<VariableDeclarationListNode>(this);
    }

    public get iterable(): ExpressionNode {
        return CSTHelper.GetLastChildByType<ExpressionNode>(this);
    }

    public static ParseForEachStatement(lexer: Lexer): ForEachStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.FOR));
        units.AddRange(lexer.GetPunctuation('('));

        if (lexer.IsOneOfKeywords(<string>[Keywords.CONST, Keywords.LET])) {
            units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.CONST, Keywords.LET]));
            units.Add(VariableDeclarationListNode.ParseVariableDeclarationList(lexer));
        } else {
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        }

        units.AddRange(lexer.GetKeyword(Keywords.OF));
        units.Add(ExpressionNode.ParseExpression(lexer));
        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer, false));

        return new ForEachStatementNode(units);
    }
}
