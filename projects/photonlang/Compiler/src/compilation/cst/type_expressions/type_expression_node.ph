import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { Exception } from 'System';
import { ParenthesizedTypeExpressionNode } from './parenthesized_type_expression_node.ph';
import { TypeIdentifierExpressionNode } from './type_identifier_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import 'System/Linq';

export abstract class TypeExpressionNode extends CSTNode {
    public static ParseTypeExpression(lexer: Lexer): TypeExpressionNode {
        const token = lexer.Peek();

        let expression: TypeExpressionNode;

        if (token.type == TokenType.PUNCTUATION && token.value == '(') {
            //We need to differentiate between an arrow function and a parenthesized expression

            const parenthesesEnd = lexer.IndexOf(TokenType.PUNCTUATION, ')');
            if (lexer.Peek(parenthesesEnd + 1).type == TokenType.PUNCTUATION && lexer.Peek(parenthesesEnd + 1).value == '=>') {
                //Arrow function
                throw new Exception('Not implemented');
            } else {
                //Parenthesized expression
                expression = ParenthesizedTypeExpressionNode.ParseParenthesizedTypeExpression(lexer);
            }
        } else if (token.type == TokenType.IDENTIFIER) {
            expression = TypeIdentifierExpressionNode.ParseTypeIdentifierExpression(lexer);
        } else if (
            token.type == TokenType.KEYWORD &&
            //prettier-ignore
            <string>[
                    Keywords.STRING,
                    Keywords.BOOL,
                    Keywords.INT,
                    Keywords.FLOAT,
                    Keywords.VOID,
                    Keywords.DOUBLE,
                    Keywords.UINT,
                    Keywords.LONG,
                    Keywords.ULONG,
                    Keywords.SHORT,
                    Keywords.USHORT,
                    Keywords.BYTE,
                    Keywords.SBYTE,
                    Keywords.CHAR,
                    Keywords.DECIMAL,
                    Keywords.OBJECT,
                    Keywords.ANY,
                    Keywords.NINT,
                    Keywords.NUINT,
                ].Contains(token.value)
        ) {
            expression = TypeIdentifierExpressionNode.ParseTypeIdentifierExpression(lexer);
        } else {
            throw new Exception('Not implemented');
        }

        return expression;
    }
}
