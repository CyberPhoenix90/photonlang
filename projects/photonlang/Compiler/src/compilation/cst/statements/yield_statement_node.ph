import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { ExpressionNode } from '../expressions/expression_node.ph';

export class YieldStatementNode extends StatementNode {
    public static ParseYieldStatement(lexer: Lexer): YieldStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetKeyword(Keywords.YIELD));
        if (lexer.IsPunctuation(';') == false) {
            units.Add(ExpressionNode.ParseExpression(lexer));
        }
        units.AddRange(lexer.GetPunctuation(';'));

        return new YieldStatementNode(units);
    }
}
