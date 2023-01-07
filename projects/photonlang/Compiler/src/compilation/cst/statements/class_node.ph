import Collections from 'System/Collections/Generic';
import 'System/Linq';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { ClassMethodNode } from '../other/class_method_node.ph';
import { ClassPropertyNode } from '../other/class_property_node.ph';
import { ClassVariableNode } from '../other/class_variable_node.ph';
import { StatementNode } from './statement.ph';

export class ClassNode extends StatementNode {
    public get name(): string | undefined {
        return CSTHelper.GetFirstTokenByType(this, TokenType.IDENTIFIER)?.value;
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.EXPORT) != null;
    }

    public get isAbstract(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD, Keywords.ABSTRACT) != null;
    }

    public static ParseClass(lexer: Lexer): ClassNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ABSTRACT)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetKeyword(Keywords.CLASS));
        units.AddRange(lexer.GetIdentifier());

        if (lexer.IsKeyword(Keywords.EXTENDS)) {
            units.AddRange(lexer.GetKeyword());
            units.AddRange(lexer.GetIdentifier());
        }

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
            units.Add(ClassNode.ParseClassMember(lexer));
        }

        units.AddRange(lexer.GetPunctuation('}'));
        const classDeclaration = new ClassNode(units);

        return classDeclaration;
    }

    private static ParseClassMember(lexer: Lexer): CSTNode {
        // We need to check if we're dealing with a method, a variable or a property. Once we find out, we can delegate the parsing to the appropriate method.

        let token = lexer.Peek(0);
        let ptr = 0;

        const skipped = <string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED, Keywords.ABSTRACT, Keywords.STATIC, Keywords.CONST, Keywords.READONLY];

        while (token.type == TokenType.KEYWORD && skipped.Contains(token.value)) {
            ptr++;
            token = lexer.Peek(ptr);
        }

        if (token.type == TokenType.KEYWORD && (token.value == Keywords.GET || token.value == Keywords.SET)) {
            return ClassPropertyNode.ParseClassProperty(lexer);
        }

        if (token.type == TokenType.KEYWORD && token.value == Keywords.CONSTRUCTOR) {
            return ClassMethodNode.ParseClassMethod(lexer);
        } else if (token.type == TokenType.IDENTIFIER && lexer.Peek(ptr + 1).type == TokenType.PUNCTUATION && lexer.Peek(ptr + 1).value == '(') {
            return ClassMethodNode.ParseClassMethod(lexer);
        } else {
            return ClassVariableNode.ParseClassVariable(lexer);
        }
    }
}
