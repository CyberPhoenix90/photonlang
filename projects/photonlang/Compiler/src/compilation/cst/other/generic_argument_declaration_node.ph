import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';

export class GenericArgumentDeclarationNode extends CSTNode {
    public static ParseGenericArgumentDeclaration(lexer: Lexer): GenericArgumentDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetIdentifier());
        if (lexer.IsKeyword(Keywords.EXTENDS)) {
            units.AddRange(lexer.GetKeyword(Keywords.EXTENDS));
            units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        }

        return new GenericArgumentDeclarationNode(units);
    }
}
