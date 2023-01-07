import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';

export class TypeUnionExpressionNode extends TypeExpressionNode {
    public static ParseTypeUnionExpression(typeExpression: TypeExpressionNode, lexer: Lexer): TypeUnionExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(typeExpression);
        units.AddRange(lexer.GetPunctuation('|'));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));

        return new TypeUnionExpressionNode(units);
    }
}
