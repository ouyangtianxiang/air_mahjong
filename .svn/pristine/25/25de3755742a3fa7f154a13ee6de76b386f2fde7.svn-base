const { ccclass, property } = cc._decorator;
import Tile from "./Tile";
import Reply from "../window/Reply";

@ccclass
export default class Gang extends cc.Component {
    @property({ type: Tile })
    tile1: Tile;

    private index: number;
    private reply: Reply;

    init(index: number, value: number, reply: Reply) {
        this.tile1.id(value);
        this.reply = reply;
        this.index = index;
    }

    click() {
        this.reply.send(this.index);
    }
}
