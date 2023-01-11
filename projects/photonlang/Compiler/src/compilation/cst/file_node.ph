import Collections from 'System/Collections/Generic';
import { AnalyzedProject } from '../../static_analysis/analyzed_project.ph';
import { Lexer } from '../parsing/lexer.ph';
import { CSTHelper } from './cst_helper.ph';
import { CSTNode } from './basic/cst_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { StatementNode } from './statements/statement.ph';
import { ClassNode } from './statements/class_node.ph';
import { EnumNode } from './statements/enum_node.ph';
import { Exception, AggregateException } from 'System';

export class FileNode extends CSTNode {
    public readonly path: string;

    public get Statements(): Collections.IEnumerable<StatementNode> {
        return CSTHelper.GetChildrenByType<StatementNode>(this);
    }

    constructor(path: string, units: Collections.List<LogicalCodeUnit>) {
        super(units);
        this.path = path;
    }

    public static ParseFile(lexer: Lexer, project: AnalyzedProject): FileNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if(!lexer.filePath.StartsWith(project.project.projectPath)) {
            throw new Exception("Included file outside of project");
        }

        let path =  lexer.filePath.Substring(project.project.projectPath.Length);
        if (path.StartsWith("/"))
        {
            path = path.Substring(1);
        }

        const fileNode = new FileNode(path, units);

        let error: Exception = null;
        try {
            while (!lexer.Eof()) {
                const statement = StatementNode.ParseStatement(lexer);
                units.Add(statement);
            }
        } catch (e: Exception) {
            error = e;
        }

        CSTHelper.IterateChildrenRecursive(
            fileNode,
            (node: LogicalCodeUnit, parent: CSTNode, index: int) => {
                node.parent = parent;
                node.root = fileNode;

                if (node instanceof ClassNode) {
                    project.AddClassDeclaration(node);
                } else if (node instanceof EnumNode) {
                    project.AddEnumDeclaration(node);
                }
            },
            false,
        );

        project.logger.Verbose(fileNode.ToTreeString());

        if (error != null) {
            throw new AggregateException(error);
        }

        return fileNode;
    }
}
