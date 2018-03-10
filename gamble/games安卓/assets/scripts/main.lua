-- main.lua
-- Author: NextCY
-- Date: 2013-09-05
-- Description:程序入口 
-- Note:
--require("mobdebug").start("172.20.131.19");
function event_lua_error ( errmsg )
    print('to_lua error.lua')
    --这个要写到最上面
    to_lua("error.lua") 
end 
function event_load ( width, height )
    --native_to_java(kshowJavaLocalTime)
   

    --这个要写到最上面
    require("EngineCore/config")
    
    require("coreex/systemex")
    require("coreex/constantsex")

    require("uiex/buttonex")
    require("uiex/edittext_ex")
    require("uiex/edittextview_ex")
    
    
    require("uiex/sliderex")
    require("coreex/soundex")
    require("coreex/globalex");
    require("Define");
    require("coreex/drawingex")
    require("coreex/systemEventex");



--    require("gameBaseex/gameResMemory")
    require("gameBaseex/gameControllerex")
    require("gameBaseex/gameStateex")
    require("gameBaseex/gameSoundex")    
    System.setStencilState(true) 
    System.setLayoutWidth(MahjongLayout_W);
    System.setLayoutHeight(MahjongLayout_H);
    DebugLog("上面是达到event_load的JAVA时间， native_to_java LUA的消耗CPU时间: "..os.clock() * 1000);
    require("MahjongConstant/Display")
    require("statesConfig");
    require("MahjongConstant/GameConstant");
    require("MahjongPlatform/PluginUtil");
    require("MahjongConstant/GameDefine");
    require("libs/json_wrap");
    -- require("MahjongCommon/CustomNode");
    require("MahjongPlatform/PlatformFactory");
    -- require("MahjongData/PlayerManager");
    require("error");
    require("MahjongConstant/GlobalFunction");
    -- require("MahjongConstant/MahjongImageFunction");  --放到了hallscene中，快速开始的延迟事件中，保证在需要用到麻将的时候正常运行
    require("MahjongConstant/GameLogicFunction");
    require("MahjongConstant/UMengReportEvent");
    require("compatible");
    require("MahjongCommon/new_pop_wnd_mgr");
    require("MahjongCommon/back_event_manager");
    
    DebugLog("event_load  Cup时间 time==" .. os.clock() * 1000 .. "   下面是require的JAVA时间：");
    if 1 == DEBUGMODE then

        System.setToErrorLuaInWin32Enable(true);
        System.setAlertErrorEnable(true);
        System.setSocketLogEnable(true);

    else
        System.setToErrorLuaInWin32Enable(false);
        System.setAlertErrorEnable(false);
        System.setSocketLogEnable(false);

    end
    local MahjongDiskData = require('MahjongCommon/MahjongDiskData')
    g_DiskDataMgr = g_DiskDataMgr or new(MahjongDiskData)
    
    require("MahjongHall/Start/StartInit");
    StartInit.initGame(StartInit);
    App = App or new(require("app"))
    PayController = PayController or new(require("MahjongPay/payController"), "MahjongPay/")
    
    System.startTextureAutoCleanup()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

	System.setEventResumeEnable(true);
	System.setEventPauseEnable(true);
    System.setWin32ConsoleColor(0xffffff);
    System.setClearBackgroundEnable(false);
    UIConfig.setScrollBarImage("ui/scroll.png");
    ScrollView.setDefaultScrollBarWidth(0);

    -----------------
    --local GameMonitor = require("libs/GameMonitor");
    --g_GameMonitor = new(GameMonitor)
    --g_GameMonitor:start()
    --sys_set_int("profiling_frame",60);    
    DebugLog("event_load 准备到大厅的CUP消耗  time==" .. os.clock() * 1000 ..  "   下面是准备到大厅的JAVA时间：");
    -- native_to_java(kshowJavaLocalTime)

    StateMachine.getInstance():changeState(States.HotUpdate);
end
