import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { AccessorNode } from './accessor_node.ph';

export class StructPropertyNode extends CSTNode {
    public get accessor(): AccessorNode {
        return CSTHelper.GetFirstChildByType<AccessorNode>(this);
    }

    public get isStatic(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.STATIC) != null;
    }

    public get isAbstract(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ABSTRACT) != null;
    }

    public get isGet(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.GET) != null;
    }

    public get isSet(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.SET) != null;
    }

    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get body(): BlockStatementNode | undefined {
        return CSTHelper.GetFirstChildByType<BlockStatementNode>(this);
    }

    public get type(): TypeDeclarationNode {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public static ParseStructProperty(lexer: Lexer): StructPropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();
        let isAbstract = false;

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.Add(AccessorNode.ParseAccessor(lexer));
        }

        if (lexer.IsKeyword(Keywords.STATIC)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ABSTRACT)) {
            isAbstract = true;
            units.AddRange(lexer.GetKeyword());
        }

        const isSet = lexer.IsKeyword(Keywords.SET);
        units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.GET, Keywords.SET]));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        units.AddRange(lexer.GetPunctuation('('));

        if (isSet) {
            units.AddRange(lexer.GetIdentifier());
            if (lexer.IsPunctuation(':')) {
                units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
            }
        }
        units.AddRange(lexer.GetPunctuation(')'));

        if (!isSet) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }

        if (!isAbstract) {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        } else {
            units.AddRange(lexer.GetPunctuation(';'));
        }

        return new StructPropertyNode(units);
    }
}
