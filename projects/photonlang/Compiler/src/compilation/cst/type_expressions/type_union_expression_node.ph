import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';

export class TypeUnionExpressionNode extends TypeExpressionNode {
    public get left(): TypeExpressionNode {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public get right(): TypeExpressionNode {
        return CSTHelper.GetLastChildByType<TypeExpressionNode>(this);
    }

    public static ParseTypeUnionExpression(typeExpression: TypeExpressionNode, lexer: Lexer): TypeUnionExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(typeExpression);
        units.AddRange(lexer.GetPunctuation('|'));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));

        return new TypeUnionExpressionNode(units);
    }
}
