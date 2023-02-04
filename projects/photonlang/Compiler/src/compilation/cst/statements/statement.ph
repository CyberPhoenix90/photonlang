import { CSTNode } from '../basic/cst_node.ph';
import Collections from 'System/Collections/Generic';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { TokenType } from '../basic/token.ph';
import { Keywords } from '../../../project_management/keywords.ph';
import { Token } from '../basic/token.ph';
import { Exception } from 'System';
import { ClassNode } from './class_node.ph';
import { ImportStatementNode } from './import_statement_node.ph';
import { EnumNode } from './enum_node.ph';
import { StructNode } from './struct_node.ph';
import { ExpressionStatementNode } from './expression_statement_node.ph';
import { VariableDeclarationStatementNode } from './variable_declaration_statement_node.ph';
import { TypeAliasStatementNode } from './type_alias_statement_node.ph';
import { BlockStatementNode } from './block_statement_node.ph';
import { IfStatementNode } from './if_statement_node.ph';
import { WhileStatementNode } from './while_statement_node.ph';
import { BreakStatementNode } from './break_statement_node.ph';
import { ContinueStatementNode } from './continue_statement_node.ph';
import { ReturnStatementNode } from './return_statement_node.ph';
import { TryStatementNode } from './try_statement_node.ph';
import { ForStatementNode } from './for_statement_node.ph';
import { YieldStatementNode } from './yield_statement_node.ph';
import { LockStatementNode } from './lock_statement_node.ph';
import { EmptyStatementNode } from './empty_statement_node.ph';
import { ForEachStatementNode } from './foreach_statement_node.ph';

export class StatementNode extends CSTNode {
    constructor(units: Collections.List<LogicalCodeUnit>) {
        super(units);
    }

    public static ParseStatement(lexer: Lexer, topLevel: bool): LogicalCodeUnit {
        let mainToken: Token;

        let ptr = 0;

        while (lexer.Peek(ptr).type == TokenType.PUNCTUATION && lexer.Peek(ptr).value == '[') {
            ptr++;
            while (lexer.Peek(ptr).type != TokenType.PUNCTUATION || lexer.Peek(ptr).value != ']') {
                if (lexer.Peek(ptr) == null) {
                    throw new Exception('Expected "]"');
                }
                ptr++;
            }
            ptr++;
        }

        if (lexer.Peek(ptr).type == TokenType.KEYWORD && lexer.Peek(ptr).value == Keywords.EXPORT) {
            ptr++;
        }

        if (lexer.Peek(ptr).type == TokenType.KEYWORD && lexer.Peek(ptr).value == Keywords.ABSTRACT) {
            ptr++;
        }

        mainToken = lexer.Peek(ptr);

        // return match(mainToken) {
        //     { type: TokenType.KEYWORD, value: Keywords.CLASS } => ClassNode.ParseClass(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.STRUCT } => StructNode.ParseStruct(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.ENUM } => EnumNode.ParseEnum(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.IMPORT } => ImportStatementNode.ParseImportStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.THIS } => ExpressionStatementNode.ParseExpressionStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.SUPER } => ExpressionStatementNode.ParseExpressionStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.CONST } => VariableDeclarationStatementNode.ParseVariableDeclarationStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.LET } => VariableDeclarationStatementNode.ParseVariableDeclarationStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.TYPE } => TypeAliasStatementNode.ParseTypeAliasStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.LOCK } => LockStatementNode.ParseLockStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.IF } => IfStatementNode.ParseIfStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.FOR } => StatementNode.IdentifyAndParseForStatement(lexer, ptr),
        //     { type: TokenType.KEYWORD, value: Keywords.WHILE } => WhileStatementNode.ParseWhileStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.BREAK } => BreakStatementNode.ParseBreakStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.CONTINUE } => ContinueStatementNode.ParseContinueStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.RETURN } => ReturnStatementNode.ParseReturnStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.YIELD } => YieldStatementNode.ParseYieldStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.THROW } => ExpressionStatementNode.ParseExpressionStatement(lexer),
        //     { type: TokenType.KEYWORD, value: Keywords.TRY } => TryStatementNode.ParseTryStatement(lexer),
        //     { type: TokenType.PUNCTUATION, value: ";" } => EmptyStatementNode.ParseEmptyStatement(lexer),
        //     { type: TokenType.PUNCTUATION, value: "{" } => BlockStatementNode.ParseBlockStatement(lexer),
        //     { type: TokenType.IDENTIFIER } => ExpressionStatementNode.ParseExpressionStatement(lexer),
        //     default => throw new Exception(`Unknown statement type ${TokenType.GetKey(mainToken.type)} ${mainToken.value} at ${lexer.filePath}:${lexer.Peek().GetLine()}:${lexer.Peek().GetColumn()}`)
        // };

        if (topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.CLASS) {
            return ClassNode.ParseClass(lexer);
        } else if (topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.STRUCT) {
            return StructNode.ParseStruct(lexer);
        } else if (topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.ENUM) {
            return EnumNode.ParseEnum(lexer);
        } else if (topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.IMPORT) {
            return ImportStatementNode.ParseImportStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.THIS) {
            return ExpressionStatementNode.ParseExpressionStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.SUPER) {
            return ExpressionStatementNode.ParseExpressionStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.CONST) {
            return VariableDeclarationStatementNode.ParseVariableDeclarationStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.LET) {
            return VariableDeclarationStatementNode.ParseVariableDeclarationStatement(lexer);
        } else if (topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.TYPE) {
            return TypeAliasStatementNode.ParseTypeAliasStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.LOCK) {
            return LockStatementNode.ParseLockStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.IF) {
            return IfStatementNode.ParseIfStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.FOR) {
            return StatementNode.IdentifyAndParseForStatement(lexer, ptr);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.WHILE) {
            return WhileStatementNode.ParseWhileStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.BREAK) {
            return BreakStatementNode.ParseBreakStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.CONTINUE) {
            return ContinueStatementNode.ParseContinueStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.RETURN) {
            return ReturnStatementNode.ParseReturnStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.YIELD) {
            return YieldStatementNode.ParseYieldStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.THROW) {
            return ExpressionStatementNode.ParseExpressionStatement(lexer);
        } else if (!topLevel && mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.TYPE) {
            return ExpressionStatementNode.ParseExpressionStatement(lexer);
        } else if (mainToken.type == TokenType.KEYWORD && mainToken.value == Keywords.TRY) {
            return TryStatementNode.ParseTryStatement(lexer);
        } else if (mainToken.type == TokenType.PUNCTUATION && mainToken.value == ';') {
            return EmptyStatementNode.ParseEmptyStatement(lexer);
        } else if (mainToken.type == TokenType.PUNCTUATION && mainToken.value == '{') {
            return BlockStatementNode.ParseBlockStatement(lexer);
        } else if (mainToken.type == TokenType.IDENTIFIER) {
            return ExpressionStatementNode.ParseExpressionStatement(lexer);
        } else {
            throw new Exception(
                `Unknown statement type ${TokenType.GetKey(mainToken.type)} ${mainToken.value} at ${lexer.filePath}:${lexer.Peek().GetLine()}:${lexer
                    .Peek()
                    .GetColumn()}`,
            );
        }
    }
    private static IdentifyAndParseForStatement(lexer: Lexer, ptr: int): CSTNode {
        let isForEach = true;
        while (lexer.Peek(ptr) != null && lexer.Peek(ptr).GetText() != ')') {
            ptr++;
            if (lexer.Peek(ptr).GetText() == ';') {
                isForEach = false;
                break;
            }
        }

        if (isForEach) {
            return ForEachStatementNode.ParseForEachStatement(lexer);
        } else {
            return ForStatementNode.ParseForStatement(lexer);
        }
    }
}
