import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../static_analysis/analyzed_project.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';

export class ImportSpecifierNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetNthTokenByType(this, 0, TokenType.IDENTIFIER).value;
    }

    public get alias(): string | undefined {
        return CSTHelper.GetNthTokenByType(this, 1, TokenType.IDENTIFIER)?.value;
    }

    public static ParseImportSpecifier(lexer: Lexer, project: AnalyzedProject): ImportSpecifierNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.AddRange(lexer.GetIdentifier());
        if (lexer.IsKeyword(Keywords.AS)) {
            units.AddRange(lexer.GetPunctuation('as'));
            units.AddRange(lexer.GetIdentifier());
        }

        return new ImportSpecifierNode(units);
    }
}
