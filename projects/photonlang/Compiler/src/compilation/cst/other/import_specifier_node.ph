import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../project_management/keywords.ph';
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

    public get alias(): IdentifierExpressionNode | undefined {
        return CSTHelper.GetNthChildByType<IdentifierExpressionNode>(this, 1);
    }

    public static ParseImportSpecifier(lexer: Lexer): ImportSpecifierNode {
        const units = new Collections.List<LogicalCodeUnit>();
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        if (lexer.IsKeyword(Keywords.AS)) {
            units.AddRange(lexer.GetKeyword(Keywords.AS));
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        }

        return new ImportSpecifierNode(units);
    }
}
