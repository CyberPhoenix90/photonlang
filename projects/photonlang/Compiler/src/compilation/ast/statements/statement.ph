import { ASTNode } from '../basic/ast_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { AnalyzedProject } from '../../../static_analysis/analyzed_project.ph';
import { TokenType } from '../basic/token.ph';
import { Keywords } from '../../../static_analysis/analyzed_project.ph';
import { Token } from '../basic/token.ph';
import { Exception } from 'System';

export class StatementNode extends ASTNode {
    constructor(units: Collections.List<LogicalCodeUnit>) {
        super(units);
    }

    public static ParseStatement(lexer: Lexer, project: AnalyzedProject): LogicalCodeUnit {
        const units = new Collections.List<LogicalCodeUnit>();
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

        match (mainToken) {
            case { type: TokenType.KEYWORD, value: Keywords.CLASS } => {
                return ClassNode.ParseClass(lexer, project, modifiers);
            },
            case { type: TokenType.KEYWORD, value: Keywords.FUNCTION } => {
                return FunctionNode.ParseFunction(lexer, project, modifiers);
            },
            case { type: TokenType.KEYWORD, value: Keywords.IMPORT } => {
                return ImportNode.ParseImport(lexer, project, modifiers);
            },
            case { type: TokenType.KEYWORD, value: Keywords.INTERFACE } => {
                return InterfaceNode.ParseInterface(lexer, project, modifiers);
            },
            _ => {
                throw new Exception('Unknown statement type');
            },
        }

        return null;
    }
}
