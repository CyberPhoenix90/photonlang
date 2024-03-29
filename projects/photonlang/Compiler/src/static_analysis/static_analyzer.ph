import { Logger } from 'Logging/src/logging';
import { Project as MSBuildProject, ProjectCollection } from 'Microsoft/Build/Evaluation';
import { Console, Exception } from 'System';
import Collections from 'System/Collections/Generic';
import { Path } from 'System/IO';
import 'System/Linq';
import { Assembly } from 'System/Reflection';
import { LogicalCodeUnit } from '../compilation/cst/basic/logical_code_unit.ph';
import { CSTHelper } from '../compilation/cst/cst_helper.ph';
import { IdentifierExpressionNode } from '../compilation/cst/expressions/identifier_expression_node.ph';
import { FileNode } from '../compilation/cst/file_node.ph';
import { ClassMethodNode } from '../compilation/cst/other/class_method_node.ph';
import { ClassNode } from '../compilation/cst/statements/class_node.ph';
import { EnumNode } from '../compilation/cst/statements/enum_node.ph';
import { FunctionStatementNode } from '../compilation/cst/statements/function_statement_node.ph';
import { ImportStatementNode } from '../compilation/cst/statements/import_statement_node.ph';
import { StructNode } from '../compilation/cst/statements/struct_node.ph';
import { TypeAliasStatementNode } from '../compilation/cst/statements/type_alias_statement_node.ph';
import { VariableDeclarationStatementNode } from '../compilation/cst/statements/variable_declaration_statement_node.ph';
import { TypeIdentifierExpressionNode } from '../compilation/cst/type_expressions/type_identifier_expression_node.ph';
import { MsBuildUtils } from '../msbuild.ph';
import { Declaration, ImportTarget, ParsedProject } from '../project_management/parsed_project.ph';
import { ProjectSettings } from '../project_settings.ph';
import { DLLAnalyzer } from './dll_analyzer.ph';
import { ClassDefinition } from './definitions/class_definition.ph';
import { MethodDefinition } from './definitions/method_definition.ph';
import { CSTNode } from '../compilation/cst/basic/cst_node.ph';
import { TypeExpressionNode } from '../compilation/cst/type_expressions/type_expression_node.ph';
import { TypeExpression } from './definitions/type_expression.ph';
// import 'System/Reflection';

export class StaticAnalyzer {
    public readonly mainProject: ParsedProject;
    public readonly projectMap: Collections.Dictionary<string, ProjectSettings>;
    private logger: Logger;
    private referenceAssemblies: DLLAnalyzer[];

    constructor(logger: Logger, projectSettings: ProjectSettings) {
        this.logger = logger;
        this.projectMap = new Collections.Dictionary<string, ProjectSettings>();
        this.mainProject = new ParsedProject(projectSettings, logger);
        MsBuildUtils.InitializeMSBuild();
    }

    public Initialize(): void {
        const dlls = this.GetProjectDLLs();

        // const resolver = new PathAssemblyResolver(dlls);
        // const mlc = new MetadataLoadContext(resolver);

        this.referenceAssemblies = <DLLAnalyzer>[]; //dlls
        //     .Select((dll) => {
        //         return new DLLAnalyzer(mlc, dll);
        //     })
        //     .ToArray();
    }

    //
    // When it's not explicitly specified, the expected type of an expression is inferred from the context.
    //
    public InferExpectedType(context: CSTNode): TypeExpression {
        throw new Exception('Not implemented');
    }

    public GetOverriddenMethod(methodNode: ClassMethodNode, inheritenceChain: Collections.List<ClassDefinition>): MethodDefinition | null {
        for (let i = 1; i < inheritenceChain.Count; i++) {
            const currentClass = inheritenceChain[i];
            for (const method of currentClass.methods) {
                if (method.name == methodNode.name) {
                    return method;
                }
            }
        }

        return null;
    }

    public ResolveImportedFile(from: FileNode, importStatement: ImportStatementNode): ImportTarget | null {
        const importPath = importStatement.importPath;
        if (importPath == null) {
            return null;
        }

        if (importPath.StartsWith('.')) {
            const importPathResolved = Path.Combine(Path.GetDirectoryName(from.path), importPath);
            const importPathResolvedFull = Path.GetFullPath(importPathResolved);
            if (this.mainProject.fileNodes.ContainsKey(importPathResolvedFull)) {
                return this.mainProject.fileNodes[importPathResolvedFull];
            } else {
                return null;
            }
        } else {
            return this.FindAssemblyByNamespace(importPath);
        }
    }

    public FindAssemblyByNamespace(ns: string): Assembly | null {
        ns = ns.Replace('/', '.');

        return null;
    }

    public GetExportedDeclarations(file: FileNode): Collections.Dictionary<string, Declaration> {
        const result = new Collections.Dictionary<string, Declaration>();
        for (const node of CSTHelper.IterateChildren(file)) {
            if (node instanceof ClassNode) {
                if (node.isExported) {
                    result.Add(node.name, node);
                }
            } else if (node instanceof StructNode) {
                if (node.isExported) {
                    result.Add(node.name, node);
                }
            } else if (node instanceof EnumNode) {
                if (node.isExported) {
                    result.Add(node.name, node);
                }
            } else if (node instanceof TypeAliasStatementNode) {
                if (node.isExported) {
                    result.Add(node.name, node);
                }
            }
        }

        return result;
    }

    public GetInheritanceChain(classNode: ClassNode): Collections.List<ClassDefinition> {
        const inheritenceChain = new Collections.List<ClassDefinition>();
        inheritenceChain.Add(ClassDefinition.FromClassNode(classNode));
        let currentClass = classNode;
        while (currentClass.extendsNode != null) {
            const extendee = this.IdentifierToDeclaration(currentClass.extendsNode.identifier, currentClass);
            if (extendee == null) {
                throw new Exception(`Cannot find class ${currentClass.extendsNode.identifier.name} extended by ${currentClass.name}`);
            } else {
                if (extendee instanceof ClassNode) {
                    inheritenceChain.Add(ClassDefinition.FromClassNode(extendee));
                    currentClass = extendee;
                } else {
                    throw new Exception(`Cannot extend ${currentClass.extendsNode.identifier.name} as it is not a class`);
                }
            }
        }

        return inheritenceChain;
    }

    public IdentifierToDeclaration(identifier: TypeIdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null {
        for (const node of CSTHelper.IterateChildrenReverse(scope)) {
            if (node instanceof TypeAliasStatementNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof ImportStatementNode) {
                if (node.namespaceImport == identifier.name) {
                    return node;
                } else {
                    for (const importedValue of node.importSpecifiers) {
                        if (identifier.name == (importedValue.alias?.name ?? importedValue.name)) {
                            const importedFile = this.ResolveImportedFile(identifier.root, node);
                            if (importedFile != null) {
                                if (importedFile instanceof FileNode) {
                                    const exportedDeclarations = this.GetExportedDeclarations(importedFile);
                                    if (exportedDeclarations.ContainsKey(importedValue.name)) {
                                        return exportedDeclarations[importedValue.name];
                                    }
                                } else if (importedFile instanceof Assembly) {
                                    const types = importedFile.GetTypes();
                                    for (const type of types) {
                                        Console.WriteLine(type.Name);
                                    }
                                }
                            } else {
                                return null;
                            }
                        }
                    }
                }
            }
        }

        return null;
    }

    public IdentifierToDeclaration(identifier: IdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null {
        for (const node of CSTHelper.IterateChildrenReverse(scope)) {
            if (node instanceof VariableDeclarationStatementNode) {
                for (const declared of node.declarationList.declarations) {
                    if (declared.name == identifier.name) {
                        return declared;
                    }
                }
            } else if (node instanceof EnumNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof ClassNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof StructNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof FunctionStatementNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof TypeAliasStatementNode) {
                if (node.name == identifier.name) {
                    return node;
                }
            } else if (node instanceof ImportStatementNode) {
                if (node.namespaceImport == identifier.name) {
                    return node;
                } else {
                    for (const importedValue of node.importSpecifiers) {
                        if (identifier.name == (importedValue.alias?.name ?? importedValue.name)) {
                            const importedFile = this.ResolveImportedFile(identifier.root, node);
                            if (importedFile != null) {
                                if (importedFile instanceof FileNode) {
                                    const exportedDeclarations = this.GetExportedDeclarations(importedFile);
                                    if (exportedDeclarations.ContainsKey(importedValue.name)) {
                                        return exportedDeclarations[importedValue.name];
                                    }
                                } else if (importedFile instanceof Assembly) {
                                    const types = importedFile.GetTypes();
                                    for (const type of types) {
                                        Console.WriteLine(type.Name);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return this.FindAmbientDeclaration(identifier, scope);
    }

    public FindAmbientDeclaration(identifier: IdentifierExpressionNode, scope: LogicalCodeUnit): Declaration | null {
        const file = scope.root;

        if (file == null) {
            return null;
        }

        for (const importStatement of file.imports) {
            if (importStatement.isAmbient) {
                const assembly = this.ResolveImportedFile(file, importStatement);
                if (assembly instanceof Assembly) {
                    const types = assembly.GetTypes();
                    for (const type of types) {
                        if (type.Name == identifier.name) {
                            return type;
                        }
                    }
                } else if (assembly instanceof FileNode) {
                    const exportedDeclarations = this.GetExportedDeclarations(assembly);
                    if (exportedDeclarations.ContainsKey(identifier.name)) {
                        return exportedDeclarations[identifier.name];
                    }
                }
            }
        }
        return null;
    }

    private GetProjectDLLs(): string[] {
        // Load the project file
        const projectCollection = new ProjectCollection();
        const project = new MSBuildProject(this.mainProject.settings.csprojPath, null, null, projectCollection);
        const dlls = new Collections.List<string>();
        const frameworkReferences = project.GetItems('FrameworkReference');
        // Framework packs
        for (const frameworkReference of frameworkReferences) {
            const frameworkPack = MsBuildUtils.GetFrameworkPackDLLs(frameworkReference.EvaluatedInclude, this.mainProject.settings.targetFramework);
            if (frameworkPack != null) {
                dlls.AddRange(frameworkPack);
            }
        }

        return dlls.ToArray();
    }
}
