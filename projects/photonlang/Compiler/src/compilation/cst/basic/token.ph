import { CSTHelper } from '../cst_helper.ph';
import { CSTNode } from './cst_node.ph';
import { LogicalCodeUnit } from './logical_code_unit.ph';
import 'System/Linq';
import { FileNode } from '../file_node.ph';

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

    constructor(type: TokenType, value: string, root?: FileNode) {
        super();
        this.type = type;
        this.value = value;
        this.root = root;
    }

    public GetText(): string {
        return this.value;
    }

    public GetLine(): int {
        let line = 0;
        CSTHelper.IterateLeavesRecursive(
            this.root,
            (unit: Token, node: CSTNode, index: int) => {
                if (unit.value.Contains('\n')) {
                    line++;
                }

                if (unit == this) {
                    return false;
                }

                return true;
            },
            false,
        );
        return line;
    }

    public GetColumn(): int {
        let column = 0;
        CSTHelper.IterateLeavesRecursive(
            this.root,
            (unit: Token, node: CSTNode, index: int) => {
                if (unit.value.Contains('\n')) {
                    column = unit.value.Length - unit.value.LastIndexOf('\n');
                } else {
                    column += unit.value.Length;
                }

                if (unit == this) {
                    return false;
                }

                return true;
            },
            false,
        );
        return column;
    }

    public GetLength(): int {
        return this.value.Length;
    }
    public GetEndLine(): int {
        return this.GetLine() + this.value.Count((c) => c == '\n'[0]);
    }
    public GetEndColumn(): int {
        if (this.value.Contains('\n')) {
            return this.GetColumn() + this.value.Length - this.value.LastIndexOf('\n');
        } else {
            return this.GetColumn() + this.value.Length;
        }
    }
}
