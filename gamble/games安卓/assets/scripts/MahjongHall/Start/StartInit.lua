--

StartInit = {};

function StartInit.initGame(self)
    DebugLog("StartInit initGameInfo");
    if not isPlatform_Win32() then
        self:initGameInfo();
    end
    self:initPlatform();
    if 1 == GameConstant.soundDownload then
        initDownloadAudio(GameConstant.resVer);
    else
        initAudio(GameConstant.resVer);
    end
    self:initVolumn();

    -- 读取新手教程数据
    GameConstant.needShowTip = g_DiskDataMgr:getAppData('acountTip', 0)

    -- 修改游戏启动状态
    writeFirstStartGameState();
    umengReportHotUpdate(); -- 上报友盟
    GameConstant.gameInitFinish = true;
end

-- 从android端获取初始化数据
function StartInit.initGameInfo( self )
    DebugLog("StartInit initGameInfo");
    native_to_get_value(kgetInitValue);
    local str = dict_get_string(kgetInitValue, kgetInitValue .. kResultPostfix);
    str = json.mahjong_decode_node(str);

    GameConstant.iosDeviceType = str.iosDeviceType or 0;
    DebugLog("GameConstant.iosDeviceType = "..GameConstant.iosDeviceType);
    GameConstant.soundDownload = tonumber(str.sound);
    GameConstant.faceIsCanUse = tonumber(str.face);
    GameConstant.resdownload = str.res
    GameConstant.appid = str.appid
    GameConstant.appkey = str.appkey
    GameConstant.isSdCard = str.isSdCard
    GameConstant.model_name = str.model_name or "";
    GameConstant.simType = tonumber(str.simType) or 0;

    GameConstant.old_appid = str.old_appid
    GameConstant.old_appkey = str.old_appkey

    if 1 == GameConstant.simType then
        GameConstant.operator = "移动";
    elseif 2 == GameConstant.simType then
        GameConstant.operator = "联通";
    elseif 3 == GameConstant.simType then
        GameConstant.operator = "电信";
    else
        GameConstant.operator = "未知";
    end

    if GameConstant.iosDeviceType>0 then
      GameConstant.devjailbreak = str.devjailbreak or 0;
      GameConstant.factoryid = str.factoryid or "";
      GameConstant.operator = str.operator or "";
      GameConstant.feedBackExtraString = str.feedBackExtraString or "";
    end
    GameConstant.api = tonumber(str.api) or 0
    GameConstant.imei = str.imei or "0";
    GameConstant.imei2 = str.imei or "0";
    GameConstant.imsi = str.imsi or "";
    GameConstant.phone = str.phone or ""; --手机号
    GameConstant.macAddress = str.mac  --联网mac地址
    GameConstant.simnum = str.simnum--sim序列号
    GameConstant.platformType = PluginUtil:convertPlugin2PlatformId(tonumber(str.platform_type or GameConstant.platformType)) --平台
    GameConstant.hasWechatPackage = (tonumber(str.hasWechat or 0)) == 1 ;
    GameConstant.isOpenMusic = str.music or "0";
    GameConstant.appName = str.appname or PlatformFactory.curPlatform:getApplicationShareName();
    GameConstant.issupportshare = (str.issupportshare or "1") == "1";
    GameConstant.isMiUiSystem = (str.isMiUISystem or "0") == "1";
    GameConstant.currentCpuFreq = str.currentCpuFreq or "";
    GameConstant.totalMemory = str.totalMemory or "";
    GameConstant.maxCpuFreq = str.maxCpuFreq or "0";
    GameConstant.minCpuFreq = str.minCpuFreq or "";
    GameConstant.romMemory = str.romMemory or "";
    GameConstant.rat = str.screenPixel or "";
    GameConstant.osv = str.os or "";
    --GameConstant.fid = str.fid or ""---邀请的房间号
    GlobalDataManager.getInstance().m_enter_data.fid = str.fid;
    GlobalDataManager.getInstance().m_enter_data.type = str.type;
    GlobalDataManager.getInstance().m_enter_data.level = str.level;
    GlobalDataManager.getInstance().m_enter_data.matchType = str.matchType;
    if true then
        DebugLog("000000000000000000000000");
        local t = GlobalDataManager.getInstance().m_enter_data.type;
        local fid =  GlobalDataManager.getInstance().m_enter_data.fid
        local level =  GlobalDataManager.getInstance().m_enter_data.level
        local matchType =  GlobalDataManager.getInstance().m_enter_data.matchType

        DebugLog("type:"..tostring(t));
        DebugLog("fid:"..tostring(fid));
        DebugLog("level:"..tostring(level));
        DebugLog("matchType:"..tostring(matchType));
    end

    --资源版本号不需要原生传过来，注释
    --GameConstant.resVer = str.resVer or GameConstant.resVer;
    GameConstant.Version = str.versionName or GameConstant.Version;

    require("Version");
    Version.lua_ver = string.gsub(GameConstant.Version,"%.","");

    GameConstant.macAddress = GameConstant.macAddress or self:getPhoneMachineId_lua() or "";
    GameConstant.net = str.net or "";   --联网方式

    require( "MahjongCommon/UploadDumpFile" );
    local uploadDup = new(UploadDumpFile, 4005);
    uploadDup:setEvent( self, function()
    end);
    uploadDup:execute( GameConstant.net == "wifi" );

    local defaultVale = 0
    DebugLog("CPU:"..GameConstant.maxCpuFreq)
    local myCpuFreq = tonumber(GameConstant.maxCpuFreq) or 0
    if myCpuFreq > 1500000 then --1.5GHz
        defaultVale = 1
        DebugLog("defaultValeCPU:"..defaultVale)
    end
    if GameConstant.iosDeviceType > 0 then
      defaultVale = 1;
    end
    GameConstant.switchAnimIsOpen = g_DiskDataMgr:getAppData( "hallAnimIsOpen", defaultVale);
end

function StartInit.initVolumn( self )
    -- 设置当前音效、音乐音量
    GameConstant.curMaxMusic = GameMusic.getInstance():getMaxVolume();
    GameConstant.curMaxVoiceEffect = GameEffect.getInstance():getMaxVolume();
    local voice = g_DiskDataMgr:getAppData( "voice", -1);
    local music = g_DiskDataMgr:getAppData("music", -1);
    if voice == -1 then -- 还没有保存过值，默认0.5, 并且保存到本地
        voice = 0.5;
        music = 0.5;
        g_DiskDataMgr:setAppData("music", music);
        g_DiskDataMgr:setAppData("voice", voice);
    end
    GameMusic.getInstance():setVolume(music);
    GameEffect.getInstance():setVolume(voice);

    if tonumber(GameConstant.isOpenMusic) == -1 then
        GameMusic.getInstance():setVolume(0);
        GameEffect.getInstance():setVolume(0);
    end
end

-- 得到手机唯一标示
function StartInit.getPhoneMachineId_lua( self )
    native_to_get_value(kGetPhoneMachineId);
    local str = dict_get_string(kGetPhoneMachineId, kGetPhoneMachineId .. kResultPostfix);
    return str or "";
end

-- 初始化平台
function StartInit.initPlatform( self )
    PlatformFactory.initPlatform( GameConstant.platformType );
end
