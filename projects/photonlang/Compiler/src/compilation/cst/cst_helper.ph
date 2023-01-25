import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { CSTNode } from './basic/cst_node.ph';
import { Token, TokenType } from './basic/token.ph';

export type CSTIteration = (unit: LogicalCodeUnit, parent: CSTNode, index: int) => void;
export type TokenIteration = (unit: Token, node: CSTNode, index: int) => bool;

export class CSTHelper {
    public static IterateChildrenRecursive(root: LogicalCodeUnit, skipNonCodingTokens: bool = true): Collections.IEnumerable<LogicalCodeUnit> {
        if (root instanceof CSTNode) {
            for (const child of root.children) {
                if (child instanceof Token) {
                    if (skipNonCodingTokens && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                        continue;
                    }
                }
                yield child;
                for (const grandChild of CSTHelper.IterateChildrenRecursive(child, skipNonCodingTokens)) {
                    yield grandChild;
                }
            }
        }
    }

    public static IterateChildrenRecursive(root: LogicalCodeUnit, action: CSTIteration, skipNonCodingTokens: bool = true): void {
        if (root instanceof CSTNode) {
            let i = 0;
            for (const child of root.children) {
                if (child instanceof Token) {
                    if (skipNonCodingTokens && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                        i++;
                        continue;
                    }
                }

                action(child, root, i);
                CSTHelper.IterateChildrenRecursive(child, action, skipNonCodingTokens);
                i++;
            }
        }
    }

    public static IterateLeavesRecursive(root: LogicalCodeUnit, action: TokenIteration, skipNonCodingTokens: bool = true): bool {
        if (root instanceof CSTNode) {
            let i = 0;
            for (const child of root.children) {
                if (child instanceof Token) {
                    if (skipNonCodingTokens && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                        i++;
                        continue;
                    }
                    const result = action(child, root, i);
                    if (result == false) {
                        return false;
                    }
                } else {
                    const result = CSTHelper.IterateLeavesRecursive(child, action, skipNonCodingTokens);
                    if (result == false) {
                        return false;
                    }
                }
                i++;
            }
        }

        return true;
    }

    public static IterateChildren(parent: CSTNode, skipNonCodingTokens: bool = true): Collections.IEnumerable<LogicalCodeUnit> {
        for (const child of parent.children) {
            if (child instanceof Token) {
                if (skipNonCodingTokens && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                    continue;
                }
            }
            yield child;
        }
    }

    public static IterateChildren(parent: CSTNode, action: CSTIteration, skipNonCodingTokens: bool = true): void {
        let i = 0;
        for (const child of parent.children) {
            if (child instanceof Token) {
                if (skipNonCodingTokens && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                    i++;
                    continue;
                }
            }

            action(child, parent, i);
            i++;
        }
    }

    public static IterateChildrenReverse(startNode: LogicalCodeUnit): Collections.IEnumerable<CSTNode> {
        if (startNode.parent == null) {
            return;
        }
        const startIndex = startNode.parent.children.IndexOf(startNode) - 1;

        for (let i = startIndex; i >= 0; i--) {
            const child = startNode.parent.children[i];
            if (child instanceof CSTNode) {
                yield child;
            }
        }

        CSTHelper.IterateChildrenReverse(startNode.parent);
    }

    public static GetFirstCodingChild(parent: CSTNode): LogicalCodeUnit {
        for (const child of parent.children) {
            if (child instanceof Token) {
                if (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT) {
                    continue;
                }
            }

            return child;
        }

        return null;
    }

    public static GetFirstCodingToken(parent: CSTNode): Token {
        for (const child of parent.children) {
            if (child instanceof Token) {
                if (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT) {
                    continue;
                }
                return child;
            }
        }

        return null;
    }

    public static GetChildrenByType<T extends CSTNode>(parent: CSTNode): Collections.IEnumerable<T> {
        for (const child of parent.children) {
            if (child instanceof T) {
                yield child;
            }
        }
    }

    public static GetFirstChildByType<T extends CSTNode>(parent: CSTNode): T | undefined {
        return CSTHelper.GetNthChildByType<T>(parent, 0);
    }

    public static GetLastChildByType<T extends CSTNode>(parent: CSTNode): T | undefined {
        let result: T = null;
        for (const child of parent.children) {
            if (child instanceof T) {
                result = child;
            }
        }

        return result;
    }

    public static GetNthChildByType<T extends CSTNode>(parent: CSTNode, n: int): T | undefined {
        let i = 0;
        for (const child of parent.children) {
            if (child instanceof T) {
                if (i++ == n) {
                    return child;
                }
            }
        }

        return null;
    }

    public static GetFirstTokenByType(parent: CSTNode, type: TokenType, value?: string): Token | undefined {
        return CSTHelper.GetNthTokenByType(parent, 0, type, value);
    }

    public static GetNthTokenByType(parent: CSTNode, n: int, type: TokenType, value?: string): Token | undefined {
        let i = 0;
        for (const child of parent.children) {
            if (child instanceof Token) {
                if (child.type == type && (value == null || child.value == value)) {
                    if (i++ == n) {
                        return child;
                    }
                }
            }
        }

        return null;
    }

    public static FindIn<T extends CSTNode>(statement: CSTNode): T | null {
        for (const child of IterateChildrenRecursive(statement)) {
            if (child instanceof T) {
                return child;
            }
        }

        return null;
    }
}
