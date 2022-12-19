import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { TokenType } from '../basic/token.ph';
import { Keywords } from '../../../static_analysis/analyzed_project.ph';
import 'System/Linq';
import { ClassPropertyNode } from '../other/class_property_node.ph';
import { ClassMethodNode } from '../other/class_method_node.ph';
import { ClassVariableNode } from '../other/class_variable_node.ph';
import { ASTNode } from '../basic/ast_node.ph';
import { ASTHelper } from '../ast_helper.ph';

export class ClassNode extends StatementNode {
    public get name(): string | undefined {
        return ASTHelper.GetFirstTokenByType(this, TokenType.IDENTIFIER)?.value;
    }

    public static ParseClass(lexer: Lexer, project: AnalyzedProject): ClassNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword('export')) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword('abstract')) {
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
            units.Add(ClassNode.ParseClassMember(lexer, project));
        }

        units.AddRange(lexer.GetPunctuation('}'));
        return new ClassNode(units);
    }

    private static ParseClassMember(lexer: Lexer, project: AnalyzedProject): ASTNode {
        // We need to check if we're dealing with a method, a variable or a property. Once we find out, we can delegate the parsing to the appropriate method.

        let token = lexer.Peek(0);
        let ptr = 0;

        const skipped = <string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED, Keywords.ABSTRACT, Keywords.STATIC, Keywords.CONST, Keywords.READONLY];

        while (token.type == TokenType.KEYWORD && skipped.Contains(token.value)) {
            ptr++;
            token = lexer.Peek(ptr);
        }

        if (token.type == TokenType.KEYWORD && (token.value == Keywords.GET || token.value == Keywords.SET)) {
            return ClassPropertyNode.ParseClassProperty(lexer, project);
        }

        if (token.type == TokenType.IDENTIFIER && lexer.Peek(ptr + 1).type == TokenType.PUNCTUATION && lexer.Peek(ptr + 1).value == '(') {
            return ClassMethodNode.ParseClassMethod(lexer, project);
        } else {
            return ClassVariableNode.ParseClassVariable(lexer, project);
        }
    }
}
