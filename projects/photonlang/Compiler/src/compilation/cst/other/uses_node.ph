import { CSTNode } from "../basic/cst_node.ph";
import { CSTHelper } from "../cst_helper.ph";
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from "../../../static_analysis/keywords.ph";
import { IdentifierExpressionNode } from "../expressions/identifier_expression_node.ph";

export class UsesNode extends CSTNode {
    public get identifiers(): Collections.IEnumerable<IdentifierExpressionNode> {
        return CSTHelper.GetChildrenByType<IdentifierExpressionNode>(this);
    }

    public static ParseUses(lexer: Lexer): UsesNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.USES));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        while (lexer.IsPunctuation(',')) {
            units.AddRange(lexer.GetPunctuation(','));
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        }

        return new UsesNode(units);
    }
}