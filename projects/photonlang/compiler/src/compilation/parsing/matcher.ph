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
}
