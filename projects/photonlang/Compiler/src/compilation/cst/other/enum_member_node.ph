import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { FunctionArgumentsNode } from './function_arguments_node.ph';
import { GenericCallNode } from './generic_call_node.ph';

export class EnumMemberNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get genericCall(): GenericCallNode | undefined {
        return CSTHelper.GetFirstChildByType<GenericCallNode>(this);
    }

    public get arguments(): FunctionArgumentsNode | undefined {
        return CSTHelper.GetFirstChildByType<FunctionArgumentsNode>(this);
    }

    public static ParseEnumMember(lexer: Lexer): EnumMemberNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsPunctuation('<')) {
            units.Add(GenericCallNode.ParseGenericCall(lexer));
        }
        if (lexer.IsPunctuation('(')) {
            units.Add(FunctionArgumentsNode.ParseFunctionArguments(lexer));
        }

        return new EnumMemberNode(units);
    }
}
