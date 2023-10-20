import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { AttributeNode } from './attribute_node.ph';

export class InterfacePropertyNode extends CSTNode {
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

    public get attributes(): Collections.IEnumerable<AttributeNode> {
        return CSTHelper.GetChildrenByType<AttributeNode>(this);
    }

    public static ParseInterfaceProperty(lexer: Lexer, attributes: Collections.List<AttributeNode>): InterfacePropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();
        let isAbstract = false;

        units.AddRange(attributes);

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

        return new InterfacePropertyNode(units);
    }
}
