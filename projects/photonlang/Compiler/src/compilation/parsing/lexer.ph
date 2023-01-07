import { Array, Exception, String } from 'System';
import Collections from 'System/Collections/Generic';
import 'System/Linq';
import { Token, TokenType } from '../../compilation/cst/basic/token.ph';
import { FileStream } from './file_stream.ph';
import { Matcher } from './matcher.ph';

export enum LexingContext {
    Default,
    Template,
}

export class Lexer {
    private fileStream: FileStream;
    private punctuation: string[];
    private keywords: string[];
    private whitespaceMatcher: Matcher;
    private identifierMatcher: Matcher;
    private decimalNumberMatcher: Matcher;
    private hexNumberMatcher: Matcher;
    private stringMatcher: Matcher;
    private commentMatcher: Matcher;
    private index: int;
    private readonly state: Collections.Stack<LexingContext>;

    public readonly filePath: string;
    public tokens: Collections.List<Token>;

    constructor(
        fileStream: FileStream,
        punctuation: string[],
        keywords: string[],
        whitespaceMatcher: Matcher,
        identifierMatcher: Matcher,
        decimalNumberMatcher: Matcher,
        hexNumberMatcher: Matcher,
        stringMatcher: Matcher,
        commentMatcher: Matcher,
    ) {
        Array.Sort(punctuation, (x, y) => y.Length.CompareTo(x.Length));
        Array.Sort(keywords, (x, y) => y.Length.CompareTo(x.Length));

        this.fileStream = fileStream;
        this.filePath = fileStream.filePath;
        this.punctuation = punctuation;
        this.keywords = keywords;
        this.whitespaceMatcher = whitespaceMatcher;
        this.identifierMatcher = identifierMatcher;
        this.decimalNumberMatcher = decimalNumberMatcher;
        this.hexNumberMatcher = hexNumberMatcher;
        this.stringMatcher = stringMatcher;
        this.commentMatcher = commentMatcher;
        this.index = 0;
        this.state = new Collections.Stack<LexingContext>();

        this.tokens = new Collections.List<Token>();

        while (!fileStream.Eof()) {
            const token = this.ParseNext();
            if (token != null) {
                this.tokens.Add(token);
            } else {
                throw new Exception(`Failed to parse token at ${fileStream.Peek()} no matcher matches it`);
            }
        }

        if (this.state.Count > 0) {
            throw new Exception(`Unbalanced template start at ${this.filePath}`);
        }
    }

    public NextCoding(): Token[] {
        if (this.index >= this.tokens.Count) {
            return <Token>[];
        }

        const tokens = new Collections.List<Token>();
        while (this.index < this.tokens.Count) {
            const token = this.tokens[this.index++];
            if (token.type == TokenType.WHITESPACE || token.type == TokenType.COMMENT) {
                continue;
            }

            tokens.Add(token);
            break;
        }

        return tokens.ToArray();
    }

    public IndexOf(tokenType: TokenType, value?: string): int {
        for (let i = this.index; i < this.tokens.Count; i++) {
            if (this.tokens[i].type == tokenType) {
                if (value == null || this.tokens[i].value == value) {
                    return i;
                }
            }
        }

        return -1;
    }

    public Next(): Token | undefined {
        if (this.index >= this.tokens.Count) {
            return null;
        }

        return this.tokens[this.index++];
    }

    public Skip(count: int): void {
        this.index += count;
    }

    public GetIndex(): int {
        return this.index;
    }

    public SetIndex(index: int): void {
        this.index = index;
    }

    public Backtrack(): void {
        if (this.index > 0) {
            this.index--;
        }
    }

    public GetAt(index: int): Token {
        return this.tokens[index];
    }

    //Returns the next token, skipping whitespace and comments
    public Peek(offset: int = 0, allowNewLineWhitespace: bool = false): Token | undefined {
        let internalOffset = 0;
        while (offset >= 0) {
            while (
                this.PeekNonCoding(internalOffset) != null &&
                (this.PeekNonCoding(internalOffset).type == TokenType.WHITESPACE || this.PeekNonCoding(internalOffset).type == TokenType.COMMENT)
            ) {
                if (allowNewLineWhitespace && this.PeekNonCoding(internalOffset).value == '\n') {
                    break;
                }
                internalOffset++;
            }
            if (offset > 0) {
                internalOffset++;
            }
            offset--;
        }

        return this.PeekNonCoding(internalOffset);
    }

    //Returns the next token, including whitespace and comments
    public PeekNonCoding(offset: int = 0): Token | undefined {
        if (this.index + offset >= this.tokens.Count) {
            return null;
        }

        return this.tokens[this.index + offset];
    }

    public PeekRange(count: int, offset: int = 0): Token[] {
        const result = new Collections.List<Token>();
        for (let i = 0; i < count; i++) {
            const token = this.Peek(i + offset);
            if (token == null) {
                break;
            }
            result.Add(token);
        }
        return result.ToArray();
    }

    public Eof(): bool {
        return this.Peek() == null;
    }

    private ParseWhitespace(): Token | undefined {
        return this.whitespaceMatcher.Parse(TokenType.WHITESPACE, this.fileStream);
    }

    private ParseKeywordOrIdentifier(): Token | undefined {
        const startContent = this.fileStream.PeekRange(this.identifierMatcher.chunkSize);
        let lastContent = '';
        if (this.identifierMatcher.start(startContent)) {
            let content = this.fileStream.NextRange(this.identifierMatcher.chunkSize);

            while (!this.fileStream.Eof()) {
                const c = this.fileStream.PeekRange(this.identifierMatcher.chunkSize);
                if (!this.identifierMatcher.stillMatching(c, startContent, lastContent)) {
                    break;
                }
                lastContent = c;
                content += this.fileStream.Next();
            }
            if (this.keywords.Contains(content)) {
                return new Token(TokenType.KEYWORD, content);
            } else {
                return new Token(TokenType.IDENTIFIER, content);
            }
        }
        return null;
    }

    private ParseDecimalNumber(): Token | undefined {
        if (this.decimalNumberMatcher == null) {
            return null;
        }

        return this.decimalNumberMatcher.Parse(TokenType.NUMBER, this.fileStream);
    }

    private ParseHexNumber(): Token | undefined {
        if (this.hexNumberMatcher == null) {
            return null;
        }

        return this.hexNumberMatcher.Parse(TokenType.NUMBER, this.fileStream);
    }

    private ParseString(): Token | undefined {
        if (this.stringMatcher == null) {
            return null;
        }

        return this.stringMatcher.Parse(TokenType.STRING, this.fileStream);
    }

    private ParseComment(): Token | undefined {
        if (this.commentMatcher == null) {
            return null;
        }

        return this.commentMatcher.Parse(TokenType.COMMENT, this.fileStream);
    }

    private ParsePunctuation(): Token | undefined {
        const startContent = this.fileStream.PeekRange(this.punctuation.Max((s) => s.Length));
        for (const p of this.punctuation) {
            if (startContent.StartsWith(p)) {
                this.fileStream.Skip(p.Length);
                return new Token(TokenType.PUNCTUATION, p);
            }
        }
        return null;
    }

    private ParseNext(): Token | undefined {
        let token = this.ParseWhitespace();
        if (token != null) {
            return token;
        }
        token = this.ParseKeywordOrIdentifier();
        if (token != null) {
            return token;
        }
        token = this.ParseDecimalNumber();
        if (token != null) {
            return token;
        }
        token = this.ParseHexNumber();
        if (token != null) {
            return token;
        }
        token = this.ParseString();
        if (token != null) {
            return token;
        }
        token = this.ParseComment();
        if (token != null) {
            return token;
        }
        token = this.ParsePunctuation();
        if (token != null) {
            return token;
        }
        return null;
    }

    public IsKeyword(): bool {
        return this.Peek().type == TokenType.KEYWORD;
    }

    public IsKeyword(keyword: string): bool {
        return this.Peek().type == TokenType.KEYWORD && this.Peek().value == keyword;
    }

    public IsOneOfKeywords(keyword: string[]): bool {
        return this.Peek().type == TokenType.KEYWORD && keyword.Contains(this.Peek().value);
    }

    public IsOneOfPunctuation(punctuation: string[]): bool {
        return this.Peek().type == TokenType.PUNCTUATION && punctuation.Contains(this.Peek().value);
    }

    public IsIdentifier(): bool {
        return this.Peek().type == TokenType.IDENTIFIER;
    }

    public IsIdentifier(identifier: string): bool {
        return this.Peek().type == TokenType.IDENTIFIER && this.Peek().value == identifier;
    }

    public IsNumber(): bool {
        return this.Peek().type == TokenType.NUMBER;
    }

    public IsString(): bool {
        return this.Peek().type == TokenType.STRING;
    }

    public IsPunctuation(): bool {
        return this.Peek().type == TokenType.PUNCTUATION;
    }

    public IsPunctuation(punctuation: string): bool {
        return this.Peek().type == TokenType.PUNCTUATION && this.Peek().value == punctuation;
    }

    public IsWhitespace(): bool {
        return this.PeekNonCoding().type == TokenType.WHITESPACE;
    }

    public IsComment(): bool {
        return this.PeekNonCoding().type == TokenType.COMMENT;
    }

    public GetKeyword(): Token[] {
        if (!this.IsKeyword()) {
            throw new Exception(`Expected keyword but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetKeyword(keyword: string): Token[] {
        if (!this.IsKeyword(keyword)) {
            throw new Exception(`Expected keyword ${keyword} but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetOneOfKeywords(keywords: string[]): Token[] {
        if (!this.IsOneOfKeywords(keywords)) {
            throw new Exception(`Expected a keyword from ${String.Join(','[0], keywords)} but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetOneOfPunctuation(punctuation: string[]): Token[] {
        if (!this.IsOneOfPunctuation(punctuation)) {
            throw new Exception(`Expected punctuation from ${String.Join(','[0], punctuation)} but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetIdentifier(): Token[] {
        if (!this.IsIdentifier()) {
            throw new Exception(`Expected identifier but got ${this.Peek().value} at ${this.filePath}:${this.Peek().GetLine()}:${this.Peek().GetColumn()}`);
        }
        return this.NextCoding();
    }

    public GetIdentifier(identifier: string): Token[] {
        if (!this.IsIdentifier(identifier)) {
            throw new Exception(`Expected identifier ${identifier} but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetNumber(): Token[] {
        if (!this.IsNumber()) {
            throw new Exception(`Expected number but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetString(): Token[] {
        if (!this.IsString()) {
            throw new Exception(`Expected string but got ${this.Peek().value}`);
        }
        return this.NextCoding();
    }

    public GetPunctuation(): Token[] {
        if (!this.IsPunctuation()) {
            throw new Exception(`Expected punctuation but got ${this.Peek().value} at ${this.filePath}:${this.Peek().GetLine()}:${this.Peek().GetColumn()}`);
        }
        return this.NextCoding();
    }

    public GetPunctuation(punctuation: string): Token[] {
        if (!this.IsPunctuation(punctuation)) {
            throw new Exception(
                `Expected punctuation ${punctuation} but got ${this.Peek().value} at ${this.filePath}:${this.Peek().GetLine()}:${this.Peek().GetColumn()}`,
            );
        }
        return this.NextCoding();
    }

    public GetWhitespace(): Token | undefined {
        if (!this.IsWhitespace()) {
            throw new Exception('Expected whitespace');
        }
        return this.Next();
    }

    public GetComment(): Token | undefined {
        if (!this.IsComment()) {
            throw new Exception('Expected comment');
        }
        return this.Next();
    }
}
