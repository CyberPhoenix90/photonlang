import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class ClassMethodNode extends CSTNode {
    public static ParseClassMethod(lexer: Lexer): ClassMethodNode {
        const units = new Collections.List<LogicalCodeUnit>();
        return new ClassMethodNode(units);
    }
}
