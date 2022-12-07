import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from './basic/logical_code_unit.ph';
import { ASTNode } from './basic/ast_node.ph';
import { Token, TokenType } from './basic/token.ph';

export type AstIteration = (unit: LogicalCodeUnit, node: ASTNode, index: int) => void;

export class ASTHelper {
    public static IterateChildrenRecursive(root: LogicalCodeUnit, skipNonCodingTokens: bool = true): Collections.IEnumerable<LogicalCodeUnit> {
        if (root instanceof ASTNode) {
            for (const child of root.children) {
                if (skipNonCodingTokens && child instanceof Token && (child.type == TokenType.WHITESPACE || child.type == TokenType.COMMENT)) {
                    continue;
                }
                yield child;
                for (const grandChild of ASTHelper.IterateChildrenRecursive(child, skipNonCodingTokens)) {
                    yield grandChild;
                }
            }
        }
    }

    public static IterateChildrenRecursive(root: LogicalCodeUnit, action: AstIteration, skipNonCodingTokens: bool = true): void {
        if (root instanceof ASTNode) {
            let i = 0;
            for (const child of root.children) {
                if (skipNonCodingTokens && child instanceof Token && (child.type == TokenType.WHITESPACE || child.Type == TokenType.COMMENT)) {
                    i++;
                    continue;
                }

                action(child, root, i);
                ASTHelper.IterateChildrenRecursive(child, action, skipNonCodingTokens);
                i++;
            }
        }
    }

    public static IterateChildren(parent: ASTNode, skipNonCodingTokens: bool = true): Collections.IEnumerable<LogicalCodeUnit> {
        for (const child of parent.children) {
            if (skipNonCodingTokens && child instanceof Token && (child.type == TokenType.WHITESPACE || child.Type == TokenType.COMMENT)) {
                continue;
            }
            yield child;
        }
    }

    public static IterateChildren(parent: ASTNode, action: AstIteration, skipNonCodingTokens: bool = true): void {
        let i = 0;
        for (const child of parent.children) {
            if (skipNonCodingTokens && child instanceof Token && (child.type == TokenType.WHITESPACE || child.Type == TokenType.COMMENT)) {
                i++;
                continue;
            }

            action(child, parent, i);
            i++;
        }
    }

    public static GetFirstCodingChild(parent: ASTNode): LogicalCodeUnit {
        for (const child of parent.children) {
            if (child instanceof Token && (child.type == TokenType.WHITESPACE || child.Type == TokenType.COMMENT)) {
                continue;
            }

            return child;
        }

        return null;
    }

    public static FindIn<T extends ASTNode>(statement: ASTNode): T | null {
        for (const child of IterateChildrenRecursive(statement)) {
            if (child instanceof T) {
                return child;
            }
        }

        return null;
    }
}
