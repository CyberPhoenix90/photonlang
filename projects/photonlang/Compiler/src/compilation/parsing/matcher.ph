import { Token, TokenType } from '../cst/basic/token.ph';
import { FileStream } from './file_stream.ph';

export type MatchChunk = (c: string) => bool;
export type MatchChunkWithStartValue = (c: string, startValue: string, lastValue: string) => bool;
export type MatchChunkWithStartValueAndReplace = (c: string, startValue: string, lastValue: string) => string;

export class Matcher {
    public readonly chunkSize: int;
    public readonly start: MatchChunk;
    public readonly stillMatching: MatchChunkWithStartValue | undefined;
    public readonly escape: MatchChunkWithStartValueAndReplace | undefined;
    public readonly singleTimeMatch: MatchChunk | undefined;
    public readonly startChunkSize: int;
    public readonly escapeChunkSize: int;

    constructor(
        chunkSize: int,
        start: MatchChunk,
        stillMatching: MatchChunkWithStartValue,
        escape?: MatchChunkWithStartValueAndReplace,
        singleTimeMatch?: MatchChunk,
        startChunkSize: int = 0,
        escapeChunkSize: int = 0,
    ) {
        this.chunkSize = chunkSize;
        this.start = start;
        this.stillMatching = stillMatching;
        this.escape = escape;
        this.singleTimeMatch = singleTimeMatch;
        this.startChunkSize = startChunkSize == 0 ? chunkSize : startChunkSize;
        this.escapeChunkSize = escapeChunkSize == 0 ? chunkSize : escapeChunkSize;
    }

    public Parse(type: TokenType, fileStream: FileStream): Token {
        const startContent = fileStream.PeekRange(this.startChunkSize);
        let lastValue = '';
        if (this.start(startContent)) {
            let hasOneTimeMatched = false;
            let content = fileStream.NextRange(this.startChunkSize);
            while (!fileStream.Eof()) {
                if (this.escape != null) {
                    const escapeCandidate = fileStream.PeekRange(this.escapeChunkSize);
                    const escapeResult = this.escape(escapeCandidate, startContent, lastValue);
                    if (escapeResult != null) {
                        content += this.escape(escapeCandidate, startContent, lastValue);
                        fileStream.Skip(this.escapeChunkSize);
                        continue;
                    }
                }

                const c = fileStream.PeekRange(this.chunkSize);
                if (this.stillMatching != null && !this.stillMatching(c, startContent, lastValue)) {
                    if (!hasOneTimeMatched && this.singleTimeMatch != null) {
                        if (this.singleTimeMatch(c)) {
                            hasOneTimeMatched = true;
                        } else {
                            break;
                        }
                    } else {
                        break;
                    }
                }
                lastValue = c;
                content += fileStream.Next();
            }
            return new Token(type, content);
        }
        return null;
    }
}
