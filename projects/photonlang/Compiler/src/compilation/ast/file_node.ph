//@ts-nocheck
import { ASTNode } from './basic/ast_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';

export class FileNode extends ASTNode {
    public readonly path: string;

    constructor(path: string, units: LogicalCodeUnit[]) {
        super(units);
        this.path = path;
    }
}
