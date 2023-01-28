import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { CSTHelper } from '../cst_helper.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { CallExpressionNode } from '../expressions/call_expression_node.ph';

export class AttributeDeclarationNode extends CSTNode {
    public get name(): string {
        return (CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this) ?? CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this.arguments)).name;
    }

    public get arguments(): CallExpressionNode {
        return CSTHelper.GetFirstChildByType<CallExpressionNode>(this);
    }

    public static ParseAttributeDeclaration(lexer: Lexer): AttributeDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        const identifier = IdentifierExpressionNode.ParseIdentifierExpression(lexer);
        if (lexer.IsPunctuation('(') || lexer.IsPunctuation('<')) {
            units.Add(CallExpressionNode.ParseCallExpression(lexer, identifier));
        } else {
            units.Add(identifier);
        }

        return new AttributeDeclarationNode(units);
    }
}
