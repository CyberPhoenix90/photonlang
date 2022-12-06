import { Token, TokenType } from '../ast/basic/token.ph';
import { FileStream } from './file_stream.ph';

export type MatchChunk = (c: string) => bool;
export type MatchChunkWithStartValue = (c: string, startValue: string, lastValue: string) => bool;

export class Matcher {
    public readonly chunkSize: int;
    public readonly start: MatchChunk;
    public readonly stillMatching: MatchChunkWithStartValue | undefined;
    public readonly escape: MatchChunkWithStartValue | undefined;
    public readonly singleTimeMatch: MatchChunk | undefined;
    public readonly startChunkSize: int;

    constructor(
        chunkSize: int,
        start: MatchChunk,
        stillMatching: MatchChunkWithStartValue,
        escape?: MatchChunkWithStartValue,
        singleTimeMatch?: MatchChunk,
        startChunkSize: int = 0,
    ) {
        this.chunkSize = chunkSize;
        this.start = start;
        this.stillMatching = stillMatching;
        this.escape = escape;
        this.singleTimeMatch = singleTimeMatch;
        this.startChunkSize = startChunkSize;
    }

    public Parse(type: TokenType, fileStream: FileStream): Token {
        const startContent = fileStream.PeekRange(this.startChunkSize);
        let lastValue = '';
        if (this.start(startContent)) {
            let hasOneTimeMatched = false;
            let content = fileStream.NextRange(this.startChunkSize);
            let escaped = false;
            while (!fileStream.Eof()) {
                const c = fileStream.PeekRange(this.chunkSize);
                if (this.escape != null && this.escape(c, startContent, lastValue)) {
                    escaped = true;
                    fileStream.Skip(1);
                    continue;
                }

                if (!escaped && this.stillMatching != null && !this.stillMatching(c, startContent, lastValue)) {
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
                if (!escaped) {
                    lastValue = c;
                }
                escaped = false;
                content += fileStream.Next();
            }
            return new Token(type, content);
        }
        return null;
    }
}
