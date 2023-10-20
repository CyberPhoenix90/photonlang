import { InterfacePropertyNode } from '../compilation/cst/other/interface_property_node.ph';

export class GetterSetterInterface {
    public readonly getter: InterfacePropertyNode;
    public readonly setter: InterfacePropertyNode;

    constructor(getter: InterfacePropertyNode, setter: InterfacePropertyNode) {
        this.getter = getter;
        this.setter = setter;
    }
}
