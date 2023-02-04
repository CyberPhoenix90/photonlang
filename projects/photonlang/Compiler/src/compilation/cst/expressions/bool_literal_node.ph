import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../project_management/keywords.ph';

export class BoolLiteralNode extends ExpressionNode {
    public static ParseBoolLiteral(lexer: Lexer): BoolLiteralNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.TRUE, Keywords.FALSE]));
        return new BoolLiteralNode(units);
    }
}
