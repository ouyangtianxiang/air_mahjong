const { ccclass, property } = cc._decorator;
import IWindow from "../utils/IWindow";
import Loader from "../utils/Loader";

@ccclass
export default class Window<T extends IWindow>{
    private name;
    private param;
    public node: cc.Node;
    public script: T;
    constructor(name, ...param) {
        this.name = name;
        this.param = param;
        this.node = cc.instantiate(Loader.it.GetPrefab(this.name));
        cc.director.getScene().addChild(this.node);
        this.script = this.node.getComponent<T>(this.name);
        if (this.script.init instanceof Function) {
            this.script.init.apply(this.script, this.param);
        }
    }

    close(code: number = 0) {
        if (this.node != null) {
            this.script.close(code);
        }
    }

    Create<W extends IWindow>(name):W {
        var node:cc.Node = cc.instantiate(Loader.it.GetPrefab(name));
        cc.director.getScene().addChild(node);
        var window = node.getComponent<W>(name);
        return window;
    }
}
