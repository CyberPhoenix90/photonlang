import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { Exception } from 'System';
import { ParenthesizedExpressionNode } from './parenthesized_expression_node.ph';
import { NumberLiteralNode } from './number_literal_node.ph';
import { StringLiteralNode } from './string_literal_node.ph';

export class ExpressionNode extends CSTNode {
    public static ParseExpression(lexer: Lexer): ExpressionNode {
        const token = lexer.Peek();

        let expression: ExpressionNode;

        if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            //We need to differentiate between an arrow function and a parenthesized expression

            const parenthesesEnd = lexer.IndexOf(TokenType.PUNCTUATION, ')');
            if (lexer.Peek(parenthesesEnd + 1).type == TokenType.PUNCTUATION && lexer.Peek(parenthesesEnd + 1).value == '=>') {
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
        } else {
            throw new Exception('Not implemented');
        }

        return expression;
    }
}
