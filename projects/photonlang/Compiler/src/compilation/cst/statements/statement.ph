import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { TokenType } from '../basic/token.ph';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { Token } from '../basic/token.ph';
import { Exception } from 'System';
import { ClassNode } from './class_node.ph';
import { ImportStatementNode } from './import_statement_node.ph';
import { EnumNode } from './enum_node.ph';

export class StatementNode extends CSTNode {
    constructor(units: Collections.List<LogicalCodeUnit>) {
        super(units);
    }

    public static ParseStatement(lexer: Lexer): LogicalCodeUnit {
        const relevantTokens = lexer.PeekRange(2);

        let mainToken: Token;
        let modifiers = new Collections.List<TokenType>();

        let ptr = 0;

        if (relevantTokens[ptr].type == TokenType.KEYWORD && relevantTokens[ptr].value == Keywords.EXPORT) {
            modifiers.Add(relevantTokens[ptr].type);
            ptr++;
        }

        if (relevantTokens[ptr].type == TokenType.KEYWORD && relevantTokens[ptr].value == Keywords.ABSTRACT) {
            modifiers.Add(relevantTokens[ptr].type);
            ptr++;
        }

        mainToken = relevantTokens[ptr];

        return match (mainToken) {
            { type: TokenType.KEYWORD, value: Keywords.CLASS } => ClassNode.ParseClass(lexer),
            { type: TokenType.KEYWORD, value: Keywords.ENUM } => EnumNode.ParseEnum(lexer),
            { type: TokenType.KEYWORD, value: Keywords.IMPORT } => ImportStatementNode.ParseImportStatement(lexer),
            // { type: TokenType.KEYWORD, value: Keywords.IMPORT } => ImportNode.ParseImport(lexer, project),
            // { type: TokenType.KEYWORD, value: Keywords.INTERFACE } => InterfaceNode.ParseInterface(lexer, project),
            default => throw new Exception(`Unknown statement type ${TokenType.GetKey(mainToken.type)} ${mainToken.value}`)
        };
    }
}
