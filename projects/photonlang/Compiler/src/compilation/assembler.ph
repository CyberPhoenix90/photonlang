import { Logger } from 'Logging/src/logging';
import { Process, ProcessStartInfo } from 'System/Diagnostics';
import { Path } from 'System/IO';
import { ProjectSettings } from '../project_settings.ph';
import { ParsedProject } from '../project_management/parsed_project.ph';
import { CSharpTranspiler } from '../cs_transpiler/csharp_transpiler.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';
import { ProjectFileEmit } from '../emit/projectfile.ph';

export class Assembler {
    public readonly projectSettings: ProjectSettings;
    private readonly staticAnalyzer: StaticAnalyzer;
    private readonly project: ParsedProject;
    private readonly logger: Logger;

    constructor(projectSettings: ProjectSettings, staticAnalyzer: StaticAnalyzer, logger: Logger) {
        this.projectSettings = projectSettings;
        this.staticAnalyzer = staticAnalyzer;
        this.logger = logger;
        new ProjectFileEmit(this.projectSettings, this.project, this.logger).Emit();
        staticAnalyzer.Initialize();
    }

    public Parse(): void {
        const project = this.staticAnalyzer.mainProject;
        project.Parse();
    }
    public Validate(): void {}

    public Emit(): void {
        const project = this.staticAnalyzer.mainProject;
        this.logger.Debug(`Emitting assembly for project ${this.projectSettings.name}`);
        const transpiler = new CSharpTranspiler(this.projectSettings, this.staticAnalyzer, project, this.logger);
        transpiler.Emit();
    }

    public Build(): void {
        const process = new ProcessStartInfo();
        process.WorkingDirectory = Path.Join(this.projectSettings.projectPath, this.projectSettings.outdir);
        process.FileName = 'dotnet';
        process.Arguments = 'build --property WarningLevel=0';

        Process.Start(process).WaitForExit();
    }
}
