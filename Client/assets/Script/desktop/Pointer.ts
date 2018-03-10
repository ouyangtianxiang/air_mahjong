const { ccclass, property } = cc._decorator;

@ccclass
export default class Pointer extends cc.Component {

    private static it: Pointer;

    onLoad() {
        if (Pointer.it && Pointer.it.node) {
            Pointer.it.node.destroy();
        }
        Pointer.it = this;

        this.up();
    }

    up() {
        this.node.runAction(cc.sequence(cc.moveTo(0.3, 0, 20), cc.callFunc(this.down, this)));
    }
    down() {
        this.node.runAction(cc.sequence(cc.moveTo(0.3, 0, 0), cc.callFunc(this.up, this)));
    }
}
