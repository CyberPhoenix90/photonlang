import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { VariableDeclarationNode } from './variable_declaration_node.ph';

export class VariableDeclarationListNode extends CSTNode {
    public static ParseVariableDeclarationList(lexer: Lexer): VariableDeclarationListNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(VariableDeclarationNode.ParseVariableDeclaration(lexer));
        while (lexer.IsPunctuation(',')) {
            units.AddRange(lexer.GetPunctuation(','));
            units.Add(VariableDeclarationNode.ParseVariableDeclaration(lexer));
        }

        return new VariableDeclarationListNode(units);
    }
}
