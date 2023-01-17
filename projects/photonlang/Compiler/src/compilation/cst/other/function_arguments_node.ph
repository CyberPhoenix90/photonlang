import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class FunctionArgumentsNode extends CSTNode {
    public get arguments(): Collections.IEnumerable<ExpressionNode> {
        return CSTHelper.GetChildrenByType<ExpressionNode>(this);
    }

    public static ParseFunctionArguments(lexer: Lexer): FunctionArgumentsNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('('));
        while (!lexer.IsPunctuation(')')) {
            units.Add(ExpressionNode.ParseExpression(lexer));

            if (!lexer.IsPunctuation(')')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }

        units.AddRange(lexer.GetPunctuation(')'));

        return new FunctionArgumentsNode(units);
    }
}
