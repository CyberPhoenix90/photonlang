import { StructPropertyNode } from '../compilation/cst/other/struct_property_node.ph';

export class GetterSetterStruct {
    public readonly getter: StructPropertyNode;
    public readonly setter: StructPropertyNode;

    constructor(getter: StructPropertyNode, setter: StructPropertyNode) {
        this.getter = getter;
        this.setter = setter;
    }
}
