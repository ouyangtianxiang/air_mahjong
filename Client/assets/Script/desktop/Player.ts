
const { ccclass, property } = cc._decorator;
import Desktop from "./Desktop";
import IPos from "./IPos";
import HUState from "./HUState";
import Tile from "./Tile";
import Tiles from "./Tiles";
import HashMap from "../utils/HashMap";
import Music from "../utils/Music";
import EventHandle from "../net/EventHandle"
import { T_tile, T_state, U_room, U_room_level } from "../net/Bean";


@ccclass
export default class Player extends cc.Component {

    @property({ type: cc.Prefab })
    huStatePrefab: cc.Prefab;

    @property()
    dir = 0;

    @property({ type: cc.Prefab, tooltip: "竖牌Prefab" })
    H: cc.Prefab;

    @property({ type: cc.Prefab })
    W: cc.Prefab;

    @property({ type: cc.Prefab })
    Tiles: cc.Prefab;

    @property({ type: cc.Rect })
    private p0: cc.Rect = cc.rect();

    @property({ type: cc.Rect })
    private p1: cc.Rect = cc.rect();

    @property({ type: cc.Rect })
    private p2: cc.Rect = cc.rect();

    @property({ type: cc.Vec2 })
    mv: cc.Vec2 = new cc.Vec2();

    @property()
    horizontal: boolean = true;

    @property()
    num: number = 9;

    huState: HUState;
    index: number;
    rank: boolean = true;

    map: HashMap<Tile> = new HashMap<Tile>();
    map2: HashMap<Tile> = new HashMap<Tile>();
    groups: HashMap<Tiles> = new HashMap<Tiles>();

    eh: Array<EventHandle> = [];
    onLoad() {
        if (this.dir >= Desktop.it.room.num) {
            this.node.destroy();
            return;
        }

        this.eh.push(T_tile.table.addEventListener("update", this.onTile, this));
        this.eh.push(U_room_level.table.addEventListener("insert",this.onRoomLevel,this));

        this.index = Desktop.it.getIndex(this.dir);
        var tiles = T_tile.table.getList(o => o.index == this.index);
        tiles.forEach(this.onTile.bind(this));
    }

    /**
     * 胡牌
     */
    onRoomLevel(o:U_room_level) {
        if (o.index == this.index) {

        }
    //     var size = bufferffer.getByte();
    //
    //     var index = buffer.getByte();
    //     var FangPao = buffer.getByte();
    //     if (FangPao >= 0) {
    //         this.array[FangPao].showHUState(101);
    //     } else {
    //         this.array[index].showHUState(100);
    //     }
    //     var baWangJing = buffer.getByte();
    //     if (baWangJing >= 0) {
    //         this.array[baWangJing].showHUState(102);
    //     }
    //     for (var i = 3; i < size; i++) {
    //         var value = buffer.getByte();
    //         this.array[index].showHUState(value);
    //     }
    //
    //     this.array[o.userId].showHUState(o);
    // }
    //
    // showHUState(type: number, value: number = 0) {
    //     if (this.huState == null) {
    //         var node = cc.instantiate(this.huStatePrefab);
    //         this.huState = node.getComponent<HUState>(HUState);
    //         this.node.addChild(node);
    //     }
    //     this.huState.push(type, value);
    }

    pushTiles(o): Tiles {
        var tiles: Tiles = this.groups.Get(o.order);
        if (tiles == null) {
            var node = cc.instantiate(this.Tiles);
            tiles = node.getComponent<Tiles>(Tiles);
            this.node.addChild(node);
            tiles.init(o.state);
            tiles.order = o.order;
            tiles.pos(this.p0.x + this.groups.size * this.p0.width, this.p0.y + this.groups.size * this.p0.height);
            this.groups.Put(o.order, tiles);
        }
        tiles.push(o);
        return tiles;
    }

    pushTile(o): Tile {
        var tile: Tile = this.map.Get(o.id);
        if (tile == null) {
            var node: cc.Node = cc.instantiate(this.H);
            tile = node.getComponent<Tile>(Tile);
            this.node.addChild(node);
            var p = this.pos(this.map.size);
            tile.pos(p.x, p.y);
            this.map.Put(o.id, tile);
        }
        tile.obj(o);
        return tile;
    }

    pushTile2(o): Tile {
        var tile: Tile = this.map2.Get(o.id);
        if (tile == null) {
            var node: cc.Node = cc.instantiate(this.W);
            var tile: Tile = node.getComponent<Tile>(Tile);
            this.node.addChild(node);
            if (this.horizontal) {
                tile.pos(this.p2.x + this.map2.size % this.num * this.p2.width, this.p2.y + Math.floor(this.map2.size / this.num) * this.p2.height);
            } else {
                tile.pos(this.p2.x + Math.floor(this.map2.size / this.num) * this.p2.width, this.p2.y + this.map2.size % this.num * this.p2.height);
            }
            this.map2.Put(o.id, tile);
        }
        tile.obj(o);
        return tile;
    }

    onTile(o: T_tile) {
        if (o.index == this.index) {
            switch (o.state) {
                case 0:
                    this.pushTile(o);
                    break;
                case 1:
                    var tile = this.pushTile(o);
                    tile.moveBy(this.mv.x, this.mv.y);
                    break;
                case 2:
                    break;
                case 3://吃
                case 4://碰
                case 5://明杠
                case 6://暗杠
                case 7://胡牌TTT
                case 8://胡牌TT
                    this.pushTiles(o);
                    this.removeTile(o);
                    break;
                case 10://出牌
                    Music.voice(o.value);
                    this.removeTile(o);
                    var tile = this.pushTile2(o);
                    var pointer = cc.instantiate(Desktop.it.pointer);
                    tile.node.addChild(pointer);
                    break;
                case 11:
                    this.pushTile2(o);
                    break;
            }
        } else {
            this.removeTile(o);
            this.removeTile2(o);
        }
    }
    update() {
        if (this.rank) {
            this.rank = false;
            this.sort();
        }
    }

    pos(i: number) {
        var x = this.p1.x + i * this.p1.width + this.groups.size * this.p0.width;
        var y = this.p1.y + i * this.p1.height + this.groups.size * this.p0.height;
        return new cc.Vec2(x, y);
    }

    sort() {
        var array: Array<Tile> = this.map.toArray();
        array.sort((a: Tile, b: Tile) => a.o.id - b.o.id);
        for (var i = 0; i < array.length; i++) {
            var p = this.pos(i);
            array[i].moveTo(p.x, p.y);
        }
    }

    removeTile(o) {
        var tile: Tile = this.map.Get(o.id);
        if (tile) {
            this.map.remove(o.id);
            tile.node.destroy();
            this.rank = true;
        }
    }

    removeTile2(o) {
        var tile: Tile = this.map2.Get(o.id);
        if (tile) {
            this.map2.remove(o.id);
            tile.node.destroy();
            this.rank = true;
        }
    }

    clear() {
        if(this.node!=null) {
            this.map.clear();
            this.map2.clear();
            this.groups.clear();
            if (this.huState) {
                this.huState.hide();
                this.huState = null;
            }
        }
    }

    onDestroy() {
        this.eh.forEach(eh => eh.remove());
    }
}
