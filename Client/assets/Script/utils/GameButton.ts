const { ccclass, property } = cc._decorator;

import Music from "./Music";
@ccclass
export default class GameButton extends cc.Component {

    @property({
        type: cc.Component.EventHandler
    })
    onClick: cc.Component.EventHandler;

    x: number;
    y: number;
    onLoad() {
        this.node.on(cc.Node.EventType.TOUCH_START, this.onTouchStart, this);
    }

    onTouchStart(event: cc.Event.EventTouch) {
        event.stopPropagation();
        this.node.on(cc.Node.EventType.TOUCH_END, this.onTouchEnd, this);
        this.node.on(cc.Node.EventType.TOUCH_MOVE, this.onTouchMove, this);
        this.node.scale = 1.1;
        this.x = event.getLocationX();
        this.y = event.getLocationY();
    }

    onTouchEnd(event) {
        if (this.onClick) {
            this.onClick.emit([this.onClick.customEventData]);
        }
        this.end();
        Music.effect(2);
    }

    onTouchMove(event: cc.Event.EventTouch) {
        var x = this.x - event.getLocationX();
        var y = this.y - event.getLocationY();
        if (Math.sqrt(x * x + y * y) > 10) {
            this.end();
        }
    }

    end() {
        this.node.scale = 1;
        this.node.off(cc.Node.EventType.TOUCH_END, this.onTouchEnd, this);
        this.node.off(cc.Node.EventType.TOUCH_MOVE, this.onTouchMove, this);
    }

}
