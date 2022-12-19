import { FileNode } from '../file_node.ph';
import { CSTNode } from './cst_node.ph';

export abstract class LogicalCodeUnit {
    public root: FileNode;
    public parent: CSTNode;

    public GetFile(): string {
        return this.root.path;
    }

    public abstract GetText(): string;
    public abstract GetLine(): int;
    public abstract GetColumn(): int;
    public abstract GetLength(): int;
    public abstract GetEndLine(): int;
    public abstract GetEndColumn(): int;
}
