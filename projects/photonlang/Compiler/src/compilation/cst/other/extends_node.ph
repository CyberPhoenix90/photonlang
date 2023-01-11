import { CSTNode } from "../basic/cst_node.ph";
import { CSTHelper } from "../cst_helper.ph";
import { Lexer } from '../../parsing/lexer.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from "../../../static_analysis/keywords.ph";
import { IdentifierExpressionNode } from "../expressions/identifier_expression_node.ph";

export class ExtendsNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetFirstCodingToken(this).value;
    }

    public get identifier(): IdentifierExpressionNode {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this);
    }

    public static ParseExtends(lexer: Lexer): ExtendsNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.EXTENDS));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        return new ExtendsNode(units);
    }
}