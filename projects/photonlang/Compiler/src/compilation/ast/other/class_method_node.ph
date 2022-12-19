import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ASTNode } from '../basic/ast_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class ClassMethodNode extends ASTNode {
    public static ParseClassMethod(lexer: Lexer, project: AnalyzedProject): ClassMethodNode {
        const units = new Collections.List<LogicalCodeUnit>();
        return new ClassMethodNode(units);
    }
}
