import Collections from 'System/Collections/Generic';
import 'System/Linq';
import { Keywords } from '../../../project_management/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { AttributeNode } from '../other/attribute_node.ph';
import { ClassMethodNode } from '../other/class_method_node.ph';
import { ClassPropertyNode } from '../other/class_property_node.ph';
import { ClassVariableNode } from '../other/class_variable_node.ph';
import { FunctionArgumentsDeclarationNode } from '../other/function_arguments_declaration_node.ph';
import { GenericsDeclarationNode } from '../other/generics_declaration_node.ph';
import { TypeDeclarationNode } from '../other/type_declaration_node.ph';
import { BlockStatementNode } from './block_statement_node.ph';
import { StatementNode } from './statement.ph';

export class FunctionStatementNode extends StatementNode {
    public get name(): string | undefined {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this)?.name;
    }

    public get identifier(): IdentifierExpressionNode | null {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.EXPORT) != null;
    }

    public get isAsync(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ASYNC) != null;
    }

    public get returnType(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get arguments(): FunctionArgumentsDeclarationNode {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsDeclarationNode>(this);
    }

    public get generics(): GenericsDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<GenericsDeclarationNode>(this);
    }

    public get body(): BlockStatementNode | undefined {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public get attributes(): Collections.IEnumerable<AttributeNode> {
        return CSTHelper.GetChildrenByType<AttributeNode>(this);
    }

    public static ParseFunctionStatement(lexer: Lexer): FunctionStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        while (lexer.IsPunctuation('[')) {
            units.Add(AttributeNode.ParseAttribute(lexer));
        }

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ASYNC)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetKeyword(Keywords.FUNCTION));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        if (lexer.IsPunctuation('<')) {
            units.Add(GenericsDeclarationNode.ParseGenericsDeclaration(lexer));
        }

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));
        units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        units.Add(BlockStatementNode.ParseBlockStatement(lexer));

        return new FunctionStatementNode(units);
    }
}
