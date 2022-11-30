import { FileStream } from './file_stream.ph';
import { Matcher } from './matcher.ph';

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
        this.fileStream = fileStream;
        this.punctuation = punctuation;
        this.keywords = keywords;
        this.whitespaceMatcher = whitespaceMatcher;
        this.identifierMatcher = identifierMatcher;
        this.decimalNumberMatcher = decimalNumberMatcher;
        this.hexNumberMatcher = hexNumberMatcher;
        this.stringMatcher = stringMatcher;
        this.commentMatcher = commentMatcher;
    }
}
