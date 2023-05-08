import { LocalFileSystem } from 'FileSystem/src/local_file_system';
import { Logger } from 'Logging/src/logging';
import { File } from 'System.IO';
import Collections from 'System/Collections/Generic';
import 'System/Linq';
import { Regex } from 'System/Text/RegularExpressions';
import { Assembler } from '../compilation/assembler.ph';
import { ExpressionNode } from '../compilation/cst/expressions/expression_node.ph';
import { FileNode } from '../compilation/cst/file_node.ph';
import { FileStream } from '../compilation/parsing/file_stream.ph';
import { Lexer } from '../compilation/parsing/lexer.ph';
import { Matcher } from '../compilation/parsing/matcher.ph';
import { ProjectSettings } from '../project_settings.ph';
import { Keywords } from './keywords.ph';
import { StaticAnalyzer } from './static_analyzer.ph';
import { TypeInstance } from './type_system/type_instance.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { VariableDeclarationNode } from '../compilation/cst/other/variable_declaration_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { Assembly } from 'System/Reflection';
import { FunctionStatementNode } from '../compilation/cst/statements/function_statement_node.ph';

export type Declaration = ClassNode | StructNode | EnumNode | VariableDeclarationNode | TypeAliasStatementNode | FunctionStatementNode;
export type ImportTarget = FileNode | Assembly;

export class ParsedProject {
    public readonly settings: ProjectSettings;
    public fileNodes: Collections.Dictionary<string, FileNode>;
    public sources: Collections.List<string>;
    public readonly logger: Logger;

    private static identifierStartRegex: Regex = new Regex('[@a-zA-Z_]');
    private static identifierRegex: Regex = new Regex('[@a-zA-Z0-9_-]');
    private static decimalNumberRegex: Regex = new Regex('[0-9]+');
    private static hexNumberRegex: Regex = new Regex('0x[0-9a-fA-F]+');
    private static whitespaceRegex: Regex = new Regex('[ \t\r\n]+');

    private static readonly punctuation: string[] = [
        '??=',
        '??',
        '</',
        ':',
        '>',
        '<',
        '>=',
        '<=',
        '!=',
        '=',
        '==',
        '...',
        '||',
        '&&',
        '|',
        '&',
        '!',
        '~',
        '-',
        '++',
        '--',
        '+',
        '*',
        '/',
        '%',
        '^',
        '<<',
        '>>',
        '?',
        '?.',
        '|>',
        '||>',
        '(',
        ')',
        '..',
        '.',
        ';',
        ',',
        '=>',
        '{',
        '}',
        '[',
        ']',
        '?=',
        '+=',
        '-=',
        '*=',
        '/=',
        '%=',
        '^=',
        '<<=',
        '>>=',
        '&=',
        '|=',
        '&&= ',
        '||=',
    ];

    private static readonly stringMatcher: Matcher = new Matcher(
        1,
        (c) => c == '"' || c == "'" || c == '`',
        (c, startValue, lastValue) => startValue != lastValue || (startValue != '`' && c == '\n'),
        (c, startValue, lastValue) => {
            if (c[0].ToString() == '\\') {
                if (c == '\\\\') {
                    return '\\';
                } else if (c == '\\n') {
                    return '\n';
                } else if (c == '\\r') {
                    return '\r';
                } else if (c == '\\t') {
                    return '\t';
                } else if (c == '\\0') {
                    return '\0';
                } else if (startValue[0].ToString() == '"' && c == '\\"') {
                    return '"';
                } else if (startValue[0].ToString() == "'" && c == "\\'") {
                    return "'";
                } else if (startValue[0].ToString() == '`' && c == '\\`') {
                    return '`';
                } else {
                    return c[1].ToString();
                }
            } else {
                return null;
            }
        },
        null,
        0,
        2,
    );

    private static readonly commentMatcher: Matcher = new Matcher(
        2,
        (c) => c == '//' || c == '/*',
        (c, startValue, lastValue) => (lastValue.Length > 0 && startValue == '//' ? lastValue[0].ToString() != '\n' : lastValue != '*/'),
    );

    private static readonly hexNumberMatcher: Matcher = new Matcher(
        1,
        (c) => ParsedProject.hexNumberRegex.IsMatch(c),
        (c, startValue, lastValue) => ParsedProject.hexNumberRegex.IsMatch(c),
    );

    private static readonly decimalNumberMatcher: Matcher = new Matcher(
        2,
        (c) => ParsedProject.decimalNumberRegex.IsMatch(c[0].ToString()),
        (c, startValue, lastValue) => ParsedProject.decimalNumberRegex.IsMatch(c[0].ToString()),
        null,
        (c) => c[0].ToString() == '.' && ParsedProject.decimalNumberRegex.IsMatch(c[1].ToString()),
        1,
    );

    private static readonly identifierMatcher: Matcher = new Matcher(
        1,
        (c) => ParsedProject.identifierStartRegex.IsMatch(c),
        (c, startValue, lastValue) => ParsedProject.identifierRegex.IsMatch(c),
    );

    private static readonly whitespaceMatcher: Matcher = new Matcher(
        1,
        (c) => ParsedProject.whitespaceRegex.IsMatch(c),
        (c, startValue, lastValue) => ParsedProject.whitespaceRegex.IsMatch(c),
    );

    constructor(project: ProjectSettings, logger: Logger) {
        super();
        this.settings = project;
        this.logger = logger;
        this.fileNodes = new Collections.Dictionary<string, FileNode>();
        this.ResolveSources();
    }

    private ResolveSources(): void {
        const result = new Collections.List<string>();
        for (const source of this.settings.sources) {
            if (source.Contains('*')) {
                this.logger.Verbose(`Globbing ${source} at ${this.settings.projectPath}`);
                const matches = LocalFileSystem.Instance.Glob(this.settings.projectPath, source);
                result.AddRange(matches);
            } else {
                result.Add(source);
            }
        }

        this.logger.Verbose(`Found ${result.Count} sources`);

        this.sources = result;
    }

    public Parse(): void {
        this.logger.Verbose(`Parsing ${this.sources.Count} sources`);
        for (const source of this.sources) {
            this.logger.Verbose(`Parsing ${source}`);
            const fileNode = FileNode.ParseFile(
                new Lexer(
                    new FileStream(File.ReadAllText(source), source),
                    ParsedProject.punctuation,
                    Keywords.GetKeys()
                        .Select((x) => x.ToLower())
                        .ToArray(),
                    ParsedProject.whitespaceMatcher,
                    ParsedProject.identifierMatcher,
                    ParsedProject.decimalNumberMatcher,
                    ParsedProject.hexNumberMatcher,
                    ParsedProject.stringMatcher,
                    ParsedProject.commentMatcher,
                ),
                this,
            );
            this.fileNodes.Add(source, fileNode);
        }
    }

    public ResolveExpressionType(expression: ExpressionNode): TypeInstance {
        // if (expression instanceof IdentifierExpressionNode) {
        //     const declaration = this.IdentifierToDeclaration(expression.identifier, expression);
        //     if (declaration == null) {
        //         throw new Exception(`Cannot find identifier ${expression.identifier}`);
        //     } else {
        //         if (declaration instanceof ClassNode) {
        //             return new TypeIdentifierExpressionNode(declaration.name, expression);
        //         } else if (declaration instanceof FunctionNode) {
        //             return new TypeExpressionNode(declaration.returnType, expression);
        //         } else if (declaration instanceof VariableNode) {
        //             return new TypeExpressionNode(declaration.type, expression);
        //         } else {
        //             throw new Exception(`Cannot resolve type of ${expression.identifier} as it is not a class, function or variable`);
        //         }
        //     }
        // } else if (expression instanceof BinaryExpressionNode) {
        //     if (expression.operator == 'instanceof') {
        //         return new TypeExpressionNode('boolean', expression);
        //     } else {
        //         const leftType = this.ResolveExpressionType(expression.left);
        //         const rightType = this.ResolveExpressionType(expression.right);
        //         if (leftType.type == rightType.type) {
        //             return leftType;
        //         } else {
        //             throw new Exception(
        //                 `Cannot resolve type of ${expression.operator} as left type ${leftType.type} does not match right type ${rightType.type}`,
        //             );
        //         }
        //     }
        // } else if (expression instanceof UnaryExpressionNode) {
        //     if (expression.operator == 'typeof') {
        //         return new TypeExpressionNode('string', expression);
        //     } else {
        //         return this.ResolveExpressionType(expression.expression);
        //     }
        // } else if (expression instanceof TernaryExpressionNode) {
        //     const leftType = this.ResolveExpressionType(expression.left);
        //     const rightType = this.ResolveExpressionType(expression.right);
        //     if (leftType.type == rightType.type) {
        //         return leftType;
        //     } else {
        //         throw new Exception(`Cannot resolve type of ${expression.operator} as left type ${leftType.type} does not match right type ${rightType.type}`);
        //     }
        // } else if (expression instanceof FunctionCallExpressionNode) {
        //     const declaration = this.IdentifierToDeclaration(expression.identifier, expression);
        //     if (declaration == null) {
        //         throw new Exception(`Cannot find identifier ${expression.identifier}`);
        //     } else {
        //         if (declaration instanceof FunctionNode) {
        //             return new TypeExpressionNode(declaration.returnType, expression);
        //         } else {
        //             throw new Exception(`Cannot resolve type of ${expression.identifier} as it is not a function`);
        //         }
        //     }
        // }
        return null;
    }

    public Build(): void {
        const assembly = new Assembler(this.settings, new StaticAnalyzer(this.logger, this.settings), this.logger);
        assembly.Parse();
        assembly.Validate();
        assembly.Emit();
    }
}
