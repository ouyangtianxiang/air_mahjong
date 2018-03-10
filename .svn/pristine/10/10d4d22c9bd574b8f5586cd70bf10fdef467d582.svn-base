const { ccclass, property } = cc._decorator;
import Table from "../net/Table";
import Global from "../utils/Global";
import Protocol from "../net/Protocol";
import Data from "../net/Data";
import Chi from "../desktop/Chi";
import Gang from "../desktop/Gang";
import PengORHu from "../desktop/PengORHu";
import Buffer from "../net/Buffer";
import Tile from "../desktop/Tile";
import IWindow from "../utils/IWindow";
import { T_tile, T_play } from "../net/Bean";

@ccclass
export default class Reply extends IWindow {

    @property({ type: cc.Prefab })
    Pang: cc.Prefab;

    @property({ type: cc.Prefab })
    Gang: cc.Prefab;

    @property({ type: cc.Prefab })
    Chi: cc.Prefab;

    @property({ type: cc.Prefab })
    Hu: cc.Prefab;

    selfmo: boolean = false;

    showGang(value: number, index: number) {
        var node: cc.Node = cc.instantiate(this.Gang);
        var gang = node.getComponent<Gang>(Gang);
        this.node.addChild(node);
        gang.init(index, value, this);
    }

    showChi(a: number, b: number, c: number, index: number) {
        var node: cc.Node = cc.instantiate(this.Chi);
        var chi = node.getComponent<Chi>(Chi);
        this.node.addChild(node);
        chi.init(a, b, c, index, this);
    }

    showBtn(prefab: cc.Prefab, index: number) {
        var node: cc.Node = cc.instantiate(prefab);
        var pengORHu = node.getComponent<PengORHu>(PengORHu);
        this.node.addChild(node);
        pengORHu.init(index, this);
    }


    play(o: T_play) {
        console.log("play()-----" + o.index);
        var type = Math.floor(o.index / 1000);
        var value = o.index % 1000;
        switch (type) {
            case 8:
                this.selfmo = true;
            case 7:
                this.showBtn(this.Hu, o.index);
                break;
            case 6:
                this.selfmo = true;
            case 5:
                this.showGang(value, o.index);
                break;
            case 4:
                this.showBtn(this.Pang, o.index);
                break;
            case 3:
            case 2:
            case 1:
                this.showChi(o.value1, o.value2, o.value3, o.index);
                break;
        }
    }

    onReply(buffer: Buffer) {
        this.close();
    }
    /**
     * 
     * @param type  0:过,1:吃,2:碰,4:杠,8:胡
     * @param value 
     */
    send(index) {
        Data.it.im.Call(Protocol.NCMJ_REPLY, this.onReply, this, this.selfmo, index);
    }

    //过
    guo() {
        this.send(0);
    }
}