//@ts-nocheck

import { LogicalCodeUnit } from './logical_code_unit.ph';
import 'System/Linq';
import { Exception } from 'System';
import Collections from 'System/Collections/Generic';

export class ASTNode extends LogicalCodeUnit {
    protected readonly units: Collections.List<LogicalCodeUnit>;

    constructor(units: Collections.List<LogicalCodeUnit>) {
        this.units = units;
    }

    public getText(): string {
        if (this.units.Contains(this)) {
            throw new Exception('Circular reference detected');
        }
        return string.Join(
            '',
            this.units.Select((c: LogicalCodeUnit) => c.getText()),
        );
    }

    public getLine(): int {
        return 0;
    }
    public getColumn(): int {
        return 0;
    }
    public getLength(): int {
        return 0;
    }
    public getEndLine(): int {
        return 0;
    }
    public getEndColumn(): int {
        return 0;
    }
}
