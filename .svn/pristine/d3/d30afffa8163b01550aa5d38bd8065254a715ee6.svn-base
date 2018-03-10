const { ccclass, property } = cc._decorator;
import Desktop from "./Desktop"
import Protocol from "../net/Protocol";
import Data from "../net/Data";
import Tile from "./Tile"


@ccclass
export default class TileTouch extends cc.Component {

    public static it: TileTouch;

    _prepare: boolean = false;
    isMove: boolean = false;

    prepare(value: boolean) {
        if (this._prepare != value) {

            this._prepare = value;
            if (value) {
                this.node.y += 50;
            } else {
                this.node.y -= 50;
            }
        }
    }
    onMove() {
        this.isMove = false;
    }

    moveTo(x: number, y: number) {
        this._prepare = false;
        this.node.stopAllActions();
        this.isMove = true;
        var v = this.node.x - x;
        if (v > 120) {
            var a1 = cc.moveBy(0.1, 0, 98);
            var a2 = cc.moveBy(v / 1200, -v, 0);
            var a3 = cc.moveTo(0.1, x, y);
            var a4 = cc.callFunc(this.onMove, this);
            this.node.runAction(cc.sequence(a1, a2, a3, a4));
        } else {
            var a5 = cc.moveTo(0.3, x, y);
            var a6 = cc.callFunc(this.onMove, this);
            this.node.runAction(cc.sequence(a5, a6));
        }
    }

    onTouchStart(event: TouchEvent) {
        if (!this.isMove) {
            if (!this._prepare) {
                if (TileTouch.it) {
                    TileTouch.it.prepare(false);
                }
                this.prepare(true);
                TileTouch.it = this;
            } else {
                if (Desktop.it.room.play == Desktop.it.state.index) {
                    var tile: Tile = this.node.getComponent<Tile>(Tile);
                    Data.it.im.Call(Protocol.NCMJ_PLAY, null, null, tile.o.id);
                }
            }
        }
    }

    onLoad() {
        this.node.on(cc.Node.EventType.TOUCH_START, this.onTouchStart, this);
    }

    onDisable() {
        this.node.off(cc.Node.EventType.TOUCH_START, this.onTouchStart, this);
        if (TileTouch.it == this) {
            TileTouch.it = null;
        }
    }
}
