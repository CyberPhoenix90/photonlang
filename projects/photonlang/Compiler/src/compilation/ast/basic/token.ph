//@ts-nocheck
import { LogicalCodeUnit } from './logical_code_unit.ph';

export enum TokenType {
    PUNCTUATION,
    KEYWORD,
    IDENTIFIER,
    NUMBER,
    STRING,
    COMMENT,
    WHITESPACE,
    NEWLINE,
    EOF,
}

export class Token extends LogicalCodeUnit {
    public readonly type: TokenType;
    public readonly value: string;

    constructor(type: TokenType, value: string) {
        this.type = type;
        this.value = value;
    }

    public getText(): string {
        return this.value;
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
