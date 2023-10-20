import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { AttributeNode } from './attribute_node.ph';
import { FunctionArgumentsDeclarationNode } from './function_arguments_declaration_node.ph';
import { GenericsDeclarationNode } from './generics_declaration_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class InterfaceMethodNode extends CSTNode {
    public get isAsync(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ASYNC) != null;
    }

    public get returnType(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get arguments(): FunctionArgumentsDeclarationNode {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsDeclarationNode>(this);
    }

    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
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

    public static ParseInterfaceMethod(lexer: Lexer, attributes: Collections.List<AttributeNode>): InterfaceMethodNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(attributes);

        let isAsync = false;

        if (lexer.IsKeyword(Keywords.ASYNC)) {
            isAsync = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsPunctuation('<')) {
            units.Add(GenericsDeclarationNode.ParseGenericsDeclaration(lexer));
        }

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));

        if (lexer.IsPunctuation(';')) {
            units.AddRange(lexer.GetPunctuation(';'));
        } else {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        }

        return new InterfaceMethodNode(units);
    }
}
