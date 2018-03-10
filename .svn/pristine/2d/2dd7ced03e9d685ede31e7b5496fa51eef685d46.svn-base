const { ccclass, property } = cc._decorator;

@ccclass
export default class HashMap<T extends cc.Component> {

    private map: object = {};
    public get size() {
        var n = 0;
        for (var k in this.map) {
            n++
        }
        return n;
    }

    public Put(key, value: T) {
        this.map[key] = value;
    }

    public Get(key): T {
        return this.map[key];
    }

    public remove(key): T {
        var o: T = this.map[key];
        delete this.map[key];
        return o;
    }

    public toArray(): Array<T> {
        var array: Array<T> = [];
        for (var k in this.map) {
            array.push(this.map[k]);
        }
        return array;
    }


    public clear() {
        for (var k in this.map) {
            var o: T = this.map[k];
            o.node.destroy();
        }
        this.map = {};
    }
}
