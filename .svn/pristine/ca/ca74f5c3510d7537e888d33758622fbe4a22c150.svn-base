const { ccclass, property } = cc._decorator;

@ccclass
export default class EventHandle {
    private type: string;
    private obj: any;
    private fun: Function;
    private event: cc.EventTarget;
    private once: boolean;
    constructor(type: string, fun: Function, obj: any, event: cc.EventTarget, once: boolean) {
        this.type = type;
        this.fun = fun;
        this.obj = obj;
        this.event = event;
        this.once = once;
        this.event.on(type, this.callback, this);
    }

    private callback(event: cc.Event.EventCustom) {
        this.fun.apply(this.obj, event.detail);
        if (this.once) {
            this.remove();
        }
    }

    remove() {
        this.event.off(this.type, this.callback, this);
        this.type = null;
        this.fun = null;
        this.obj = null;
        this.event = null;
    }
}
