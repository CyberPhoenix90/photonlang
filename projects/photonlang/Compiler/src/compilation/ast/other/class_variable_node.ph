import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ASTNode } from '../basic/ast_node.ph';

export class ClassVariableNode extends ASTNode {
    public static ParseClassVariable(lexer: Lexer, project: AnalyzedProject): ClassVariableNode {
        return new ClassVariableNode();
    }
}
