import { TypeExpressionNode } from './type_expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { FunctionArgumentsDeclarationNode } from '../other/function_arguments_declaration_node.ph';

export class DelegateTypeExpressionNode extends TypeExpressionNode {
    public static ParseDelegateTypeExpression(lexer: Lexer): DelegateTypeExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));
        units.AddRange(lexer.GetPunctuation('=>'));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));

        return new DelegateTypeExpressionNode(units);
    }
}
