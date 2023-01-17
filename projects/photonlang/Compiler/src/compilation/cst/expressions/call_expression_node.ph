import { Lexer } from '../../parsing/lexer.ph';
import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { GenericCallNode } from '../other/generic_call_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { FunctionArgumentsNode } from '../other/function_arguments_node.ph';

export class CallExpressionNode extends ExpressionNode {
    public get identifier(): ExpressionNode {
        return CSTHelper.GetFirstChildByType<ExpressionNode>(this);
    }

    public get genericCall(): GenericCallNode | undefined {
        return CSTHelper.GetFirstChildByType<GenericCallNode>(this);
    }

    public get arguments(): FunctionArgumentsNode {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsNode>(this);
    }

    public static ParseCallExpression(lexer: Lexer, expression: ExpressionNode): CallExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(expression);

        if (lexer.IsPunctuation('<')) {
            units.Add(GenericCallNode.ParseGenericCall(lexer));
        }

        units.Add(FunctionArgumentsNode.ParseFunctionArguments(lexer));

        return new CallExpressionNode(units);
    }
}
