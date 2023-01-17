import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class ArrayBindingNode extends CSTNode {
    public get elements(): Collections.IEnumerable<IdentifierExpressionNode> {
        return CSTHelper.GetChildrenByType<IdentifierExpressionNode>(this);
    }

    public static ParseArrayBinding(lexer: Lexer): ArrayBindingNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('['));

        while (!lexer.IsPunctuation(']')) {
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
            if (!lexer.IsPunctuation(']')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }

        units.AddRange(lexer.GetPunctuation(']'));

        return new ArrayBindingNode(units);
    }
}
