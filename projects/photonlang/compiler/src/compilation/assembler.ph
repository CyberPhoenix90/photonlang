import { ProjectSettings } from '../project_settings.ph';

export class Assembler {
    public readonly projectSettings: ProjectSettings;

    constructor(projectSettings: ProjectSettings) {
        this.projectSettings = projectSettings;
    }

    public Parse(): void {}
    public Validate(): void {}
    public Emit(): void {}
}
