import { ClassPropertyNode } from '../compilation/cst/other/class_property_node.ph';

export class GetterSetterClass {
    public readonly getter: ClassPropertyNode;
    public readonly setter: ClassPropertyNode;

    constructor(getter: ClassPropertyNode, setter: ClassPropertyNode) {
        this.getter = getter;
        this.setter = setter;
    }
}
