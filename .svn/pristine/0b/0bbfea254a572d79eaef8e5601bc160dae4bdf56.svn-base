const { ccclass, property } = cc._decorator;

@ccclass
export default class Loading extends cc.Component {

    @property(cc.Label)
    labelVersion: cc.Label;
    @property(cc.Label)
    labelInfo: cc.Label;
    @property(cc.Label)
    fileLabel: cc.Label;
    @property(cc.Label)
    byteLabel: cc.Label;

    _storagePath: string;
    _assetsManager: jsb.AssetsManager;
    _updateListener: jsb.EventListenerAssetsManager;

    _customManifestStr = JSON.stringify({
        "packageUrl": "http://mj.game1982.com/build/jsb-default/",
        "remoteManifestUrl": "http://mj.game1982.com/build/jsb-default/project.manifest",
        "remoteVersionUrl": "http://mj.game1982.com/build/jsb-default/version.manifest",
        "version": "0.0.0.0",
        "assets": {
        },
        "searchPaths": []
    });



    versionCompareHandle(versionA, versionB) {
        this.labelVersion.string = versionA + '->' + versionB;
        var a = parseInt(versionA.split('.').join(''));
        var b = parseInt(versionB.split('.').join(''));
        return -Math.abs(a - b);
    }


    updateCb(event) {
        switch (event.getEventCode()) {
            case jsb.EventAssetsManager.UPDATE_PROGRESSION:
                this.fileLabel.string = event.getDownloadedFiles() + ' / ' + event.getTotalFiles() + "(" + event.getPercent() + ")";
                this.byteLabel.string = event.getDownloadedBytes() + ' / ' + event.getTotalBytes() + "(" + event.getPercentByFile() + ")";
                break;
            case jsb.EventAssetsManager.ERROR_NO_LOCAL_MANIFEST:
            case jsb.EventAssetsManager.ERROR_DOWNLOAD_MANIFEST:
            case jsb.EventAssetsManager.ERROR_PARSE_MANIFEST:
            case jsb.EventAssetsManager.ERROR_DECOMPRESS:
            case jsb.EventAssetsManager.ERROR_UPDATING:
            case jsb.EventAssetsManager.UPDATE_FAILED:
                this.labelInfo.string = event.getEventCode() + ":" + event.getMessage();
                this._assetsManager.downloadFailedAssets();
                break;
            case jsb.EventAssetsManager.ALREADY_UP_TO_DATE:
                this.labelInfo.string = '已经是最新版本！';
                cc.director.loadScene("Login");
                break;
            case jsb.EventAssetsManager.UPDATE_FINISHED:
                this.labelInfo.string = '更新完成！. ' + event.getMessage();
                cc.eventManager.removeListener(this._updateListener);
                this._updateListener = null;

                var searchPaths = jsb.fileUtils.getSearchPaths();
                var newPaths = this._assetsManager.getLocalManifest().getSearchPaths();
                Array.prototype.unshift(searchPaths, newPaths);

                cc.sys.localStorage.setItem('HotUpdateSearchPaths', JSON.stringify(searchPaths));
                jsb.fileUtils.setSearchPaths(searchPaths);

                cc.audioEngine.stopAll();
                cc.game.restart();
                break;
            default:
                break;
        }
    }

    onLoad() {
        if (!cc.sys.isNative) {
            return;
        }
        this._storagePath = ((jsb.fileUtils ? jsb.fileUtils.getWritablePath() : '/') + 'remote-asset');
        cc.log('Storage path for remote asset : ' + this._storagePath);

        this._assetsManager = new jsb.AssetsManager('', this._storagePath, this.versionCompareHandle.bind(this));
        this._assetsManager.retain();

        if (cc.sys.os === cc.sys.OS_ANDROID) {
            this._assetsManager.setMaxConcurrentTask(2);
        }

        this._updateListener = new jsb.EventListenerAssetsManager(this._assetsManager, this.updateCb.bind(this));
        cc.eventManager.addListener(this._updateListener, 1);

        if (this._assetsManager.getState() === jsb.AssetsManager.State.UNINITED) {
            var manifest = new jsb.Manifest(this._customManifestStr, this._storagePath);
            this._assetsManager.loadLocalManifest(manifest, this._storagePath);
        }
        this._assetsManager.update();
    }

    onDisable() {
        if (this._updateListener) {
            cc.eventManager.removeListener(this._updateListener);
            this._updateListener = null;
        }
        this._assetsManager.release();
    }
}