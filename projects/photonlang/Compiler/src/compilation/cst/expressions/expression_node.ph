import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { Exception } from 'System';
import { ParenthesizedExpressionNode } from './parenthesized_expression_node.ph';
import { NumberLiteralNode } from './number_literal_node.ph';
import { StringLiteralNode } from './string_literal_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { IdentifierExpressionNode } from './identifier_expression_node.ph';
import { PropertyAccessExpressionNode } from './property_access_expression_node.ph';
import { ElementAccessExpressionNode } from './element_access_expression_node.ph';
import { BinaryExpressionNode } from './binary_expression_node.ph';
import 'System/Linq';
import { CallExpressionNode } from './call_expression_node.ph';

export abstract class ExpressionNode extends CSTNode {
    public static ParseExpression(lexer: Lexer): ExpressionNode {
        const token = lexer.Peek();

        let expression: ExpressionNode;

        if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            //We need to differentiate between an arrow function and a parenthesized expression

            const parenthesesEnd = lexer.IndexOf(TokenType.PUNCTUATION, ')');
            if (lexer.GetAt(parenthesesEnd + 1).type == TokenType.PUNCTUATION && lexer.GetAt(parenthesesEnd + 1).value == '=>') {
                //Arrow function
                throw new Exception('Not implemented');
            } else {
                //Parenthesized expression
                expression = ParenthesizedExpressionNode.ParseParenthesizedExpression(lexer);
            }
        } else if (token.type == TokenType.NUMBER) {
            expression = NumberLiteralNode.ParseNumberLiteral(lexer);
        } else if (token.type == TokenType.STRING) {
            expression = StringLiteralNode.ParseStringLiteral(lexer);
        } else if (token.type == TokenType.KEYWORD && token.value == Keywords.THIS) {
            expression = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        } else if (token.type == TokenType.IDENTIFIER) {
            expression = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        } else {
            throw new Exception('Not implemented');
        }

        return ExpressionNode.ProcessBinaryExpression(lexer, expression);
    }

    private static ProcessBinaryExpression(lexer: Lexer, expression: ExpressionNode): ExpressionNode {
        const token = lexer.Peek();

        if (token.type == TokenType.PUNCTUATION && token.value == '.') {
            return ExpressionNode.ProcessBinaryExpression(lexer, PropertyAccessExpressionNode.ParsePropertyAccessExpression(lexer, expression));
        } else if (token.type == TokenType.PUNCTUATION && token.value == '[') {
            return ExpressionNode.ProcessBinaryExpression(lexer, ElementAccessExpressionNode.ParseElementAccessExpression(lexer, expression));
        } else if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            return ExpressionNode.ProcessBinaryExpression(lexer, CallExpressionNode.ParseCallExpression(lexer, expression));
        } else if (
            token.type == TokenType.PUNCTUATION &&
            //prettier-ignore
            <string>[
                    '=',
                    '+=',
                    '-=',
                    '*=',
                    '/=',
                    '%=',
                    '<<=',
                    '>>=',
                    '>>>=',
                    '&=',
                    '^=',
                    '|=',
                    '==',
                    '+',
                    '-',
                    '*',
                    '/',
                    '%',
                    '<<',
                    '>>',
                    '>>>',
                    '&',
                    '^',
                    '|',
                    '&&',
                    '||',
                    '!=',
                    '<',
                    '>',
                    '<=',
                    '>=',
                    '??',
                ].Contains(token.value)
        ) {
            return ExpressionNode.ProcessBinaryExpression(lexer, BinaryExpressionNode.ParseBinaryExpression(lexer, expression));
        } else {
            return expression;
        }
    }
}
