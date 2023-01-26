import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TokenType } from '../basic/token.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class ImportSpecifierNode extends CSTNode {
    public get identifier(): IdentifierExpressionNode {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public get name(): string {
        return this.identifier.name;
    }

    public get alias(): string | undefined {
        return CSTHelper.GetNthTokenByType(this, 1, TokenType.IDENTIFIER)?.value;
    }

    public static ParseImportSpecifier(lexer: Lexer): ImportSpecifierNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsKeyword(Keywords.AS)) {
            units.AddRange(lexer.GetPunctuation('as'));
            units.AddRange(lexer.GetIdentifier());
        }

        return new ImportSpecifierNode(units);
    }
}
