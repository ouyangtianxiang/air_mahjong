const { ccclass, property } = cc._decorator;
import Seat from "./Seat";

@ccclass
export default class MJRoom extends cc.Component {
    @property(cc.Label)
    roomId: cc.Label;
    @property(cc.Label)
    roomName: cc.Label;
    @property(cc.Label)
    password: cc.Label;

    @property(cc.Node)
    btn: cc.Node;

    @property({ type: [Seat] })
    icon: Seat[] = [];

    init() {
        this.roomId.string = "9999";
        this.roomName.string = "南昌宁";
        this.password.string = "1234";
    }

    click() {
        console.log("11111");
    }

    setting() {
        console.log("22222");
    }
}
