import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { GenericArgumentDeclarationNode } from './generic_argument_declaration_node.ph';
import { CSTHelper } from '../cst_helper.ph';

export class GenericsDeclarationNode extends CSTNode {
    public get arguments(): Collections.IEnumerable<GenericArgumentDeclarationNode> {
        return CSTHelper.GetChildrenByType<GenericArgumentDeclarationNode>(this);
    }

    public static ParseGenericsDeclaration(lexer: Lexer): GenericsDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('<'));
        units.Add(GenericArgumentDeclarationNode.ParseGenericArgumentDeclaration(lexer));
        while (!lexer.IsPunctuation('>')) {
            if (!lexer.IsPunctuation('>')) {
                units.AddRange(lexer.GetPunctuation(','));
            }
            units.Add(GenericArgumentDeclarationNode.ParseGenericArgumentDeclaration(lexer));
        }

        units.AddRange(lexer.GetPunctuation('>'));

        return new GenericsDeclarationNode(units);
    }
}
