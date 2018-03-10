const { ccclass, property } = cc._decorator;

@ccclass
export default class Loader {
    public static it: Loader = new Loader();

    public static LoadSprite(url: string, sprite: cc.Sprite) {
        cc.loader.load(url, (err, texture) => {
            sprite.spriteFrame.setTexture(texture);
        });
    }

    private array: Array<string> = [
        "CardDrafting",
        "CreateRoom",
        "DataView",
        "ExitRoom",
        "InputBox",
        "IntoRoom",
        "Reply",
        "Setting",
        "TableView",
        "Tips",
        "Wait"
    ];
    
    private objs: object = {};
    private name: string;
    private callback: Function;
    public PrefabLoad(callback: Function) {
        this.callback = callback;
        if (this.array.length > 0) {
            this.name = this.array.pop();
            cc.loader.loadRes("window/" + this.name, this.onLoadRes.bind(this));
        } else {
            callback();
        }
    }

    private onLoadRes(err, prefab) {
        this.objs[this.name] = prefab;
        this.PrefabLoad(this.callback);
    }

    public GetPrefab(name: string) {
        return this.objs[name];
    }
}
