-- ***** --
-- author : nextcy
-- ***** --
require("MahjongData/GlobalDataManager");

NativeManager = class();
NativeManager.instance = nil;

-- 原生事件
NativeManager._Event = EventDispatcher.getInstance():getUserEvent();

function NativeManager.getInstance()
    if not NativeManager.instance then
        NativeManager.instance = new(NativeManager);
    end
    return NativeManager.instance;
end

function NativeManager.ctor( self )
    EventDispatcher.getInstance():register(Event.Call, self, self.callEvent);
    EventDispatcher.getInstance():register(Event.Resume, self, self.nativeEventResume);
    EventDispatcher.getInstance():register(Event.Pause, self, self.nativeEventPause);
end

function NativeManager.dtor( self )
    NativeManager.instance = nil;
    EventDispatcher.getInstance():unregister(Event.Call, self, self.callEvent);
    EventDispatcher.getInstance():unregister(Event.Resume, self, self.nativeEventResume);
    EventDispatcher.getInstance():unregister(Event.Pause, self, self.nativeEventPause);
end

-- 下载一张图片
-- 1.如果存在,则返回true + imageDir
-- 2.如果不存在,则下载返回false + imageDir
function NativeManager.downloadImage( self , _imageUrl )
    DebugLog( "NativeManager.downloadImage" );
    if not _imageUrl then
        return false , "";
    end
    if string.find(_imageUrl, "default_woman") or string.find(_imageUrl, "default_man") then
        return false , "";
    end
    local _picName = md5_string( _imageUrl );
    if not _picName then
        return false , "";
    end
    if publ_isFileExsit_lua( _picName..".png" ) then
        DebugLog(" image exsit in sdCard ");
        return true , _picName..".png";
    end
    local post_data = {};
    post_data.ImageName = _picName;
    post_data.ImageUrl = _imageUrl;
    local dataStr = json.encode(post_data);
    native_to_java(kDownloadImageOne , dataStr);
    return false , _picName..".png";
end

-- 查询多张图片
-- 返回已存在的imageDirs + 未存在的imageDirs
function NativeManager.downloadImages( self , _imageUrls )
    if not _imageUrl then
        return "" , "";
    end
end

-- 友盟更新
-- function NativeManager.downloadUmengUpdate(self , param)
--  if not param then
--      return;
--  end
--  local dataStr = json.encode(param);
--  dict_set_string(kUmengUpdate, kUmengUpdate..kparmPostfix, dataStr);
--  native_to_java(kUmengUpdate);
-- end

-- 图片下载完成后的事件回调
function NativeManager.callEvent( self )
    local param = dict_get_string(kcallEvent , kcallEvent) or "";
    DebugLog("NativeManager callEvent : "..(param or ""));
    if not param then
        return
    end
    local data = initResult(param)
    local detailData = nil
    if kDownloadImageOne == param then                                            --下载图片
        if data then
            detailData = (data.ImageName or "")..".png"
            if not publ_isFileExsit_lua(detailData) then
                detailData = nil
            else
                EventDispatcher.getInstance():dispatch(NativeManager._Event, param, detailData)
            end
        end
    elseif kFetionUploadHeadicon == param then                                    --上传头像
        detailData = "";
        EventDispatcher.getInstance():dispatch(NativeManager._Event, param, detailData)
    elseif kShowMemory == param then
        detailData = data.memory or ""
        DebugLog("kShowMemory == param : "..detailData)
        EventDispatcher.getInstance():dispatch(NativeManager._Event, param, detailData)
    elseif kCloseLoadingProe == param then                                        --关闭闪屏
        --关闭起始闪屏
        DebugLog("--关闭起始闪屏")
        self:playFlashScreenAndEnterAnim()
    elseif "ApplePayDeliverRequest" == param then                                 --苹果支付
        --苹果支付请求发货
        DebugLog("--苹果支付请求发货")
        SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_APPLE_PAY,data)
    elseif "CloseNativeShareView" == param then                                   --关闭分享界面
        --游戏中的奖状界面 分享结束后要显示奖状上的btn
        if GameConstant.curGameSceneRef and GameConstant.curGameSceneRef ~= HallScene_instance then
            if GameConstant.curGameSceneRef.resultView and GameConstant.curGameSceneRef.resultView.screenShot then
                GameConstant.curGameSceneRef.resultView:screenShot(false)
            end
        end
        if GameConstant.curGameSceneRef and GameConstant.curGameSceneRef ~= HallScene_instance then
            if GameConstant.curGameSceneRef.certificateWnd and GameConstant.curGameSceneRef.certificateWnd.showBtn then
                GameConstant.curGameSceneRef.certificateWnd:showBtn()
            end
        end
    elseif "showBanner" == param then                                              --显示bannner
        local msg = data.msg
        if msg then
            Banner.getInstance():showMsg(msg)
        end
    elseif kLoadSoundRes == param then                                             --加载声音资源完成 设置音效
        loadSoundCallback(callParam)
    else 
        DebugLog("NativeManager callEvent, dispatch:" .. tostring(param) .. ", data:" .. tostring(data))
        EventDispatcher.getInstance():dispatch(NativeManager._Event, param, data)  --让各个业务处理各自逻辑
    end
end

function NativeManager.playFlashScreenAndEnterAnim( self )
    if not GameConstant.isFirstRun or not HallScene_instance then
        return
    end
    HallScene_instance:preEnterHallState()
    GameEffect.getInstance():play("AUDIO_ENTERHALL");
    HallScene_instance:playEnterHallAnim(HallScene_instance,HallScene_instance.enterAnimOver)
    GameConstant.isFirstRun = false
end

-- 原生resume
function NativeManager.nativeEventResume(self)
    if not GameConstant.gameInitFinish then
        return;
    end
    DebugLog("NativeManager nativeEventResume");
    if not isPlatform_Win32() then
        
        if GameConstant.brankInRoomFlg and not GameConstant.hasReallyPay then
            -- 在游戏里破产了，且玩家没有没有支付，重新打开破产界面
            if PlayerManager.getInstance():myself().money < GameConstant.bankruptMoney then
                -- 玩家放弃购买且已经破产，则弹出破产界面
                --globalShowBankruptcyDlg(nil, nil, function( obj )
                --
                --end);
                GlobalDataManager.getInstance():showBankruptDlg(nil,RoomScene_instance);
            end
        end
        GameConstant.brankInRoomFlg = false;
        GameMusic.getInstance():resume();

        -- 无论timeout是否处理过，都清除之.
        dict_set_int("OSTimeout", "id", GameConstant.roomReconnectTimeoutId);
        call_native("ClearOSTimeout")

        dict_set_int("OSTimeout", "id", GameConstant.exitGameTimeoutId);
        call_native("ClearOSTimeout");
        -- 切换后台返回后在大厅，则重连连接大厅socket
        if GameConstant.whenResumeInHall then
            DebugLog("GameConstant.whenResumeInHall");
            GameConstant.whenResumeInHall = false;
            if HallScene_instance then
                HallScene_instance:openHallSocketAndLogin();
            end
        end

        showOrHide_sprite_lua(1);

        if PlatformFactory.curPlatform then
           if not GameConstant.isSingleGame then
                -- native_to_java(kCheckLoginPlatform);
           end
        end
        GameConstant.payingInRoom = false;
    end
end

-- 原生Pause
function NativeManager.nativeEventPause(self)
    DebugLog("NativeManager nativeEventPause");
    if not isPlatform_Win32() then
        GameMusic.getInstance():pause();
        -- 设置一个timeout, 到期时如果是在房间则重连要重连
        --GameConstant.roomReconnectTimeoutId = 1001;
        dict_set_int("OSTimeout", "id", GameConstant.roomReconnectTimeoutId or 1001 );
        dict_set_int("OSTimeout", "ms", 1000*20);
        call_native("SetOSTimeout");

        --设置一个timeout,当其到达时关闭程序
        --GameConstant.exitGameTimeoutId = 1002;
        dict_set_int("OSTimeout", "id", GameConstant.exitGameTimeoutId or 1002 );
        dict_set_int("OSTimeout", "ms", 1000*60*60);
        call_native("SetOSTimeout");
    end
    if g_DiskDataMgr then 
        g_DiskDataMgr:save()
    end 
    showOrHide_sprite_lua(0);
end

-- 打开本地的webview
--[[
    visibility : 0 为隐藏   1为显示   2为释放
    webindex   : 处于arrayList的index
    rect       : 坐标
    weburl     : 本地路径
]]
function NativeManager.showLocalWebview(self , visibility , webindex , rect , weburl)
    local webviewData = {};
    rect = rect or {};
    webviewData.webx = rect.webx or 0;
    webviewData.weby = rect.weby or 0;
    webviewData.webw = rect.webw or 0;
    webviewData.webh = rect.webh or 0;
    webviewData.weburl = weburl or "";
    webviewData.webindex = webindex or -1;
    webviewData.visibility = visibility or 2;
    local dataStr = json.encode(webviewData);
    native_to_get_value(kLocalWebview , dataStr);
    return dict_get_int(kLocalWebview, "webindex", -1);
end

-- 显示android真机的内存
function NativeManager.showAndroidMemroy(self)
    local webviewData = {};
    local dataStr = json.encode(webviewData);
    native_to_java(kShowMemory , dataStr);
end
