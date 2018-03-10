const { ccclass, property } = cc._decorator;
import Tile from "./Tile";
import EventHandle from "../net/EventHandle"
import { T_tile, T_state, U_room, U_room_level } from "../net/Bean";


@ccclass
export default class Extractive extends cc.Component {

    @property(cc.Node)
    pos: cc.Node;

    @property({ type: Tile })
    main: Tile;

    @property({ type: Tile })
    vice: Tile;

    eh: Array<EventHandle> = [];
    onLoad() {
        this.eh.push(T_tile.table.addEventListener("update", this.onTile, this));
        var tiles = T_tile.table.getList(o => o.index == 5);
        tiles.forEach(this.onTile.bind(this));
    }

    action() {
        this.node.scale = 3;
        var action0 = cc.scaleTo(0.5, 1, 1);
        action0.easing(cc.easeBackInOut());
        var delay = cc.delayTime(1);

        var action1 = cc.moveTo(0.5, this.pos.position);
        action1.easing(cc.easeBackOut());

        var seq = cc.sequence(action0, delay, action1);
        this.node.runAction(seq);
    }

    onTile(o: T_tile) {
        if (o.index == 5) {
            this.main.obj(o);
            this.vice.value(this.Vice(o.value));
            this.action();
        }
    }

    Vice(value: number): number {
        var arr = [9, 9, 9, 4, 3];
        var p = Math.floor(value / 10);
        return value % 10 == arr[p] ? p * 10 + 1 : value + 1;
    }

    onDestroy() {
        this.eh.forEach(eh => eh.remove());
    }
}
