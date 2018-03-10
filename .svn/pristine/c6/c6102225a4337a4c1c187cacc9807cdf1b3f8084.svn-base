const { ccclass, property } = cc._decorator;
import Tile from "./Tile";
import Reply from "../window/Reply";

@ccclass
export default class Chi extends cc.Component {

    @property({ type: Tile })
    tile1: Tile;
    @property({ type: Tile })
    tile2: Tile;
    @property({ type: Tile })
    tile3: Tile;

    private index: number;
    private reply: Reply;

    init(a: number, b: number, c: number, index: number, reply: Reply) {
        this.tile1.id(a);
        this.tile2.id(b);
        this.tile3.id(c);
        this.index = index;
        this.reply = reply;
    }

    click() {
        this.reply.send(this.index);
    }
}
