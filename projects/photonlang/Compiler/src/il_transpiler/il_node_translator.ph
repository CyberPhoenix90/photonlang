import 'System/Linq';
import { StringBuilder } from 'System/Text';
import { StatementNode } from '../compilation/cst/statements/statement.ph';
import { ParsedProject } from '../project_management/parsed_project.ph';
import { ProjectSettings } from '../project_settings.ph';
import { StaticAnalyzer } from '../static_analysis/static_analyzer.ph';

export class IlNodeTranslator {
    private staticAnalyzer: StaticAnalyzer;
    private project: ParsedProject;
    private projectSettings: ProjectSettings;

    constructor(staticAnalyzer: StaticAnalyzer, projectSettings: ProjectSettings) {
        this.staticAnalyzer = staticAnalyzer;
        this.project = staticAnalyzer.mainProject;
        this.projectSettings = projectSettings;
    }

    public TranslateStatement(statementNode: StatementNode, output: StringBuilder): void {}
}
