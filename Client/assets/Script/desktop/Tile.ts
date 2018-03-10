const { ccclass, property } = cc._decorator;
import Desktop from "./Desktop";
import TileTouch from "./TileTouch"
import IPos from "./IPos"
import { T_tile } from "../net/Bean";

@ccclass
export default class Tile extends IPos {

    @property({ type: cc.Sprite })
    img: cc.Sprite;
    @property({ type: cc.Sprite })
    jing: cc.Sprite;

    o: any;
    touch: TileTouch;

    onLoad() {
        this.touch = this.getComponent<TileTouch>(TileTouch);
    }

    id(v) {
        var o = T_tile.table.getObj(v);
        this.value(o.value);
    }

    value(v) {
        if (this.img) {
            this.img.spriteFrame = Desktop.it.pa.getSpriteFrame(v);
        }
    }

    obj(o: any) {
        this.o = o;
        this.value(o.value)
        if (this.jing) {
            if (o.jing > 0) {
                this.jing.node.active = true;
                if (o.jing == 2) {
                    this.jing.node.color = cc.color(0, 0, 255, 255);
                }
            } else {
                this.jing.node.active = false;
            }
        }
    }


    moveTo(x: number, y: number) {
        if (this.node.x != x || this.node.y != y) {
            if (this.touch) {
                this.touch.moveTo(x, y);
            } else {
                this.pos(x, y);
            }
        }
    }

    moveBy(x: number, y: number) {
        if (this.node.x != x || this.node.y != y) {
            this.node.runAction(cc.moveBy(0.1, x, y));
        }
    }
}
