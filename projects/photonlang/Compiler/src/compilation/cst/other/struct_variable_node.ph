import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class StructVariableNode extends CSTNode {
    public static ParseStructVariable(lexer: Lexer): StructVariableNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetIdentifier());
        units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));

        if(lexer.IsPunctuation('=')) {
            units.AddRange(lexer.GetPunctuation('='));
            units.Add(ExpressionNode.ParseExpression(lexer));
        }

        units.AddRange(lexer.GetPunctuation(';'));

        return new StructVariableNode(units);
    }
}
