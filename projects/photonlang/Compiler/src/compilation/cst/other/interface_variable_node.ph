import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { AttributeNode } from './attribute_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class InterfaceVariableNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get type(): TypeDeclarationNode {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get attributes(): Collections.IEnumerable<AttributeNode> {
        return CSTHelper.GetChildrenByType<AttributeNode>(this);
    }

    public static ParseInterfaceVariable(lexer: Lexer, attributes: Collections.List<AttributeNode>): InterfaceVariableNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(attributes);
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new InterfaceVariableNode(units);
    }
}
