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
import { InterfaceMethodNode } from '../other/interface_method_node.ph';
import { InterfacePropertyNode } from '../other/interface_property_node.ph';
import { InterfaceVariableNode } from '../other/interface_variable_node.ph';
import { ExtendsNode } from '../other/extends_node.ph';
import { StatementNode } from './statement.ph';

export class InterfaceNode extends StatementNode {
    public get name(): string | undefined {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this)?.name;
    }

    public get identifier(): IdentifierExpressionNode | null {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.EXPORT) != null;
    }

    public get extendsNode(): ExtendsNode | null {
        return CSTHelper.GetFirstChildByType<ExtendsNode>(this);
    }

    public get properties(): Collections.IEnumerable<InterfacePropertyNode> {
        return CSTHelper.GetChildrenByType<InterfacePropertyNode>(this);
    }

    public get variables(): Collections.IEnumerable<InterfaceVariableNode> {
        return CSTHelper.GetChildrenByType<InterfaceVariableNode>(this);
    }

    public get methods(): Collections.IEnumerable<InterfaceMethodNode> {
        return CSTHelper.GetChildrenByType<InterfaceMethodNode>(this);
    }

    public get attributes(): Collections.IEnumerable<AttributeNode> {
        return CSTHelper.GetChildrenByType<AttributeNode>(this);
    }

    public static ParseInterface(lexer: Lexer): InterfaceNode {
        const units = new Collections.List<LogicalCodeUnit>();

        while (lexer.IsPunctuation('[')) {
            units.Add(AttributeNode.ParseAttribute(lexer));
        }

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetKeyword(Keywords.INTERFACE));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        if (lexer.IsKeyword(Keywords.EXTENDS)) {
            units.Add(ExtendsNode.ParseExtends(lexer));
        }

        units.AddRange(lexer.GetPunctuation('{'));

        while (!lexer.IsPunctuation('}')) {
            units.Add(InterfaceNode.ParseInterfaceMember(lexer));
        }

        units.AddRange(lexer.GetPunctuation('}'));
        const interfaceDeclaration = new InterfaceNode(units);

        return interfaceDeclaration;
    }

    private static ParseInterfaceMember(lexer: Lexer): CSTNode {
        // We need to check if we're dealing with a method, a variable or a property. Once we find out, we can delegate the parsing to the appropriate method.

        const attributes: Collections.List<AttributeNode> = new Collections.List<AttributeNode>();
        while (lexer.IsPunctuation('[')) {
            attributes.Add(AttributeNode.ParseAttribute(lexer));
        }

        let token = lexer.Peek(0);
        let ptr = 0;

        if (token.type == TokenType.KEYWORD && (token.value == Keywords.GET || token.value == Keywords.SET)) {
            return InterfacePropertyNode.ParseInterfaceProperty(lexer, attributes);
        }

        if (token.type == TokenType.KEYWORD && token.value == Keywords.CONSTRUCTOR) {
            return InterfaceMethodNode.ParseInterfaceMethod(lexer, attributes);
        } else if (
            token.type == TokenType.IDENTIFIER &&
            lexer.Peek(ptr + 1).type == TokenType.PUNCTUATION &&
            (lexer.Peek(ptr + 1).value == '(' || lexer.Peek(ptr + 1).value == '<')
        ) {
            return InterfaceMethodNode.ParseInterfaceMethod(lexer, attributes);
        } else {
            return InterfaceVariableNode.ParseInterfaceVariable(lexer, attributes);
        }
    }
}
