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
import { TernaryExpressionNode } from './ternary_expression_node.ph';
import { UnaryExpressionNode } from './unary_expression_node.ph';
import { BoolLiteralNode } from './bool_literal_node.ph';
import { NullLiteralNode } from './null_literal_node.ph';
import { NewExpressionNode } from './new_expression_node.ph';
import { PostfixUnaryExpressionNode } from './postfix_unary_expression_node.ph';
import { ArrowExpressionNode } from './arrow_expression_node.ph';
import { ThrowExpressionNode } from './throw_expression_node.ph';
import { ArrayLiteralNode } from './array_literal_node.ph';
import { AsExpressionNode } from './as_expression_node.ph';
import { RangeExpressionNode } from './range_expression_node.ph';

export abstract class ExpressionNode extends CSTNode {
    public static ParseExpression(lexer: Lexer): ExpressionNode {
        const token = lexer.Peek();

        let expression: ExpressionNode = null;

        if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            //We need to differentiate between an arrow function and a parenthesized expression

            const parenthesesEnd = lexer.IndexOf(TokenType.PUNCTUATION, ')');
            if (parenthesesEnd != -1) {
                const save = lexer.GetIndex();
                lexer.SetIndex(parenthesesEnd);
                if (lexer.Peek(1).type == TokenType.PUNCTUATION && lexer.Peek(1).value == '=>') {
                    lexer.SetIndex(save);
                    //Arrow function
                    expression = ArrowExpressionNode.ParseArrowExpression(lexer);
                } else {
                    //Parenthesized expression
                    expression = ParenthesizedExpressionNode.ParseParenthesizedExpression(lexer);
                }
            } else {
                throw new Exception('Unbalanced parentheses');
            }
        } else if (token.type == TokenType.PUNCTUATION && token.value == '!') {
            expression = UnaryExpressionNode.ParseUnaryExpression(lexer);
        } else if (token.type == TokenType.PUNCTUATION && token.value == '++') {
            expression = UnaryExpressionNode.ParseUnaryExpression(lexer);
        } else if (token.type == TokenType.NUMBER) {
            expression = NumberLiteralNode.ParseNumberLiteral(lexer);
        } else if (token.type == TokenType.KEYWORD && token.value == Keywords.NEW) {
            expression = NewExpressionNode.ParseNewExpression(lexer);
        } else if (token.type == TokenType.STRING) {
            expression = StringLiteralNode.ParseStringLiteral(lexer);
        } else if (token.type == TokenType.KEYWORD && token.value == Keywords.THROW) {
            expression = ThrowExpressionNode.ParseThrowExpression(lexer);
        } else if (token.type == TokenType.KEYWORD && (token.value == Keywords.TRUE || token.value == Keywords.FALSE)) {
            expression = BoolLiteralNode.ParseBoolLiteral(lexer);
        } else if (token.type == TokenType.KEYWORD && token.value == Keywords.NULL) {
            expression = NullLiteralNode.ParseNullLiteral(lexer);
        } else if (token.type == TokenType.KEYWORD && token.value == Keywords.THIS) {
            expression = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        } else if (token.type == TokenType.IDENTIFIER) {
            expression = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        } else if (token.type == TokenType.KEYWORD) {
            expression = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        } else if (token.type == TokenType.PUNCTUATION && token.value == '[') {
            expression = ArrayLiteralNode.ParseArrayLiteral(lexer);
        } else {
            if (token.type == TokenType.PUNCTUATION && token.value == '<') {
                const save = lexer.GetIndex();
                const genericsEnd = lexer.IndexOf(TokenType.PUNCTUATION, '>');
                if (genericsEnd != -1) {
                    lexer.SetIndex(genericsEnd);
                    if (lexer.Peek(1).type == TokenType.PUNCTUATION && lexer.Peek(1).value == '[') {
                        lexer.SetIndex(save);
                        expression = ArrayLiteralNode.ParseArrayLiteral(lexer);
                    }
                }
            }
        }
        if (expression == null) {
            throw new Exception('Not implemented');
        }
        return ExpressionNode.ProcessBinaryExpression(lexer, expression);
    }

    private static ProcessBinaryExpression(lexer: Lexer, expression: ExpressionNode): ExpressionNode {
        const token = lexer.Peek();

        if (token.type == TokenType.PUNCTUATION && token.value == '.') {
            return ExpressionNode.ProcessBinaryExpression(lexer, PropertyAccessExpressionNode.ParsePropertyAccessExpression(lexer, expression));
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '[') {
            return ExpressionNode.ProcessBinaryExpression(lexer, ElementAccessExpressionNode.ParseElementAccessExpression(lexer, expression));
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '<') {
            const save = lexer.GetIndex();
            const genericsEnd = lexer.IndexOf(TokenType.PUNCTUATION, '>');
            if (genericsEnd != -1) {
                lexer.SetIndex(genericsEnd);
                if (lexer.Peek(1).type == TokenType.PUNCTUATION && lexer.Peek(1).value == '(') {
                    lexer.SetIndex(save);
                    return ExpressionNode.ProcessBinaryExpression(lexer, CallExpressionNode.ParseCallExpression(lexer, expression));
                } else {
                    lexer.SetIndex(save);
                }
            }
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            return ExpressionNode.ProcessBinaryExpression(lexer, CallExpressionNode.ParseCallExpression(lexer, expression));
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '?') {
            return ExpressionNode.ProcessBinaryExpression(lexer, TernaryExpressionNode.ParseTernaryExpression(lexer, expression));
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '++') {
            return ExpressionNode.ProcessBinaryExpression(lexer, PostfixUnaryExpressionNode.ParsePostfixUnaryExpression(lexer, expression));
        }
        if (token.type == TokenType.PUNCTUATION && token.value == '..') {
            return ExpressionNode.ProcessBinaryExpression(lexer, RangeExpressionNode.ParseRangeExpression(lexer, expression));
        }
        if (token.type == TokenType.KEYWORD && token.value == Keywords.AS) {
            return ExpressionNode.ProcessBinaryExpression(lexer, AsExpressionNode.ParseAsExpression(lexer, expression));
        }
        if (
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
                    '??=',
                ].Contains(token.value)
        ) {
            return ExpressionNode.ProcessBinaryExpression(lexer, BinaryExpressionNode.ParseBinaryExpression(lexer, expression));
        }
        return expression;
    }
}
