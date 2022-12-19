import { File } from 'System/IO';

export class FileStream {
    private pos: int;
    public readonly filePath: string;
    private input: string;

    constructor(input: string, filePath: string) {
        this.pos = 0;
        this.input = input;
        this.filePath = filePath;
    }

    public static FromFile(file: string): FileStream {
        return new FileStream(File.ReadAllText(file), file);
    }

    public Next(): char {
        return this.input[pos++];
    }

    public NextRange(count: int): string {
        const result = this.input.Substring(this.pos, count);
        this.pos += count;
        return result;
    }

    public Skip(count: int): void {
        this.pos += count;
    }

    public Peek(offset: int = 0): char {
        return this.input[this.pos + offset];
    }

    public PeekRange(count: int, offset: int = 0): string {
        if (pos + offset + count > input.Length) {
            return input.Substring(pos + offset);
        } else {
            return input.Substring(pos + offset, count);
        }
    }

    public Eof(): bool {
        return this.pos >= this.input.Length;
    }
}
