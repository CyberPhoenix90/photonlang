import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { VariableDeclarationListNode } from '../other/variable_declaration_list_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';
import { InitializerNode } from '../other/initializer_node.ph';
import { ForIncrementNode } from '../other/for_increment_node.ph';
import { ForConditionNode } from '../other/for_condition_node.ph';

export class ForStatementNode extends StatementNode {
    public get iteratorIdentifier(): IdentifierExpressionNode | undefined {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get initializer(): InitializerNode | undefined {
        return CSTHelper.GetFirstChildByType<InitializerNode>(this);
    }

    public get iteratorDeclaration(): VariableDeclarationListNode | undefined {
        return CSTHelper.GetFirstChildByType<VariableDeclarationListNode>(this);
    }

    public get body(): StatementNode {
        return CSTHelper.GetFirstChildByType<StatementNode>(this);
    }

    public get condition(): ForConditionNode | undefined {
        return CSTHelper.GetFirstChildByType<ForConditionNode>(this);
    }

    public get increment(): ForIncrementNode | undefined {
        return CSTHelper.GetFirstChildByType<ForIncrementNode>(this);
    }

    public static ParseForStatement(lexer: Lexer): ForStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.FOR));
        units.AddRange(lexer.GetPunctuation('('));
        if (!lexer.IsPunctuation(';')) {
            if (lexer.IsOneOfKeywords(<string>[Keywords.CONST, Keywords.LET])) {
                units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.CONST, Keywords.LET]));
                units.Add(VariableDeclarationListNode.ParseVariableDeclarationList(lexer));
            } else {
                units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
                units.Add(InitializerNode.ParseInitializer(lexer));
            }
        }

        units.AddRange(lexer.GetPunctuation(';'));
        if (!lexer.IsPunctuation(';')) {
            units.Add(ForConditionNode.ParseForCondition(lexer));
        }
        units.AddRange(lexer.GetPunctuation(';'));
        if (!lexer.IsPunctuation(')')) {
            units.Add(ForIncrementNode.ParseForIncrement(lexer));
        }

        units.AddRange(lexer.GetPunctuation(')'));
        units.Add(StatementNode.ParseStatement(lexer));

        return new ForStatementNode(units);
    }
}
