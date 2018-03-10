const { ccclass, property } = cc._decorator;

import IWindow from "../utils/IWindow"
import Global from "../utils/Global";
import Protocol from "../net/Protocol";
import Data from "../net/Data";
import Window from "../utils/Window"
import Buffer from "../net/Buffer"

@ccclass
export default class Desktop extends IWindow {

    @property([cc.Label])
    label: cc.Label[] = [];

    str = "";

    start() {
        this.fill();
    }

    fill() {
        for (var i = 0; i < this.label.length; i++) {
            this.label[i].string = this.str.length>i?this.str[i]:"";
        }
    }

    init() {

    }

    onKey(event, value) {
        switch (value) {
            case 'D':
                if (this.str.length > 0) {
                    this.str = this.str.substr(0, this.str.length - 1);
                } else {
                    return;
                }
                break;
            case 'C':
                this.str = "";
                break;
            default:
                if (this.str.length < this.label.length) {
                    this.str += value;
                    if (this.str.length == this.label.length) {
                        this.intoRoom();
                    }
                }

        }
        this.fill();
        console.log(this.str);
    }

    onIntoRoom(buffer: Buffer) {
        var index = buffer.getByte();
        if (index >= 0) {
            var roomCode = buffer.getInt();
            Data.it.index = index;
            Data.it.roomCode = roomCode;
            Global.GotoScene("Desktop");
        } else if (index == -1) {
            new Window("Tips", "房间已满！")
        } else if (index == -2) {
            new Window("Tips", "房间不存在！")
        }
    }

    intoRoom() {
        Data.it.im.Call(Protocol.NCMJ_INTO, this.onIntoRoom, this, parseInt(this.str));
    }

    onClose() {
        this.node.destroy();
    }
}
