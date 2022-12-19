import Collections from 'System/Collections/Generic';
import { ASTNode } from '../compilation/ast/basic/ast_node.ph';
import { FileNode } from '../compilation/ast/file_node.ph';
import { ClassNode } from '../compilation/ast/statements/class_node.ph';

export class NamespaceModel {
    public readonly scopes: Collections.List<string>;

    constructor(scopes: Collections.List<string>) {
        this.scopes = scopes;
    }

    public static ParseNamespace(ns: string): NamespaceModel {
        return new NamespaceModel(new Collections.List<string>(ns.Split('.'[0])));
    }

    public static fromFile(file: string): NamespaceModel {
        const path = new Collections.List<string>(file.Split('/'[0]));
        const fileName = path[path.Count - 1];
        const fileNameWithoutExtension = fileName.Split('.'[0])[0];
        path.RemoveAt(path.Count - 1);
        path.Add(fileNameWithoutExtension);

        return new NamespaceModel(path);
    }

    public static fromAST(ast: ASTNode): NamespaceModel {
        const filePath = ast.root.path;
        const ns = NamespaceModel.fromFile(filePath);
        const rest = new Collections.List<string>();

        let ptr = ast;
        while (!(ptr instanceof FileNode)) {
            if (ptr instanceof ClassNode) {
                rest.Add(ptr.name);
            }

            ptr = ptr.parent;
        }

        rest.Reverse();
        ns.scopes.AddRange(rest);

        return ns;
    }
}
