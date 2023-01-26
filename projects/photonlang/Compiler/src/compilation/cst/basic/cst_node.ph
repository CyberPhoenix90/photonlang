import { LogicalCodeUnit } from './logical_code_unit.ph';
import 'System/Linq';
import { Exception } from 'System';
import Collections from 'System/Collections/Generic';
import { StringBuilder } from 'System/Text';
import { Token } from './token.ph';
import { TokenType } from './token.ph';

export class CSTNode extends LogicalCodeUnit {
    public readonly children: Collections.List<LogicalCodeUnit>;

    constructor(children: Collections.List<LogicalCodeUnit>) {
        super();
        this.children = children;
    }

    public GetText(): string {
        if (this.children.Contains(this)) {
            throw new Exception('Circular reference detected');
        }
        return string.Join(
            '',
            this.children.Select((c: LogicalCodeUnit) => c.GetText()),
        );
    }

    public ToTreeString(): string {
        const sb = new StringBuilder();
        const knownNodes = new Collections.HashSet<LogicalCodeUnit>();
        sb.AppendLine(`[${this.ToString()}]`);
        this.PrintAsTree(sb, '  ', knownNodes);

        return sb.ToString();
    }

    public IsEquivalentTo(other: CSTNode): bool {
        if (other.GetType() != this.GetType()) {
            return false;
        }

        const thisChildren = this.children
            .Where((c) => c instanceof CSTNode || (c instanceof Token && (c as Token).type != TokenType.COMMENT && (c as Token).type != TokenType.WHITESPACE))
            .ToList();
        const otherChildren = other.children
            .Where((c) => c instanceof CSTNode || (c instanceof Token && (c as Token).type != TokenType.COMMENT && (c as Token).type != TokenType.WHITESPACE))
            .ToList();

        if (thisChildren.Count != otherChildren.Count) {
            return false;
        }

        for (let i = 0; i < thisChildren.Count; i++) {
            if (thisChildren[i] instanceof CSTNode && otherChildren[i] instanceof CSTNode) {
                if (!(thisChildren[i] as CSTNode).IsEquivalentTo(otherChildren[i] as CSTNode)) {
                    return false;
                }
            } else if (thisChildren[i] instanceof Token && otherChildren[i] instanceof Token) {
                if ((thisChildren[i] as Token).GetText() != (otherChildren[i] as Token).GetText()) {
                    return false;
                }
            } else {
                return false;
            }
        }

        return true;
    }

    private PrintAsTree(sb: StringBuilder, prefix: string, knownNodes: Collections.HashSet<LogicalCodeUnit>): void {
        for (const child of this.children) {
            const isLastChild = child == this.children.Last();
            const text = CSTNode.GetTokenText(child).Replace('\n', '\\n').Replace('\r', '\\r').Replace('\t', '\\t').Replace(' ', '\u001b[32m█\u001b[0m');
            if (knownNodes.Contains(child)) {
                sb.AppendLine(`${prefix}${isLastChild ? '└╴' : '├╴'}${text + '[Circular]'}`);
            } else {
                knownNodes.Add(child);
                if (child instanceof CSTNode) {
                    sb.AppendLine(`${prefix}${isLastChild ? '└╴' : '├╴'}[${child.GetType().ToString().Replace('PhotonCompiler.src.compilation.cst.', '')}]`);
                    child.PrintAsTree(sb, `${prefix}${isLastChild ? '  ' : '│ '}`, knownNodes);
                } else {
                    sb.AppendLine(`${prefix}${isLastChild ? '└╴' : '├╴'}${text}`);
                }
            }
        }
    }

    private static GetTokenText(child: LogicalCodeUnit): string {
        return child?.GetText() ?? '\u001b[33mNULL\u001b[0m';
    }

    public GetLine(): int {
        if (this.children.Count == 0) {
            return -1;
        }

        return this.children[0].GetLine();
    }
    public GetColumn(): int {
        if (this.children.Count == 0) {
            return -1;
        }

        return this.children[0].GetColumn();
    }
    public GetLength(): int {
        return this.children.Sum((c: LogicalCodeUnit) => c.GetLength());
    }
    public GetEndLine(): int {
        if (this.children.Count == 0) {
            return -1;
        }

        return this.children[this.children.Count - 1].GetEndLine();
    }
    public GetEndColumn(): int {
        if (this.children.Count == 0) {
            return -1;
        }

        return this.children[this.children.Count - 1].GetEndColumn();
    }
}
