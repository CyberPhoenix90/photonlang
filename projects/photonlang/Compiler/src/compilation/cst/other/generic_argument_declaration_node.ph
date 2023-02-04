import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class GenericArgumentDeclarationNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get constraint(): TypeExpressionNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeExpressionNode>(this);
    }

    public static ParseGenericArgumentDeclaration(lexer: Lexer): GenericArgumentDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsKeyword(Keywords.EXTENDS)) {
            units.AddRange(lexer.GetKeyword(Keywords.EXTENDS));
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        }

        return new GenericArgumentDeclarationNode(units);
    }
}
