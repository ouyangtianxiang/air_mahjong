const { ccclass, property } = cc._decorator;
import IWindow from "../utils/IWindow"

@ccclass
export default class Login extends IWindow {
    @property(cc.EditBox)
    edit: cc.EditBox;
    @property(cc.Label)
    label: cc.Label;
    callback: Function;
    target: null;

    init(msg:string,callback:Function,def:string) {
        this.label.string = msg;
        this.callback = callback;
        if (def) {
            this.edit.string = def;
        }
    }

    click() {
        this.callback(this.edit.string);
        this.close();
    }

    close() {
        this.node.destroy();
    }
}
