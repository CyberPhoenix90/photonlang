import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { CSTHelper } from '../cst_helper.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { AttributeDeclarationNode } from './attribute_declaration_node.ph';

export class AttributeNode extends CSTNode {
    public get attributes(): Collections.IEnumerable<AttributeDeclarationNode> {
        return CSTHelper.GetChildrenByType<AttributeDeclarationNode>(this);
    }

    public static ParseAttribute(lexer: Lexer): AttributeNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation('['));
        units.Add(AttributeDeclarationNode.ParseAttributeDeclaration(lexer));
        while (lexer.IsPunctuation(',')) {
            units.AddRange(lexer.GetPunctuation(','));
            units.Add(AttributeDeclarationNode.ParseAttributeDeclaration(lexer));
        }
        units.AddRange(lexer.GetPunctuation(']'));

        return new AttributeNode(units);
    }
}
