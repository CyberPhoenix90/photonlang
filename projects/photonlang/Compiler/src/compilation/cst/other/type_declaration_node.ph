import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';

export class TypeDeclarationNode extends CSTNode {
    public static ParseTypeDeclaration(lexer: Lexer): TypeDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetPunctuation(':'));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));

        return new TypeDeclarationNode(units);
    }
}
