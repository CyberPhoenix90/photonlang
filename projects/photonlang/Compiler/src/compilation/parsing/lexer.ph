import { FileStream } from './file_stream.ph';
import { Matcher } from './matcher.ph';
import Collection from 'System/Collections/Generic';
import { Token, TokenType } from '../../compilation/ast/basic/token.ph';
import { Exception, Array } from 'System';
import 'System/Linq';

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

    public tokens: Collection.List<Token>;

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
        this.punctuation = punctuation;
        this.keywords = keywords;
        this.whitespaceMatcher = whitespaceMatcher;
        this.identifierMatcher = identifierMatcher;
        this.decimalNumberMatcher = decimalNumberMatcher;
        this.hexNumberMatcher = hexNumberMatcher;
        this.stringMatcher = stringMatcher;
        this.commentMatcher = commentMatcher;
        this.index = 0;

        this.tokens = new Collection.List<Token>();

        while (!fileStream.Eof()) {
            const token = this.ParseNext();
            if (token != null) {
                this.tokens.Add(token);
            } else {
                throw new Exception(`Failed to parse token at ${fileStream.Peek()} no matcher matches it`);
            }
        }
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

    public Peek(offset: int = 0): Token | undefined {
        if (this.index + offset >= this.tokens.Count) {
            return null;
        }

        return this.tokens[this.index + offset];
    }

    public PeekNonWhitespace(offset: int = 0, allowNewLineWhitespace: bool = false): Token | undefined {
        let internalOffset = 0;
        while (offset >= 0) {
            while (
                this.Peek(internalOffset) != null &&
                (this.Peek(internalOffset).type == TokenType.WHITESPACE || this.Peek(internalOffset).type == TokenType.COMMENT)
            ) {
                if (allowNewLineWhitespace && this.Peek(internalOffset).value == '\n') {
                    break;
                }
                internalOffset++;
            }
            if (offset > 0) {
                internalOffset++;
            }
            offset--;
        }

        return this.Peek(internalOffset);
    }

    public Eof(): bool {
        return this.index >= this.tokens.Count;
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
}
