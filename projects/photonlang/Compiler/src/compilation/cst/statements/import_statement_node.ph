import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { ImportSpecifierNode } from '../other/import_specifier_node.ph';
import { StatementNode } from './statement.ph';
import { Exception } from 'System';
import { StringLiteralNode } from '../expressions/string_literal_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import 'System/Linq';

export class ImportStatementNode extends StatementNode {
    public get importPath(): string {
        return CSTHelper.GetFirstChildByType<StringLiteralNode>(this).unquotedValue;
    }

    public get importSpecifiers(): Collections.IEnumerable<ImportSpecifierNode> {
        return CSTHelper.GetChildrenByType<ImportSpecifierNode>(this);
    }

    public get namespaceImport(): string | undefined {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this)?.name;
    }

    public get isAmbient(): bool {
        return this.namespaceImport == null && this.importSpecifiers.Count() == 0;
    }

    public static ParseImportStatement(lexer: Lexer): ImportStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.IMPORT));

        if (lexer.IsPunctuation('{')) {
            units.AddRange(lexer.GetPunctuation('{'));
            while (!lexer.IsPunctuation('}')) {
                units.Add(ImportSpecifierNode.ParseImportSpecifier(lexer));
                if (lexer.IsPunctuation(',')) {
                    units.AddRange(lexer.GetPunctuation(','));
                } else if (!lexer.IsPunctuation('}')) {
                    throw new Exception("Expected ',' or '}'");
                }
            }

            units.AddRange(lexer.GetPunctuation('}'));
            units.AddRange(lexer.GetKeyword(Keywords.FROM));
        } else if (lexer.IsIdentifier()) {
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
            units.AddRange(lexer.GetKeyword(Keywords.FROM));
        }

        units.Add(StringLiteralNode.ParseStringLiteral(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new ImportStatementNode(units);
    }
}
