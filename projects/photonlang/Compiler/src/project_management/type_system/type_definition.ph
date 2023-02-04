import { CSTNode } from '../../compilation/cst/basic/cst_node.ph';

export class TypeDefinition {
    public readonly typeSource: CSTNode;
    public readonly type: string;
    public readonly genericArguments: string[];
    public readonly arrayDimensions: int;

    constructor(typeSource: CSTNode, type: string, arrayDimensions: int, genericArguments: string[]) {
        this.typeSource = typeSource;
        this.type = type;
        this.arrayDimensions = arrayDimensions;
        this.genericArguments = genericArguments;
    }

    public ToString(): string {
        let type = this.type;
        if (this.genericArguments.Length > 0) {
            type += `<${string.Join(','[0], this.genericArguments)}>`;
        }
        for (let i = 0; i < this.arrayDimensions; i++) {
            type += '[]';
        }
        return type;
    }
}
