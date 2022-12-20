import { CSTHelper } from '../cst_helper.ph';
import 'System/Linq';
import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { StructVariableNode } from '../other/struct_variable_node.ph';
import { StructMethodNode } from '../other/struct_method_node.ph';
import { StructPropertyNode } from '../other/struct_property_node.ph';

export class StructNode extends StatementNode {
    public get name(): string | undefined {
        return CSTHelper.GetFirstTokenByType(this, TokenType.IDENTIFIER)?.value;
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.EXPORT) != null;
    }

    public static ParseStruct(lexer: Lexer): StructNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetKeyword(Keywords.STRUCT));
        units.AddRange(lexer.GetIdentifier());

        if (lexer.IsKeyword(Keywords.IMPLEMENTS)) {
            units.AddRange(lexer.GetKeyword());
            units.AddRange(lexer.GetIdentifier());
        }

        if (lexer.IsKeyword(Keywords.USES)) {
            units.AddRange(lexer.GetKeyword());
            units.AddRange(lexer.GetIdentifier());
        }

        units.AddRange(lexer.GetPunctuation('{'));

        while (!lexer.IsPunctuation('}')) {
            units.Add(StructNode.ParseStructMember(lexer));
        }

        units.AddRange(lexer.GetPunctuation('}'));
        const structDeclaration = new StructNode(units);

        return structDeclaration;
    }

    private static ParseStructMember(lexer: Lexer): CSTNode {
        // We need to check if we're dealing with a method, a variable or a property. Once we find out, we can delegate the parsing to the appropriate method.

        let token = lexer.Peek(0);
        let ptr = 0;

        const skipped = <string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED, Keywords.ABSTRACT, Keywords.STATIC, Keywords.CONST, Keywords.READONLY];

        while (token.type == TokenType.KEYWORD && skipped.Contains(token.value)) {
            ptr++;
            token = lexer.Peek(ptr);
        }

        if (token.type == TokenType.KEYWORD && (token.value == Keywords.GET || token.value == Keywords.SET)) {
            return StructPropertyNode.ParseStructProperty(lexer);
        }

        if (token.type == TokenType.IDENTIFIER && lexer.Peek(ptr + 1).type == TokenType.PUNCTUATION && lexer.Peek(ptr + 1).value == '(') {
            return StructMethodNode.ParseStructMethod(lexer);
        } else {
            return StructVariableNode.ParseStructVariable(lexer);
        }
    }
}
