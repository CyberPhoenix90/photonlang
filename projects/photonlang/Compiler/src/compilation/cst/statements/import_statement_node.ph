import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/analyzed_project.ph';
import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { ImportSpecifierNode } from '../other/import_specifier_node.ph';
import { StatementNode } from './statement.ph';
import { Exception } from 'System';

export class ImportStatementNode extends StatementNode {
    public get importPath(): string {
        return CSTHelper.GetFirstTokenByType(this, TokenType.STRING).value;
    }

    public get importSpecifiers(): Collections.IEnumerable<ImportSpecifierNode> {
        return CSTHelper.GetChildrenByType<ImportSpecifierNode>(this);
    }

    public get namespaceImport(): string | undefined {
        return CSTHelper.GetFirstTokenByType(this, TokenType.IDENTIFIER)?.value;
    }

    public static ParseImportStatement(lexer: Lexer, project: AnalyzedProject): ImportStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetKeyword(Keywords.IMPORT));

        if (lexer.IsPunctuation('{')) {
            units.AddRange(lexer.GetPunctuation('{'));
            while (!lexer.IsPunctuation('}')) {
                units.Add(ImportSpecifierNode.ParseImportSpecifier(lexer, project));
                if (lexer.IsPunctuation(',')) {
                    units.AddRange(lexer.GetPunctuation(','));
                } else if (!lexer.IsPunctuation('}')) {
                    throw new Exception("Expected ',' or '}'");
                }
            }

            units.AddRange(lexer.GetPunctuation('}'));
            units.AddRange(lexer.GetKeyword(Keywords.FROM));
        } else if (lexer.IsIdentifier()) {
            units.AddRange(lexer.GetIdentifier());
            units.AddRange(lexer.GetKeyword(Keywords.FROM));
        }

        units.AddRange(lexer.GetString());
        units.AddRange(lexer.GetPunctuation(';'));

        return new ImportStatementNode(units);
    }
}
