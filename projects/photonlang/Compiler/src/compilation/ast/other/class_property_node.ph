import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { ASTNode } from '../basic/ast_node.ph';

export class ClassPropertyNode extends ASTNode {
    public static ParseClassProperty(lexer: Lexer, project: AnalyzedProject): ClassPropertyNode {
        return new ClassPropertyNode();
    }
}
