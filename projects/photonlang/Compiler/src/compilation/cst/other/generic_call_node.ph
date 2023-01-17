import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class GenericCallNode extends CSTNode {
    public get types(): Collections.IEnumerable<TypeExpressionNode> {
        return CSTHelper.GetChildrenByType<TypeExpressionNode>(this);
    }

    public static ParseGenericCall(lexer: Lexer): GenericCallNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('<'));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        while (!lexer.IsPunctuation('>')) {
            units.AddRange(lexer.GetPunctuation(','));
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        }
        units.AddRange(lexer.GetPunctuation('>'));

        return new GenericCallNode(units);
    }
}
