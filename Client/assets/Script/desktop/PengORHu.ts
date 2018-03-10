const { ccclass, property } = cc._decorator;
import Reply from "../window/Reply";

@ccclass
export default class PengORHu extends cc.Component {

    private index: number;
    private reply: Reply;

    init(index: number, reply: Reply) {
        this.index = index;
        this.reply = reply;
    }

    click() {
        this.reply.send(this.index);
    }
}
