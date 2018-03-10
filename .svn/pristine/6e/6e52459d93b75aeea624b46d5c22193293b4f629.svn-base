const { ccclass, property } = cc._decorator;
import IWindow from "../utils/IWindow"


@ccclass
export default class Tips extends IWindow {
    @property(cc.Label)
    label: cc.Label;

    init(msg:string) {
        this.label.string = msg;
    }
 
    onTouchStart(event: cc.Event.EventTouch) {
        this.close();
    }

    close() {
        this.node.destroy();
    }
}