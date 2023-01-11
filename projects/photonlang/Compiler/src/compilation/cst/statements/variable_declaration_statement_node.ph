import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { VariableDeclarationListNode } from '../other/variable_declaration_list_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class VariableDeclarationStatementNode extends StatementNode {

    public get declarationList(): VariableDeclarationListNode {
        return CSTHelper.GetFirstChildByType<VariableDeclarationListNode>(this);
    }

    public static ParseVariableDeclarationStatement(lexer: Lexer): VariableDeclarationStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.LET, Keywords.CONST]));
        units.Add(VariableDeclarationListNode.ParseVariableDeclarationList(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new VariableDeclarationStatementNode(units);
    }
}
