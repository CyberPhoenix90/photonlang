import Collections from 'System/Collections/Generic';
import { ParsedProject } from '../../project_management/parsed_project.ph';
import { Lexer } from '../parsing/lexer.ph';
import { CSTHelper } from './cst_helper.ph';
import { CSTNode } from './basic/cst_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { StatementNode } from './statements/statement.ph';
import { ClassNode } from './statements/class_node.ph';
import { EnumNode } from './statements/enum_node.ph';
import { Exception, AggregateException } from 'System';
import { StructNode } from './statements/struct_node.ph';
import { ImportStatementNode } from './statements/import_statement_node.ph';
import { TypeAliasStatementNode } from './statements/type_alias_statement_node.ph';

export class FileNode extends CSTNode {
    public readonly path: string;

    public get classes(): Collections.IEnumerable<ClassNode> {
        return CSTHelper.GetChildrenByType<ClassNode>(this);
    }

    public get enums(): Collections.IEnumerable<EnumNode> {
        return CSTHelper.GetChildrenByType<EnumNode>(this);
    }

    public get structs(): Collections.IEnumerable<StructNode> {
        return CSTHelper.GetChildrenByType<StructNode>(this);
    }

    public get imports(): Collections.IEnumerable<ImportStatementNode> {
        return CSTHelper.GetChildrenByType<ImportStatementNode>(this);
    }

    public get typeAliases(): Collections.IEnumerable<TypeAliasStatementNode> {
        return CSTHelper.GetChildrenByType<TypeAliasStatementNode>(this);
    }

    public get statements(): Collections.IEnumerable<StatementNode> {
        return CSTHelper.GetChildrenByType<StatementNode>(this);
    }

    constructor(path: string, units: Collections.List<LogicalCodeUnit>) {
        super(units);
        this.path = path;
    }

    public static ParseFile(lexer: Lexer, project: ParsedProject): FileNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (!lexer.filePath.StartsWith(project.settings.projectPath)) {
            throw new Exception('Included file outside of project');
        }

        let path = lexer.filePath.Substring(project.settings.projectPath.Length);
        if (path.StartsWith('/')) {
            path = path.Substring(1);
        }

        const fileNode = new FileNode(path, units);
        lexer.SetCurrentFile(fileNode);
        lexer.Process();

        let error: Exception = null;
        try {
            while (!lexer.Eof()) {
                const statement = StatementNode.ParseStatement(lexer, true);
                units.Add(statement);
            }
        } catch (e: Exception) {
            error = e;
        }
        lexer.SetCurrentFile(null);

        CSTHelper.IterateChildrenRecursive(
            fileNode,
            (node: LogicalCodeUnit, parent: CSTNode, index: int) => {
                node.parent = parent;
                node.root = fileNode;
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
