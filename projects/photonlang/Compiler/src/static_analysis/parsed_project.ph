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
import { Keywords } from './keywords.ph';
import { Project } from './project.ph';
import { Declaration } from './project.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';

export class ParsedProject extends Project {
    public readonly project: ProjectSettings;
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
                    ParsedProject.punctuation,
                    Keywords.GetValues(),
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

    public IdentifierToDeclaration(identifier: IdentifierExpressionNode): Declaration {
        return null;
    }
}
