import { StatementNode } from './statement.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';

export class TypeAliasStatementNode extends StatementNode {
    public static ParseTypeAliasStatement(lexer: Lexer): TypeAliasStatementNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword(Keywords.EXPORT)) {
            units.AddRange(lexer.GetKeyword(Keywords.EXPORT));
        }

        units.AddRange(lexer.GetKeyword('type'));
        units.AddRange(lexer.GetIdentifier());
        units.AddRange(lexer.GetPunctuation('='));
        units.Add(TypeExpressionNode.ParseTypeExpression(lexer));
        units.AddRange(lexer.GetPunctuation(';'));

        return new TypeAliasStatementNode(units);
    }
}
