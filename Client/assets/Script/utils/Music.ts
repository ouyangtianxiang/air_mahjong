const { ccclass, property } = cc._decorator;
@ccclass
export default class Music {

    private static bgID: number = 0;
    private static onBGMusic(err, url) {
        if (Music.bgID > 0) {
            cc.audioEngine.stop(Music.bgID);
        }
        Music.bgID = cc.audioEngine.play(url, true, 1);
    }

    public static bgMusic(value) {
        cc.loader.load(cc.url.raw('resources/sound/bg/' + value + '.mp3'), Music.onBGMusic);
    }
    ///========================

    private static onEffect(err, url) {
        cc.audioEngine.play(url, false, 1);
    }

    public static effect(value) {
        cc.loader.load(cc.url.raw('resources/sound/effect/' + value + '.mp3'), Music.onEffect);
    }
    ///========================

    private static onVoice(err, url) {
        cc.audioEngine.play(url, false, 1);
    }

    public static language: string = "nanchang";
    public static sex = "woman";

    public static voice(value) {
        cc.loader.load(cc.url.raw('resources/sound/voice/' + Music.language + '/' + Music.sex + '/' + value + '.mp3'), Music.onVoice);
    }

}
