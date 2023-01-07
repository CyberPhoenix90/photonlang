import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class FunctionArgumentsDeclarationNode extends CSTNode {
    public static ParseFunctionArgumentsDeclaration(lexer: Lexer): FunctionArgumentsDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('('));
        while (true) {
            if (lexer.IsPunctuation(')')) {
                break;
            }

            if (lexer.IsKeyword()) {
                units.AddRange(lexer.GetKeyword());
            } else {
                units.AddRange(lexer.GetIdentifier());
            }
            if (lexer.IsPunctuation('?')) {
                units.AddRange(lexer.GetPunctuation('?'));
            }
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));

            if (lexer.IsPunctuation('=')) {
                units.AddRange(lexer.GetPunctuation('='));
                units.Add(ExpressionNode.ParseExpression(lexer));
            }

            if (!lexer.IsPunctuation(')')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
        }

        units.AddRange(lexer.GetPunctuation(')'));

        return new FunctionArgumentsDeclarationNode(units);
    }
}
