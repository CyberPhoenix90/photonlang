import { ExpressionNode } from './expression_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../project_management/keywords.ph';

export class NullLiteralNode extends ExpressionNode {
    public static ParseNullLiteral(lexer: Lexer): NullLiteralNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.NULL));
        return new NullLiteralNode(units);
    }
}
