const { ccclass, property } = cc._decorator;
import IWindow from "../utils/IWindow"

@ccclass
export default class Setting extends IWindow {

    @property(cc.Label)
    label: cc.Label;

    @property()
    text: string = 'hello';

    init(param) {

    }

    exit() {
        cc.game.end();
    }

    close() {
        this.node.destroy();
    }
}
