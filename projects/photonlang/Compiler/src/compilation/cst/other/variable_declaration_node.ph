import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class VariableDeclarationNode extends CSTNode {
    public static ParseVariableDeclaration(lexer: Lexer): VariableDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetIdentifier());
        if (lexer.IsPunctuation(':')) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }
        if (lexer.IsPunctuation('=')) {
            units.AddRange(lexer.GetPunctuation('='));
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        return new VariableDeclarationNode(units);
    }
}
