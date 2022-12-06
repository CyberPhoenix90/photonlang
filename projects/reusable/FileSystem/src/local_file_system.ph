//@ts-nocheck
import { Path, File, Directory } from "System/IO";
import { String, ArgumentException } from "System";
import Collections from "System/Collections/Generic";
import "System/Linq";

export struct ReadDirectoryOptions {
    directoryNameBlackList: string[] = null;
    directoryNameWhiteList: string[] = null;
    fileNameWhiteList: string[] = null;
    searchHiddenDirectories: bool = false;
    includeDirectories: bool = false;
    excludeFiles: bool = false;
    extensionBlackList: string[] = null;
    extensionWhiteList: string[] = null;
}

export class LocalFileSystem {

    public static Instance:LocalFileSystem = new LocalFileSystem();

    public Glob(
        folder: string,
        pattern: string,
        options: ReadDirectoryOptions = null
    ): string[] {

        if (!pattern.Contains("*") && !pattern.Contains("!")) {
            if (this.Exists(Path.Join(folder, pattern))) {
                return <string>[Path.Join(folder, pattern)];
            } else {
                return <string>[];
            }
        } else {
            const patternParts = pattern.Split("/");
            const leadingSlash = false;

            if (patternParts[0] == "") {
                patternParts = patternParts[1..];
                leadingSlash = true;
            }
            while (patternParts.Length > 0) {
                if (patternParts[0].Contains('*') || patternParts[0].Contains('!')) {
                    break;
                }
                else {
                    folder = Path.Join(folder, patternParts[0]);
                    patternParts = patternParts[1..];
                }
            }

            pattern = String.Join('/', patternParts);
            if (leadingSlash) {
                pattern = '/' + pattern;
            }

            pattern = String.Join('/', patternParts);
            if (leadingSlash) {
                pattern = '/' + pattern;
            }


            const result = new Collections.List<string>();

            if (!Exists(folder)) {
                return result.ToArray();
            }

            const candidates = this.ReadDirectoryRecursively(folder, options);

            for (const candidate of candidates) {
                if (GlobExpressions.Glob.IsMatch(candidate.Substring(folder.Length + 1), pattern)) {
                    result.Add(candidate);
                }
            }

            return result.ToArray();
        }
    }

    public ReadDirectoryRecursively(folder: string, options: ReadDirectoryOptions = null): string[] {
        if (options != null && options.includeDirectories && options.excludeFiles) {
            throw new ArgumentException("Neither directories nor files are included");
        }

        if (options != null && options.fileNameWhiteList.Length == 0) {
            throw new ArgumentException("No files are allowed due to empty whitelist");
        }

        this.NormalizeExtensions(options?.extensionBlackList, options?.extensionWhiteList);
        return this.ReadDirectoryRecursivelyInternal(folder, new Collections.List<string>(), options).ToArray();
    }

    private ReadDirectoryRecursivelyInternal(path: string, result: Collections.List<string>, options: ReadDirectoryOptions = {}): Collections.List<string> {
        if (!options.excludeFiles)
            for(const file of Directory.GetFiles(path))
        {
            if (options.fileNameWhiteList != null && !options.fileNameWhiteList.Contains(Path.GetFileName(file))) {
                continue;
            }

            if (options.extensionBlackList != null && options.extensionBlackList.Contains(Path.GetExtension(file))) {
                continue;
            }

            if (options.extensionWhiteList != null && !options.extensionWhiteList.Contains(Path.GetExtension(file))) {
                continue;
            }

            result.Add(file);
        }

        for(const directory of Directory.GetDirectories(path))
        {
            if (Path.GetFileName(directory).StartsWith(".") && !options.searchHiddenDirectories) {
                continue;
            }

            if (options.directoryNameBlackList != null && options.directoryNameBlackList.Contains(Path.GetFileName(directory))) {
                continue;
            }

            if (options.directoryNameWhiteList != null && !options.directoryNameWhiteList.Contains(Path.GetFileName(directory))) {
                continue;
            }

            if (options.includeDirectories) {
                result.Add(directory);
            }

            this.ReadDirectoryRecursivelyInternal(directory, result, options);
        }

        return result;
    }

    private NormalizeExtensions(extensionBlackList: string[] = null, extensionWhiteList: string[] = null): void {
        if (extensionBlackList != null)
            for (let i = 0; i < extensionBlackList.Length; i++)
                if (!extensionBlackList[i].StartsWith("."))
                    extensionBlackList[i] = "." + extensionBlackList[i];
        if (extensionWhiteList != null)
            for (let i = 0; i < extensionWhiteList.Length; i++)
                if (!extensionWhiteList[i].StartsWith("."))
                    extensionWhiteList[i] = "." + extensionWhiteList[i];
    }

    public Exists(path: string): bool {
        return File.Exists(path) || Directory.Exists(path);
    }
}
