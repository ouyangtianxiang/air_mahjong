const { ccclass, property } = cc._decorator;
import { T_state } from "../net/Bean";
import Data from "../net/Data";
import Loader from "../utils/Loader";
import UI from "../desktop/UI";
import IWindow from "../utils/IWindow";
import Window from "../utils/Window";
import ExitRoomItem from "../desktop/ExitRoomItem";

@ccclass
export default class ExitRoom extends IWindow {

    @property({ type: [ExitRoomItem] })
    items: ExitRoomItem[] = [];

    @property({ type: [cc.SpriteFrame] })
    stateIMG: cc.SpriteFrame[] = [];

    @property(cc.Node)
    btn1: cc.Node;
    @property(cc.Node)
    btn2: cc.Node;


    onLoad() {
    }

    ui: UI;
    init(ui: UI) {
        this.ui = ui;
        this.flush();
    }

    flush() {
        for (var i = 0; i < 4; i++) {
            var o = T_state.table.getObj(i);
            var item = this.items[i];
            if (o != null) {
                Loader.LoadSprite(o.url, item.icons);
                item.states.spriteFrame = this.stateIMG[o.exit];
                item.nicknames.string = o.nickname;
            } else {
                item.node.active = false;
            }
        }

        var obj = T_state.table.getObj(Data.it.index);
        this.btn1.active = obj.exit == 0;
        this.btn2.active = obj.exit == 0;
    }

    onClick(event, type: number) {
        this.ui.exit(event, type);
    }
}
