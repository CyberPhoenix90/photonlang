import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class ClassVariableNode extends CSTNode {
    public static ParseClassVariable(lexer: Lexer): ClassVariableNode {
        const units = new Collections.List<LogicalCodeUnit>();
        return new ClassVariableNode(units);
    }
}
