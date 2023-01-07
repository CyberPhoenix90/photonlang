import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class ClassVariableNode extends CSTNode {
    public static ParseClassVariable(lexer: Lexer): ClassVariableNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.STATIC)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.READONLY)) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetIdentifier());
        units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new ClassVariableNode(units);
    }
}
