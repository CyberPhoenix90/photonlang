import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ASTNode } from '../basic/ast_node.ph';

export class ClassMethodNode extends ASTNode {
    public static ParseClassMethod(lexer: Lexer, project: AnalyzedProject): ClassMethodNode {
        return new ClassMethodNode();
    }
}
