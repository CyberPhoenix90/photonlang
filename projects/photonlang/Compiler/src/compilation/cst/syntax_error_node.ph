import { CSTNode } from './basic/cst_node.ph';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { Environment, StringSplitOptions } from 'System';
import 'System/Linq';
import Collections from 'System/Collections/Generic';

export class SyntaxErrorNode extends CSTNode {
    public readonly message: string;
    public readonly stackTrace: string;

    constructor(message: string, units: Collections.List<LogicalCodeUnit>) {
        super(units);
        this.message = message;
        this.stackTrace = Environment.StackTrace.Split(<string>[Environment.NewLine], StringSplitOptions.None)
            .Skip(2)
            .Aggregate((a, b) => a + Environment.NewLine + b);
    }
}
