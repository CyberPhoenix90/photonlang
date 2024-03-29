import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { FunctionArgumentDeclarationNode } from './function_argument_declaration_node.ph';

export class FunctionArgumentsDeclarationNode extends CSTNode {
    public get arguments(): Collections.IEnumerable<FunctionArgumentDeclarationNode> {
        return CSTHelper.GetChildrenByType<FunctionArgumentDeclarationNode>(this);
    }

    public static ParseFunctionArgumentsDeclaration(lexer: Lexer): FunctionArgumentsDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('('));
        while (!lexer.IsPunctuation(')')) {
            units.Add(FunctionArgumentDeclarationNode.ParseFunctionArgumentDeclaration(lexer));

            if (!lexer.IsPunctuation(')')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }

        units.AddRange(lexer.GetPunctuation(')'));

        return new FunctionArgumentsDeclarationNode(units);
    }
}
