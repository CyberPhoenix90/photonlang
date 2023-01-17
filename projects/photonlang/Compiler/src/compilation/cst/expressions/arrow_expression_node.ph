import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { FunctionArgumentsDeclarationNode } from '../other/function_arguments_declaration_node.ph';

export class ArrowExpressionNode extends ExpressionNode {
    public get expression(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get arguments(): FunctionArgumentsDeclarationNode {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsDeclarationNode>(this);
    }

    public get body(): BlockStatementNode | undefined {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public static ParseArrowExpression(lexer: Lexer): ArrowExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));

        units.AddRange(lexer.GetPunctuation('=>'));
        if (lexer.IsPunctuation('{')) {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        } else {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        return new ArrowExpressionNode(units);
    }
}
