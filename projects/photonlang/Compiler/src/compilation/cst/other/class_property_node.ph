import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class ClassPropertyNode extends CSTNode {
    public static ParseClassProperty(lexer: Lexer): ClassPropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();
        return new ClassPropertyNode(units);
    }
}
