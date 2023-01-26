import { TypeExpressionNode } from './type_expression_node.ph';
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import 'System/Linq';

export class GenericTypeExpressionNode extends TypeExpressionNode {
    public get type(): TypeExpressionNode {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public get genericArguments(): Collections.IEnumerable<TypeExpressionNode> {
        return CSTHelper.GetChildrenByType<TypeExpressionNode>(this).Skip(1);
    }

    public static ParseGenericTypeExpression(expression: TypeExpressionNode, lexer: Lexer): GenericTypeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);
        units.AddRange(lexer.GetPunctuation('<'));
        while (true) {
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
            if (lexer.IsPunctuation('>')) {
                break;
            }

            units.AddRange(lexer.GetPunctuation(','));
        }
        units.AddRange(lexer.GetPunctuation('>'));

        return new GenericTypeExpressionNode(units);
    }
}
