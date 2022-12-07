import { AnalyzedProject } from '../../static_analysis/analyzed_project.ph';
import { Lexer } from '../parsing/lexer.ph';
import { ASTNode } from './basic/ast_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';

export class FileNode extends ASTNode {
    public readonly path: string;

    constructor(path: string, units: Collections.List<LogicalCodeUnit>) {
        super(units);
        this.path = path;
    }

    public static ParseFile(lexer: Lexer, project: AnalyzedProject): FileNode {
        const units = new Collections.List<LogicalCodeUnit>();
        const fileNode = new FileNode(lexer.filePath, units);

        ASTHelper.IterateChildrenRecursive(rootNode, (LogicalCodeUnit node, ASTNode parent, int index) =>
        {
            node.parent = parent;
            node.root = rootNode;
            if (node is SyntaxErrorNode)
            {
                syntaxErrors.Add(node as SyntaxErrorNode);
            }
        }, false);


        return fileNode;
    }
}
