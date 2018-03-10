const { ccclass, property } = cc._decorator;
import Buffer from "./Buffer"
import EventHandle from "./EventHandle"

@ccclass
export default class IMEvent<T> {
    private event: cc.EventTarget = new cc.EventTarget();

    addEventListener(type: string, listener: (buffer: T) => void, thisArg: any, once: boolean = false): EventHandle {
        return new EventHandle(type, listener, thisArg, this.event, once);
    }

    addFieldListener(type: string, listener: (obj: T) => void, thisArg: any): EventHandle {
        var eh=new EventHandle(type, listener, thisArg, this.event, false);
        this.dispatchField(type);
        return eh;
    }

    dispatchEvent(type: string, obj: T): void {
        try{
            this.event.emit(type, [obj]);
        }catch (e){
            console.log(e+"-----------------");
        }
    }

    dispatchField(type: string): void {
    }
}