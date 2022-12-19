import { ProjectSettings } from '../project_settings.ph';
import Collections from 'System/Collections/Generic';
import { FileNode } from '../compilation/cst/file_node.ph';
import { LocalFileSystem } from 'FileSystem/src/local_file_system';
import { Logger } from 'Logging/src/logging';
import { File } from 'System.IO';
import { FileStream } from '../compilation/parsing/file_stream.ph';
import { Lexer } from '../compilation/parsing/lexer.ph';
import { Matcher } from '../compilation/parsing/matcher.ph';
import { Regex } from 'System/Text/RegularExpressions';
import { ProjectDeclarations } from './project_declarations.ph';

export enum Keywords {
    EXPORT('export'),
    CONSTRUCTOR('constructor'),
    DESTRUCTOR('destructor'),
    VOLATILE('volatile'),
    STACKALLOC('stackalloc'),
    ASYNC('async'),
    AWAIT('await'),
    OPERATOR('operator'),
    IMPLICIT('implicit'),
    EXPLICIT('explicit'),
    REF('ref'),
    OUT('out'),
    OF('of'),
    EXTERN('extern'),
    IN('in'),
    LINKED('linked'),
    EXTENDS('extends'),
    IMPLEMENTS('implements'),
    FUNCTION('function'),
    NULL('null'),
    TRUE('true'),
    FALSE('false'),
    CLASS('class'),
    MIXIN('mixin'),
    INTERFACE('interface'),
    STRUCT('struct'),
    TUPLE('tuple'),
    ENUM('enum'),
    MATCH('match'),
    DEFAULT('default'),
    CONTINUE('continue'),
    FOR('for'),
    WHILE('while'),
    DO('do'),
    VOID('void'),
    IF('if'),
    ELSE('else'),
    BREAK('break'),
    RETURN('return'),
    TRY('try'),
    CATCH('catch'),
    FINALLY('finally'),
    THROW('throw'),
    PUBLIC('public'),
    PRIVATE('private'),
    PROTECTED('protected'),
    INTERNAL('internal'),
    ABSTRACT('abstract'),
    STATIC('static'),
    OVERRIDE('override'),
    READONLY('readonly'),
    LET('let'),
    CONST('const'),
    PURE('pure'),
    COMPTIME('comptime'),
    NEW('new'),
    AS('as'),
    IS('is'),
    SIZEOF('sizeof'),
    NAMEOF('nameof'),
    TYPEOF('typeof'),
    THIS('this'),
    SUPER('super'),
    GET('get'),
    SET('set'),
    YIELD('yield'),
    USES('uses'),
    IMPORT('import'),
    FROM('from'),
    BOOL('bool'),
    INT('int'),
    LONG('long'),
    SHORT('short'),
    BYTE('byte'),
    USHORT('ushort'),
    ULONG('ulong'),
    UINT('uint'),
    FLOAT('float'),
    DOUBLE('double'),
    DECIMAL('decimal'),
    OBJECT('object'),
    STRING('string'),
    CHAR('char'),
    SBYTE('sbyte'),
    NINT('nint'),
    NUINT('nuint'),
    LOCK('lock'),
    TYPE('type'),
}

export class AnalyzedProject {
    public readonly project: ProjectSettings;
    public fileNodes: Collections.Dictionary<string, FileNode>;
    public sources: Collections.List<string>;
    public readonly logger: Logger;

    public declarationsDatabase: ProjectDeclarations;

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
        (c) => AnalyzedProject.hexNumberRegex.IsMatch(c),
        (c, startValue, lastValue) => AnalyzedProject.hexNumberRegex.IsMatch(c),
    );

    private static readonly decimalNumberMatcher: Matcher = new Matcher(
        2,
        (c) => AnalyzedProject.decimalNumberRegex.IsMatch(c[0].ToString()),
        (c, startValue, lastValue) => AnalyzedProject.decimalNumberRegex.IsMatch(c[0].ToString()),
        null,
        (c) => c[0].ToString() == '.' && AnalyzedProject.decimalNumberRegex.IsMatch(c[1].ToString()),
        1,
    );

    private static readonly identifierMatcher: Matcher = new Matcher(
        1,
        (c) => AnalyzedProject.identifierStartRegex.IsMatch(c),
        (c, startValue, lastValue) => AnalyzedProject.identifierRegex.IsMatch(c),
    );

    private static readonly whitespaceMatcher: Matcher = new Matcher(
        1,
        (c) => AnalyzedProject.whitespaceRegex.IsMatch(c),
        (c, startValue, lastValue) => AnalyzedProject.whitespaceRegex.IsMatch(c),
    );

    constructor(project: ProjectSettings, logger: Logger) {
        this.project = project;
        this.logger = logger;
        this.fileNodes = new Collections.Dictionary<string, FileNode>();
        this.ResolveSources();
    }

    private ResolveSources(): void {
        const result = new Collections.List<string>();
        for (const source of this.project.sources) {
            if (source.Contains('*')) {
                this.logger.Verbose(`Globbing ${source} at ${this.project.projectPath}`);
                const matches = LocalFileSystem.Instance.Glob(this.project.projectPath, source);
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
                    AnalyzedProject.punctuation,
                    Keywords.GetValues(),
                    AnalyzedProject.whitespaceMatcher,
                    AnalyzedProject.identifierMatcher,
                    AnalyzedProject.decimalNumberMatcher,
                    AnalyzedProject.hexNumberMatcher,
                    AnalyzedProject.stringMatcher,
                    AnalyzedProject.commentMatcher,
                ),
                this,
            );
            this.fileNodes.Add(source, fileNode);
        }
    }
}
