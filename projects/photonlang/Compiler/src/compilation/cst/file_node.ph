import Collections from 'System/Collections/Generic';
import { AnalyzedProject } from '../../static_analysis/analyzed_project.ph';
import { Lexer } from '../parsing/lexer.ph';
import { CSTHelper } from './cst_helper.ph';
import { CSTNode } from './basic/cst_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { StatementNode } from './statements/statement.ph';

export class FileNode extends CSTNode {
    public readonly path: string;

    constructor(path: string, units: Collections.List<LogicalCodeUnit>) {
        super(units);
        this.path = path;
    }

    public static ParseFile(lexer: Lexer, project: AnalyzedProject): FileNode {
        const units = new Collections.List<LogicalCodeUnit>();
        const fileNode = new FileNode(lexer.filePath, units);

        while (!lexer.Eof()) {
            const statement = StatementNode.ParseStatement(lexer, project);
            units.Add(statement);
        }

        CSTHelper.IterateChildrenRecursive(
            fileNode,
            (node: LogicalCodeUnit, parent: CSTNode, index: int) => {
                node.parent = parent;
            },
            false,
        );

        project.logger.Verbose(fileNode.ToTreeString());

        return fileNode;
    }
}
