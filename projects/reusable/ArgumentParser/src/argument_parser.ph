import 'System/Linq';
import { Char, String, Array } from 'System';
import Collections from 'System/Collections/Generic';

export class ParsedArguments {
    public readonly raw: string[];
    public readonly escapedArguments: ParsedArguments;
    private readonly keyValuePairs: Collections.Dictionary<string, string>;
    public readonly list: string[];

    constructor(raw: string[]) {
        const collectUntil = Array.IndexOf(raw, '--');
        const argsToProcess = collectUntil == -1 ? raw : raw.Take(collectUntil).ToArray();
        const rest = collectUntil == -1 ? [] : raw.Skip(collectUntil + 1).ToArray();

        this.list = argsToProcess.Where((arg) => !arg.StartsWith('-')).ToArray();
        this.keyValuePairs = new Collections.Dictionary<string, string>();
        this.raw = argsToProcess.Select((arg) => this.KebabCaseToCamelCase(arg)).ToArray();

        if (rest.Length > 0) {
            this.escapedArguments = new ParsedArguments(rest);
        }

        for (let i = 0; i < argsToProcess.Length; i++) {
            let arg = argsToProcess[i];
            if (arg.StartsWith('--')) {
                arg = arg.Substring(2);
            } else if (arg.StartsWith('-')) {
                arg = arg.Substring(1);
            } else {
                continue;
            }

            if (arg.Contains('=')) {
                const split = arg.Split('=');
                this.keyValuePairs.Add(split[0], split[1]);
            } else {
                this.keyValuePairs.Add(arg, 'true');
            }
        }
    }

    private KebabCaseToCamelCase(kebabCase: string): string {
        if (kebabCase.Contains('-') == false) {
            return kebabCase;
        }

        const words = kebabCase.Split('-');
        for (let i = 1; i < words.Length; i++) {
            words[i] = Char.ToUpper(words[i][0]) + words[i].Substring(1);
        }
        return String.Join('', words);
    }

    public GetArgumentAsString(name: string): string {
        if (this.keyValuePairs.ContainsKey(name)) {
            return this.keyValuePairs[name];
        } else {
            return null;
        }
    }

    public GetArgumentAsBool(name: string): bool {
        return this.GetArgumentAsString(name) == 'true';
    }

    public GetArgumentAsBoolOrDefault(name: string, defaultValue: bool): bool {
        const value = this.GetArgumentAsString(name);
        return value == null ? defaultValue : value == 'true';
    }

    public GetArgumentAsInt(name: string): int {
        return int.Parse(this.GetArgumentAsString(name));
    }

    public GetArgumentAsFloat(name: string): float {
        return float.Parse(this.GetArgumentAsString(name));
    }

    public GetArgumentAsDouble(name: string): double {
        return double.Parse(this.GetArgumentAsString(name));
    }

    public GetArgumentAsDecimal(name: string): decimal {
        return decimal.Parse(this.GetArgumentAsString(name));
    }

    public GetArgumentAsStringArray(name: string): string[] {
        return this.GetArgumentAsString(name).Split(',');
    }

    public GetArgumentAsBoolArray(name: string): bool[] {
        return this.GetArgumentAsStringArray(name)
            .Select((value) => value == 'true')
            .ToArray();
    }

    public GetArgumentAsIntArray(name: string): int[] {
        return this.GetArgumentAsStringArray(name)
            .Select((value) => int.Parse(value))
            .ToArray();
    }

    public GetArgumentAsFloatArray(name: string): float[] {
        return this.GetArgumentAsStringArray(name)
            .Select((value) => float.Parse(value))
            .ToArray();
    }

    public GetArgumentAsDoubleArray(name: string): double[] {
        return this.GetArgumentAsStringArray(name)
            .Select((value) => double.Parse(value))
            .ToArray();
    }

    public GetArgumentAsDecimalArray(name: string): decimal[] {
        return this.GetArgumentAsStringArray(name)
            .Select((value) => decimal.Parse(value))
            .ToArray();
    }

    public GetOneOfArgumentsAsString(names: string[]): string {
        for (let i = 0; i < names.Length; i++) {
            const name = names[i];
            if (this.keyValuePairs.ContainsKey(name)) {
                return this.keyValuePairs[name];
            }
        }
        return null;
    }

    public GetOneOfArgumentsAsBool(names: string[]): bool {
        return this.GetOneOfArgumentsAsString(names) == 'true';
    }

    public GetOneOfArgumentsAsInt(names: string[]): int {
        return int.Parse(this.GetOneOfArgumentsAsString(names));
    }

    public GetOneOfArgumentsAsFloat(names: string[]): float {
        return float.Parse(this.GetOneOfArgumentsAsString(names));
    }

    public GetOneOfArgumentsAsDouble(names: string[]): double {
        return double.Parse(this.GetOneOfArgumentsAsString(names));
    }

    public GetOneOfArgumentsAsDecimal(names: string[]): decimal {
        return decimal.Parse(this.GetOneOfArgumentsAsString(names));
    }

    public GetOneOfArgumentsAsStringArray(names: string[]): string[] {
        return this.GetOneOfArgumentsAsString(names).Split(',');
    }

    public GetOneOfArgumentsAsBoolArray(names: string[]): bool[] {
        return this.GetOneOfArgumentsAsStringArray(names)
            .Select((value) => value == 'true')
            .ToArray();
    }

    public GetOneOfArgumentsAsIntArray(names: string[]): int[] {
        return this.GetOneOfArgumentsAsStringArray(names)
            .Select((value) => int.Parse(value))
            .ToArray();
    }

    public GetOneOfArgumentsAsFloatArray(names: string[]): float[] {
        return this.GetOneOfArgumentsAsStringArray(names)
            .Select((value) => float.Parse(value))
            .ToArray();
    }

    public GetOneOfArgumentsAsDoubleArray(names: string[]): double[] {
        return this.GetOneOfArgumentsAsStringArray(names)
            .Select((value) => double.Parse(value))
            .ToArray();
    }

    public GetOneOfArgumentsAsDecimalArray(names: string[]): decimal[] {
        return this.GetOneOfArgumentsAsStringArray(names)
            .Select((value) => decimal.Parse(value))
            .ToArray();
    }

    public HasArgument(name: string): bool {
        return this.keyValuePairs.ContainsKey(name);
    }

    public HasOneOfArguments(names: string[]): bool {
        for (let i = 0; i < names.Length; i++) {
            const name = names[i];
            if (this.keyValuePairs.ContainsKey(name)) {
                return true;
            }
        }
        return false;
    }
}
