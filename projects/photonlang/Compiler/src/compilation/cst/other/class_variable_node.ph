import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { AccessorNode } from './accessor_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { InitializerNode } from './initializer_node.ph';
import { AttributeNode } from './attribute_node.ph';

export class ClassVariableNode extends CSTNode {
    public get accessor(): AccessorNode {
        return CSTHelper.GetFirstChildByType<AccessorNode>(this);
    }

    public get isStatic(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.STATIC) != null;
    }

    public get isReadonly(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.READONLY) != null;
    }

    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get type(): TypeDeclarationNode {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get initializer(): InitializerNode | undefined {
        return CSTHelper.GetFirstChildByType<InitializerNode>(this);
    }

    public get attributes(): Collections.IEnumerable<AttributeNode> {
        return CSTHelper.GetChildrenByType<AttributeNode>(this);
    }

    public static ParseClassVariable(lexer: Lexer, attributes: Collections.List<AttributeNode>): ClassVariableNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(attributes);

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.Add(AccessorNode.ParseAccessor(lexer));
        }

        if (lexer.IsKeyword(Keywords.STATIC)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.READONLY)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));

        if (lexer.IsPunctuation('=')) {
            units.Add(InitializerNode.ParseInitializer(lexer));
        }

        units.AddRange(lexer.GetPunctuation(';'));

        return new ClassVariableNode(units);
    }
}
