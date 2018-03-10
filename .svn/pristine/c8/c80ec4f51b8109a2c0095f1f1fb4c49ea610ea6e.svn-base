const { ccclass, property } = cc._decorator;
import { U_data } from "../net/Bean"
import Desktop from "./Desktop";
import Player from "./Player";
import Loader from "../utils/Loader";
import EventHandle from "../net/EventHandle"
import { T_tile, T_state, U_room, U_room_level } from "../net/Bean";


@ccclass
export default class Info extends cc.Component {
    @property(cc.Node)
    pos: cc.Node;

    @property()
    dir = 0;

    @property(cc.Node)
    btn: cc.Node;

    @property(cc.Node)
    ok: cc.Node;

    @property(cc.Sprite)
    icon: cc.Sprite;

    @property(cc.Node)
    banker: cc.Node;

    @property(cc.Label)
    nickname: cc.Label;

    @property(cc.Label)
    score: cc.Label;

    @property(Player)
    player:Player;

    room: U_room;
    state: T_state;
    index: number;

    eh: Array<EventHandle> = [];
    onLoad() {
        if (this.dir >= Desktop.it.room.num) {
            this.node.destroy();
            return;
        }
        this.index = Desktop.it.getIndex(this.dir);

        this.eh.push(T_state.table.addEventListener("update", this.onState, this));
        this.eh.push(U_room.table.addFieldListener("state", this.onRoomState, this));
        this.eh.push(U_room_level.table.addEventListener("insert", this.onRoomLevel, this));

        this.room = U_room.table.getObj();
        this.state = T_state.table.getObj(this.index);
        this.onState(this.state);
    }

    onRoomState(o: U_room) {
        if (o.state == 2) {
            this.ok.active = false;
            this.nickname.node.active = false;
            this.node.runAction(cc.moveTo(0.5, this.pos.position));
            if(this.dir==0){
                this.player.sort();
            }
        }
    }

    onRoomLevel(o: U_room_level) {
        var score: number = 0;
        var arr = U_room_level.table.getList(o => o.userId == this.state.userId)
        arr.forEach(o => score += o.score + o.jing);
        this.score.string = "分：" + score;
    }

    onState(o: T_state) {
        if (o.index == this.index) {
            if (o.userId > 1) {

                this.ok.active = true;
                this.nickname.node.active = true;
                this.score.node.active = true;
                this.banker.active = true;
                this.btn.active = false;

                this.ok.active = o.state == 1;
                this.nickname.string = o.nickname;
                this.banker.active = o.index == this.room.banker;
                Loader.LoadSprite(o.url,this.icon);
            } else {
                this.ok.active = false;
                this.nickname.node.active = false;
                this.score.node.active = false;
                this.banker.active = false;
                this.btn.active = true;
            }
        }
    }

    onDestroy() {
        this.eh.forEach(eh => eh.remove());
    }
}
