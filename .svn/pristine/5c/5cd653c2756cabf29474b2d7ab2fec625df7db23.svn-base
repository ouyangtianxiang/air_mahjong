const { ccclass, property } = cc._decorator;
import IWindow from "../utils/IWindow"


@ccclass
export default class Wait extends IWindow {
    @property(cc.Label)
    label: cc.Label;
    @property(cc.Node)
    img: cc.Node;

    code = 0;

    init(code: number, msg: string) {
        this.code = code;
        if (msg) {
            this.label.string = msg;
        }
    }

    update(dt) {
        this.img.rotation += 30;
    }

    close(code: number = 0) {
        if (code == 0 || this.code == code) {
            this.node.destroy();
        }
    }
}