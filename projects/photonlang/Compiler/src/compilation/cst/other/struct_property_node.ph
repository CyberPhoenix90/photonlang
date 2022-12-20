import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class StructPropertyNode extends CSTNode {
    public static ParseStructProperty(lexer: Lexer): StructPropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();
        return new StructPropertyNode(units);
    }
}
