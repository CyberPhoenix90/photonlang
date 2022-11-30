//@ts-nocheck

import { FileNode } from '../file_node.ph';

export abstract class LogicalCodeUnit {
    public root: FileNode;
    public parent: LogicalCodeUnit;

    public getFile(): string {
        return this.root.path;
    }

    public abstract getText(): string;
    public abstract getLine(): int;
    public abstract getColumn(): int;
    public abstract getLength(): int;
    public abstract getEndLine(): int;
    public abstract getEndColumn(): int;
}
