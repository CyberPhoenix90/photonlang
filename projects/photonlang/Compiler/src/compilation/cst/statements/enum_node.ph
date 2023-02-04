import { TokenType } from '../basic/token.ph';
import { CSTHelper } from '../cst_helper.ph';
import { StatementNode } from './statement.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Keywords } from '../../../project_management/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { Exception } from 'System';
import { EnumMemberNode } from '../other/enum_member_node.ph';

export class EnumNode extends StatementNode {
    public get name(): string {
        return CSTHelper.GetFirstTokenByType(this, TokenType.IDENTIFIER).value;
    }

    public get members(): Collections.IEnumerable<EnumMemberNode> {
        return CSTHelper.GetChildrenByType<EnumMemberNode>(this);
    }

    public get isExported(): bool {
        return CSTHelper.GetFirstTokenByType(this, TokenType.KEYWORD) != null;
    }

    public static ParseEnum(lexer: Lexer): EnumNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsKeyword('export')) {
            units.AddRange(lexer.GetKeyword());
        }

        units.AddRange(lexer.GetKeyword(Keywords.ENUM));
        units.AddRange(lexer.GetIdentifier());
        units.AddRange(lexer.GetPunctuation('{'));
        while (!lexer.IsPunctuation('}')) {
            units.Add(EnumMemberNode.ParseEnumMember(lexer));
            if (lexer.IsPunctuation(',')) {
                units.AddRange(lexer.GetPunctuation(','));
            } else if (!lexer.IsPunctuation('}')) {
                throw new Exception("Expected ',' or '}'");
            }
        }

        units.AddRange(lexer.GetPunctuation('}'));

        const enumDeclaration = new EnumNode(units);

        return enumDeclaration;
    }
}
