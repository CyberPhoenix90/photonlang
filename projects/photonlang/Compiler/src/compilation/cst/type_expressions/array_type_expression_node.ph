import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class ArrayTypeExpressionNode extends TypeExpressionNode {
    public static ParseArrayTypeExpression(expression: TypeExpressionNode, lexer: Lexer): ArrayTypeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('['));
        units.AddRange(lexer.GetPunctuation(']'));

        return new ArrayTypeExpressionNode(units);
    }
}
