import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { IdentifierExpressionNode } from './identifier_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class PropertyAccessExpressionNode extends ExpressionNode {
    public get obj(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get isOptional(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.PUNCTUATION).value == '?.';
    }

    public get property(): IdentifierExpressionNode {
        return CSTHelper.GetLastChildByType<IdentifierExpressionNode>(this);
    }

    public static ParsePropertyAccessExpression(lexer: Lexer, expression: ExpressionNode): PropertyAccessExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetOneOfPunctuation(['.', '?.']));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        return new PropertyAccessExpressionNode(units);
    }
}
