//@ts-nocheck

import { LogicalCodeUnit } from './logical_code_unit.ph';
import 'System/Linq';
import { Exception } from 'System';
import Collections from 'System/Collections/Generic';
import { StringBuilder } from 'System/Text';

export class ASTNode extends LogicalCodeUnit {
    public readonly children: Collections.List<LogicalCodeUnit>;

    constructor(children: Collections.List<LogicalCodeUnit>) {
        this.children = children;
    }

    public getText(): string {
        if (this.children.Contains(this)) {
            throw new Exception('Circular reference detected');
        }
        return string.Join(
            '',
            this.children.Select((c: LogicalCodeUnit) => c.getText()),
        );
    }

    public ToTreeString(): string {
        const sb = new StringBuilder();
        const knownNodes = new Collections.HashSet<LogicalCodeUnit>();
        sb.AppendLine(`[${ToString()}]`);
        this.PrintAsTree(sb, '  ', knownNodes);

        return sb.ToString();
    }

    private PrintAsTree(sb: StringBuilder, prefix: string, knownNodes: HashSet<LogicalCodeUnit>): void {
        for (const child of children) {
            const isLastChild = child == children.Last();
            if (knownNodes.Contains(child)) {
                sb.AppendLine(
                    `${prefix}${isLastChild ? '└╴' : '├╴'}${(ASTNode.GetTokenText(child) + '[Circular]')
                        .Replace('\n', '\\n')
                        .Replace('\r', '\\r')
                        .Replace('\t', '\\t')
                        .Replace(' ', '\u001b[32m█\u001b[0m')}`,
                );
            } else {
                knownNodes.Add(child);
                if (child instanceof ASTNode) {
                    sb.AppendLine(`${prefix}${isLastChild ? '└╴' : '├╴'}[${node.GetType().ToString()}] ${child.Trivia}`);
                    node.PrintAsTree(sb, `${prefix}${isLastChild ? '  ' : '│ '}`, knownNodes);
                } else {
                    sb.AppendLine(
                        `${prefix}${isLastChild ? '└╴' : '├╴'}${ASTNode.GetTokenText(child)
                            .Replace('\n', '\\n')
                            .Replace('\r', '\\r')
                            .Replace('\t', '\\t')
                            .Replace(' ', '\u001b[32m█\u001b[0m')}`,
                    );
                }
            }
        }
    }

    private static GetTokenText(child: LogicalCodeUnit): string {
        return child?.Text ?? '\u001b[33mNULL\u001b[0m';
    }

    public getLine(): int {
        if (this.children.Length == 0) {
            return -1;
        }

        return this.children[0].getLine();
    }
    public getColumn(): int {
        if (this.children.Length == 0) {
            return -1;
        }

        return this.children[0].getColumn();
    }
    public getLength(): int {
        return this.children.Sum((c: LogicalCodeUnit) => c.getLength());
    }
    public getEndLine(): int {
        if (this.children.Length == 0) {
            return -1;
        }

        return this.children[this.children.Length - 1].getEndLine();
    }
    public getEndColumn(): int {
        if (this.children.Length == 0) {
            return -1;
        }

        return this.children[this.children.Length - 1].getEndColumn();
    }
}
