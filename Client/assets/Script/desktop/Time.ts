const { ccclass, property } = cc._decorator;

import Player from "./Player";
import Music from "../utils/Music";
import EventHandle from "../net/EventHandle";
import Desktop from "./Desktop";
import { T_tile, T_state, U_room, U_room_level } from "../net/Bean";

@ccclass
export default class Time extends cc.Component {
    private rotations: Array<number> = [0, 270, 180, 90];

    @property({ type: cc.Label })
    time: cc.Label;

    @property({ type: cc.Node })
    playTips: cc.Node;
    eh: EventHandle;
    onLoad() {
        this.hide();
        this.eh = U_room.table.addEventListener("update", this.onRoom, this);
        this.onRoom();
    }

    onRoom() {
        if (!this.node.active && Desktop.it.room.state == 2) {
            this.show();
        }
        if (Desktop.it.room.play >= 0) {
            Music.effect(1);
            this.time.string = Desktop.it.room.time.toString();
            this.playTips.active = true;
            var i = Desktop.it.getIndex(Desktop.it.room.play);
            this.playTips.rotation = this.rotations[i];
        } else {
            this.time.string = "";
            this.playTips.active = false;
        }
    }

    show() {
        this.node.active = true;

        this.node.scale = 0.3;
        var action0 = cc.scaleTo(0.5, 1, 1);
        action0.easing(cc.easeBackInOut());
        this.node.runAction(action0);
    }

    hide() {
        this.node.active = false;
    }

    onDestroy() {
        this.eh.remove();
    }
}
