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

    public GetText(): string {
        return this.value;
    }

    public GetLine(): int {
        return 0;
    }

    public GetColumn(): int {
        return 0;
    }

    public GetLength(): int {
        return this.value.Length;
    }
    public GetEndLine(): int {
        return 0;
    }
    public GetEndColumn(): int {
        return 0;
    }
}
