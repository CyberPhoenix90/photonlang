import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class ArrayLiteralNode extends ExpressionNode {
    public get type(): TypeExpressionNode {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public get elements(): Collections.IEnumerable<ExpressionNode> {
        return CSTHelper.GetChildrenByType<ExpressionNode>(this);
    }

    public static ParseArrayLiteral(lexer: Lexer): ArrayLiteralNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsPunctuation('<')) {
            units.AddRange(lexer.GetPunctuation('<'));
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
            units.AddRange(lexer.GetPunctuation('>'));
        }

        units.AddRange(lexer.GetPunctuation('['));
        while (!lexer.IsPunctuation(']')) {
            units.Add(ExpressionNode.ParseExpression(lexer));
            if (!lexer.IsPunctuation(']')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }
        units.AddRange(lexer.GetPunctuation(']'));

        return new ArrayLiteralNode(units);
    }
}
