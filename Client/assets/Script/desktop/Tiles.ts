const { ccclass, property } = cc._decorator;
import Tile from "./Tile"
import IPos from "./IPos"
import Music from "../utils/Music";

@ccclass
export default class Tiles extends IPos {

    @property({ type: [Tile] })
    tiles: Tile[] = [];
    order: number;
    i: number = 0;

    push(o) {
        this.tiles[this.i].obj(o);
        this.tiles[this.i].node.active = true;
        this.i++;
    }

    onLoad() {
        this.tiles.forEach(e => e.node.active = false);
    }

    init(state: number) {
        switch (state) {
            case 3://吃
                Music.voice("chi");
                break;
            case 4://碰
                Music.voice("pang");
                break;
            case 5://明杠
                Music.voice("gang");
                break;
            case 6://暗杠
                Music.voice("angang");
                break;
            case 7://胡牌TTT
                Music.voice("hu");
                break;
        }
    }
}
