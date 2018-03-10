const { ccclass, property } = cc._decorator;
import Pai from "../desktop/Pai"
import Protocol from "../net/Protocol";
import Data from "../net/Data";
import Desktop from "../desktop/Desktop";
import IWindow from "../utils/IWindow"
import { T_tile } from "../net/Bean";

@ccclass
export default class CardDrafting extends IWindow {
    @property({ type: cc.SpriteAtlas })
    pa: cc.SpriteAtlas;

    @property({ type: cc.Prefab })
    pia: cc.Prefab;

    create(obj: any) {
        var o: cc.Node = cc.instantiate(this.pia);
        var pai: Pai = o.getComponent<Pai>(Pai);
        pai.init(this, obj, this.pa);
        this.node.addChild(o);
    }

    start() {
        console.log("1111111111");
        var array = T_tile.table.getList(a => a.index == -1);
        array.forEach(o => {
            this.create(o);
        });
    }

    init() {

    }

    save(id: number) {
        console.log("222222222");
        Data.it.im.Call(Protocol.NCMJ_USER_VIP, null, null, id);
        this.node.destroy();
    }
}
