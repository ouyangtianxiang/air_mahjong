const { ccclass, property } = cc._decorator;

import Data from "../net/Data";
import Window from "../utils/Window"
import Protocol from "../net/Protocol";
import Player from "./Player";
import Desktop from "./Desktop"
import EventHandle from "../net/EventHandle"
import ExitRoom from "../window/ExitRoom";
import { T_tile, T_state, U_room, U_room_level } from "../net/Bean";

@ccclass
export default class UI extends cc.Component {


    @property({ type: cc.Label })
    RoomId: cc.Label;
    @property({ type: cc.Label })
    remainingTile: cc.Label;
    @property({ type: cc.Label })
    level: cc.Label;

    @property({ type: cc.Node })
    PrepareBtn: cc.Node;

    exitRoom: Window<ExitRoom>;

    eh: Array<EventHandle> = [];

    onLoad() {
        this.RoomId.string = "房间号：" + Data.it.roomCode;
        this.eh.push(T_state.table.addFieldListener("state", this.onState, this));
        this.eh.push(T_state.table.addFieldListener("exit", this.onExit, this));
        this.eh.push(T_state.table.addFieldListener("useVIP",this.onUseVIP,this));
        this.eh.push(U_room.table.addFieldListener("curLevel", this.onCurLevel, this));
        this.eh.push(U_room.table.addFieldListener("remainingTile", this.onRemainingTile, this));
    }

    onState(o: T_state) {
        if (o.index == Data.it.index) {
            this.PrepareBtn.active = o.state == 0;
            if(o.state==1){
                Desktop.it.clear();
            }
        }
    }

    onCurLevel(room: U_room) {
        this.level.string = "局数(" + room.curLevel + "/" + room.sumLevel + ")";
    }

    onRemainingTile(room: U_room) {
        this.remainingTile.string = "剩余(" + room.remainingTile + ")张";
    }

    onExit(o: T_state) {
        if (o.exit > 0) {
            if (this.exitRoom == null) {
                this.exitRoom = new Window<ExitRoom>("ExitRoom", this);
            } else {
                this.exitRoom.script.flush();
            }
        } else {
            if (this.exitRoom != null) {
                this.exitRoom.close();
                this.exitRoom = null;
            }
        }
    }

    onUseVIP(o:T_state) {
        if(o.index==Data.it.index){
            if(o.useVIP==1) {
                new Window("CardDrafting");
            }
        }
    }

    prepare() {
        Data.it.im.Call(Protocol.NCMJ_PREPARE);
    }

    exit(event,type: number) {
        Data.it.im.Call(Protocol.NCMJ_EXIT, null, null, type);
    }

    onDestroy() {
        this.eh.forEach(eh => eh.remove());
    }
}
