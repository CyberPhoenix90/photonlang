import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { FunctionArgumentsDeclarationNode } from './function_arguments_declaration_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { Exception } from 'System';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { GenericsDeclarationNode } from './generics_declaration_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { AccessorNode } from './accessor_node.ph';
import { AttributeNode } from './attribute_node.ph';

export class ClassMethodNode extends CSTNode {
    public get accessor(): AccessorNode {
        return CSTHelper.GetFirstChildByType<AccessorNode>(this);
    }

    public get isStatic(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.STATIC) != null;
    }

    public get isAbstract(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ABSTRACT) != null;
    }

    public get isAsync(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ASYNC) != null;
    }

    public get isConstructor(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.CONSTRUCTOR) != null;
    }

    public get returnType(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get arguments(): FunctionArgumentsDeclarationNode {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsDeclarationNode>(this);
    }

    public get name(): string {
        if (this.isConstructor) {
            return 'constructor';
        }

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

    public static ParseClassMethod(lexer: Lexer, attributes: Collections.List<AttributeNode>): ClassMethodNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(attributes);

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.Add(AccessorNode.ParseAccessor(lexer));
        }

        let isStatic = false;
        let isConstructor = false;
        let isAbstract = false;
        let isAsync = false;

        if (lexer.IsKeyword(Keywords.STATIC)) {
            isStatic = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ABSTRACT)) {
            isAbstract = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ASYNC)) {
            isAsync = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.CONSTRUCTOR)) {
            if (isStatic) {
                throw new Exception('Static constructors are not allowed');
            }
            isConstructor = true;
            units.AddRange(lexer.GetKeyword());
        } else {
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        }

        if (lexer.IsPunctuation('<')) {
            units.Add(GenericsDeclarationNode.ParseGenericsDeclaration(lexer));
        }

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));

        if (!isConstructor) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }

        if (isAbstract) {
            units.AddRange(lexer.GetPunctuation(';'));
        } else {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        }

        return new ClassMethodNode(units);
    }
}
