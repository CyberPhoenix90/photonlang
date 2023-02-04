import { CSTNode } from '../../compilation/cst/basic/cst_node.ph';

export class TypeInstance {
    public readonly typeSource: CSTNode;
    public readonly type: string;
    public readonly genericArguments: TypeInstance[];
    public readonly arrayDimensions: int;

    constructor(typeSource: CSTNode, type: string, arrayDimensions: int, genericArguments: TypeInstance[]) {
        this.typeSource = typeSource;
        this.type = type;
        this.arrayDimensions = arrayDimensions;
        this.genericArguments = genericArguments;
    }
}
