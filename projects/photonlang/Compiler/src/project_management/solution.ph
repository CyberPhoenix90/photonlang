import { JsonConvert } from 'Newtonsoft/Json';
import { Path } from 'System/IO';
import { LocalFileSystem } from 'FileSystem/src/local_file_system';
import Collections from 'System/Collections/Generic';
import { ParsedProject } from './parsed_project.ph';
import { Logger } from 'Logging/src/logging';
import { ProjectSettings } from '../project_settings.ph';
import 'System/Linq';

export struct SolutionConfig {
    public readonly name: string;
    public readonly includes: string[];
}

export class Solution {
    public readonly config: SolutionConfig;
    public readonly path: string;
    public readonly projects: Collections.Dictionary<string, ParsedProject>;
    public readonly logger: Logger;

    public constructor(solutionConfig: SolutionConfig, path: string, logger: Logger) {
        this.config = solutionConfig;
        this.path = path;
        this.logger = logger;

        const projects = new Collections.List<ParsedProject>();

        for (const include of solutionConfig.includes) {
            let includePath = Path.GetFullPath(Path.Join(path, include));
            if (LocalFileSystem.Instance.Exists(includePath)) {
                if (LocalFileSystem.Instance.IsDirectory(includePath)) {
                    const configs = LocalFileSystem.Instance.Glob(includePath, '/**/photon.json');
                    for (const config of configs) {
                        projects.Add(new ParsedProject(JsonConvert.DeserializeObject<ProjectSettings>(config), logger));
                    }
                } else if (includePath.EndsWith('.json')) {
                    projects.Add(new ParsedProject(JsonConvert.DeserializeObject<ProjectSettings>(includePath), logger));
                }
            }
        }
    }

    public BuildProject(projectName: string, shallow: bool): void {
        const project = this.projects[projectName];
        if (!shallow) {
            const projectList = this.GetDependenciesRecursive(projectName);
            projectList.Add(project);
            // const projectsByDependency = this.SortDependencies(projectList);

            for (const p of projectList) {
                p.Build();
            }
        } else {
            project.Build();
        }
    }

    // private SortDependencies(projects: Collections.HashSet<ParsedProject>): Collections.List<ParsedProject> {
    //     const result: Collections.List<ParsedProject> = new Collections.List<ParsedProject>();
    //     const remainingProjects = projects.Clone();
    //     const dependencyMap: Collections.Dictionary<string, string[]> = new Collections.Dictionary<string, string[]>();

    //     for (const project of projects) {
    //         dependencyMap.set(project.name, project.dependencies.ToArray());
    //     }

    //     while (remainingProjects.Length) {
    //         let circle = true;

    //         for (let i = remainingProjects.length - 1; i >= 0; i--) {
    //             if (dependencyMap[remainingProjects[i].id].every((f) => result.map((e) => e.id).includes(f as any))) {
    //                 result.push(remainingProjects[i]);
    //                 remainingProjects.splice(i, 1);
    //                 circle = false;
    //             }
    //         }

    //         if (circle) {
    //             const circle = this.FindCircle(
    //                 remainingProjects.map((e) => e.id),
    //                 dependencyMap,
    //             );
    //             this.logger.Error(String.Join("->",circle));
    //             throw new Error(`Circular dependency in project dependencies ${circle.join('->')}`);
    //         }
    //     }

    //     return result;
    // }

    // private FindCircle(projectNames: string[], dependencyMap: Record<string, string[]>): string[] {
    //     for (const start of projectNames) {
    //         for (const dep of dependencyMap[start]) {
    //             if (projectNames.find((e) => e === dep)) {
    //                 const result = this.CheckCircle(
    //                     projectNames.find((e) => e === dep),
    //                     [start],
    //                     projectNames,
    //                     dependencyMap,
    //                 );
    //                 if (result) {
    //                     return result;
    //                 }
    //             }
    //         }
    //     }
    //     throw new Error('no circle');
    // }

    // private CheckCircle(dep: string, chain: string[], projectNames: string[], dependencyMap: Record<string, string[]>): string[] {
    //     if (projectNames.map((p) => p).includes(dep)) {
    //         if (chain.includes(dep)) {
    //             chain.push(dep);
    //             return chain;
    //         } else {
    //             chain.push(dep);
    //             for (const subDep of dependencyMap[dep]) {
    //                 if (projectNames.find((p) => p === subDep)) {
    //                     const result = this.CheckCircle(
    //                         projectNames.find((p) => p === subDep),
    //                         [...chain],
    //                         projectNames,
    //                         dependencyMap,
    //                     );
    //                     if (result) {
    //                         return result;
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     return undefined;
    // }

    public GetDependencies(projectName: string): Collections.HashSet<ParsedProject> {
        const project = this.projects[projectName];
        const dependencies = new Collections.HashSet<ParsedProject>();
        for (const dependency of project.settings.projectReferences) {
            const dep = this.projects[dependency];
            dependencies.Add(dep);
        }
        return dependencies;
    }

    public GetDependenciesRecursive(projectName: string): Collections.HashSet<ParsedProject> {
        const project = this.projects[projectName];
        const dependencies = new Collections.HashSet<ParsedProject>();
        for (const dependency of project.settings.projectReferences) {
            const dep = this.projects[dependency];
            dependencies.Add(dep);
            for (const depDep of this.GetDependenciesRecursive(dependency)) {
                dependencies.Add(depDep);
            }
        }
        return dependencies;
    }

    public static Load(path: string, logger: Logger): Solution {
        const solutionConfig = JsonConvert.DeserializeObject<SolutionConfig>(path);
        return new Solution(solutionConfig, path, logger);
    }
}

// export type ArrayPredicate<T> = (value: T, index: int, obj: T[]) => bool;

// export function Find<T>(this:T[], predicate: ArrayPredicate<T>): T | null {
//     for (let i = 0; i < this.Length; i++) {
//         if (predicate(this[i], i, this)) {
//             return this[i];
//         }
//     }
//     return default(T);
// }
