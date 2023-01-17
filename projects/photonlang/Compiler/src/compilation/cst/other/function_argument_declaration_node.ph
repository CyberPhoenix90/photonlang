import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { InitializerNode } from './initializer_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class FunctionArgumentDeclarationNode extends CSTNode {
    public get identifier(): IdentifierExpressionNode {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get type(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get initializer(): InitializerNode | undefined {
        return CSTHelper.GetFirstChildByType<InitializerNode>(this);
    }

    public get isOptional(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.PUNCTUATION, '?') != null;
    }

    public static ParseFunctionArgumentDeclaration(lexer: Lexer): FunctionArgumentDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsPunctuation('?')) {
            units.AddRange(lexer.GetPunctuation('?'));
        }

        if (lexer.IsPunctuation(':')) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }

        if (lexer.IsPunctuation('=')) {
            units.Add(InitializerNode.ParseInitializer(lexer));
        }

        return new FunctionArgumentDeclarationNode(units);
    }
}
