const { ccclass, property } = cc._decorator;

import IWindow from "../utils/IWindow"
import Global from "../utils/Global";
import Protocol from "../net/Protocol";
import Data from "../net/Data";
import Buffer from "../net/Buffer";

@ccclass
export default class Desktop extends IWindow {

    @property({ type: cc.Node })
    item: cc.Node;


    p = [0, 0, 0, 0, 0, 0, 0, 0];
    start() {
        var data = [
            { name: "游戏局数", d: ["8局(3张房卡)", "16局(6张房卡)", "24局(9张房卡)", "32局(12张房卡)"] },
            { name: "人数", d: ["2人", "3人", "4人"] },
            { name: "爬楼", d: ["牌爬精不爬(逐层下)", "牌爬精不爬(快速下)", "不爬楼"] },
            { name: "回头一笑", d: ["上下回头", "上回头", "不回头"] },
            { name: "下精玩法", d: ["同一首歌(弃牌也算)", "同一首歌(弃牌不算)", "埋地雷(弃牌也算)", "埋地雷(弃牌不算)", "翻下精", "无下精"] },
            { name: "平胡", d: ["有精点炮可平胡", "有精点炮不能平胡"] },
            { name: "杠精玩法", d: ["有杠精", "有杠精"] },
            { name: "抄庄", d: ["抄庄", "不抄庄"] }
        ];

        for (var i = 0; i < data.length - 1; i++) {
            var n: cc.Node = cc.instantiate(this.item);
            n.parent = this.item.parent;
        }

        var arr = this.item.parent.children;
        for (var j in arr) {
            this.fill(arr[j], data[j], parseInt(j));
        }
    }

    fill(item: cc.Node, itemData, j: number) {
        var labelNode: cc.Node = item.getChildByName("Label");
        var label = labelNode.getComponent(cc.Label);
        label.string = itemData["name"];

        var ToggleGroup: cc.Node = item.getChildByName("ToggleGroup");
        var toggle: cc.Node = ToggleGroup.getChildByName("toggle");

        for (var i = 0; i < itemData.d.length - 1; i++) {
            var n = cc.instantiate(toggle);
            n.parent = toggle.parent;
        }

        var arr = ToggleGroup.children;
        for (var k in arr) {
            var o = arr[k];
            if (o) {
                o.name = k;
                o.tag = j;
                this.fill2(o, itemData.d[k]);
            }
        }

    }

    fill2(item, itemData) {
        var labelNode = item.getChildByName("Label");
        var label = labelNode.getComponent(cc.Label);
        label.string = itemData;
    }

    init() {
    }
    // called every frame, uncomment this function to activate update callback
    // update: function (dt) {

    // },

    onToggle(event) {
        this.p[event.target.tag] = event.target.name;
        console.log(event.target.tag, event.target.name);
    }

    onCreate(buffer:Buffer) {
        var index = buffer.getByte();
        var roomCode = buffer.getInt();
        Data.it.index = index;
        Data.it.roomCode = roomCode;
        Global.GotoScene("Desktop");
    }

    onClick() {
        Data.it.im.Call(Protocol.NCMJ_CREATE, this.onCreate, this, this.p[0], this.p[1], this.p[2], this.p[3], this.p[4], this.p[5], this.p[6], this.p[7]);
    }

    onClose() {
        this.node.destroy();
    }
}
