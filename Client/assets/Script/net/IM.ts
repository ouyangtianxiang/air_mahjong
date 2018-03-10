const { ccclass, property } = cc._decorator;
import Data from "./Data";
import Buffer from "./Buffer";
import Window from "../utils/Window";
import IMEvent from "./IMEvent";


@ccclass
export default class IM extends IMEvent<Buffer> {
    data: Data;
    socket: WebSocket;

    PARAM_TYPE = [];
    wait: Window;
    constructor(data: Data, url: string) {
        super();
        this.data = data;

        this.socket = new WebSocket(url);
        this.wait = new Window("Wait", "正在连接服务器");

        this.socket.onopen = function (event) {
            data.onOpen(event);
        };
        this.socket.onerror = function (event) {
            data.onError(event);
        };
        this.socket.onclose = function (event) {
            data.onClose(event);
        };
        this.socket.onmessage = this.onMessage.bind(this);
    }

    onMessage(e) {
        if (e.data instanceof ArrayBuffer) {
            this.handler(e.data);
        } else if (e.data instanceof Blob) {
            var reader = new FileReader();
            reader.readAsArrayBuffer(e.data);
            reader.onload = function (e) {
                this.handler(reader.result);
            }.bind(this);
        }
    }

    handler(arrayBuffer: ArrayBuffer) {
        var buffer: Buffer = new Buffer(arrayBuffer);
        var code = buffer.getUByte();
        switch (code) {
            case 0:
                this.data.Init(buffer);
                break;
            case 1:
                this.data.Insert(buffer);
                break;
            case 2:
                this.data.Delete(buffer);
                break;
            case 3:
                this.data.Update(buffer);
                break;
            case 4:
                while (buffer.remaining() > 0) {
                    var c = buffer.getUByte();
                    var len = buffer.getByte();
                    var pTypes = [];
                    for (var i = 0; i < len; i++) {
                        pTypes[i] = buffer.getByte();
                    }
                    this.PARAM_TYPE[c] = pTypes;
                }
                break;
            case 5:
                var time = buffer.getLong();
                var str = buffer.getUTF();
                this.data.onServerTime(time, str);
                this.wait.close();
                break;
            case 9:
                throw "ServerError:\n" + buffer.getUTF();
            default:
                this.wait.close(code);
                this.dispatchEvent(code.toString(), buffer);
                break;
        }

    }

    Call(code, callback?: (buffer: Buffer) => void, target?, ...param: any[]) {
        if (callback != null) {
            this.addEventListener(code, callback, target, true);
            this.wait = new Window("Wait", code, code);
        }
        var buffer: Buffer = new Buffer(new ArrayBuffer(256));
        buffer.putUByte(code);
        if (param.length > 0) {
            buffer.putArray(this.PARAM_TYPE[code], param);
        }
        buffer.flip();
        this.socket.send(buffer.getData());
    }

    close() {
        this.socket.close();
    }
}
