const { ccclass, property } = cc._decorator;

@ccclass
export default class HUState extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    onLoad() {
    }

    hide() {
        this.node.destroy();
    }
    array={0:"天胡", 1:"小七对", 2:"七星十三烂", 3:"十三烂", 4:"德国", 5:"大七对", 6:"抢杠", 7:"杠上开花", 8:"德中德", 9:"精吊",100:"自摸", 101:"放炮", 102:"霸王精", 103:"冲关"};
    push(type: number, value: number) {
        this.label.string += this.array[type] + "/";
    }
}
