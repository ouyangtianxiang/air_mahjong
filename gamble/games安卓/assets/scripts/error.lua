require("MahjongConstant/GameConstant");

require("EngineCore/config")
require("coreex/systemex")
require("coreex/constantsex")
require("uiex/buttonex")
require("uiex/sliderex")
require("coreex/soundex")
require("coreex/globalex");
require("Define");
require("coreex/drawingex")
require("coreex/systemEventex");
require("gameBase/gameEffect");
require("gameBase/gameMusic");
require("Version");

local ViewLuaPath_Error = "view/SC_800_480/";

local errorLayout = require(ViewLuaPath_Error.."errorLayout");
local errorLayout_debug = require(ViewLuaPath_Error.."errorLayout_debug");
require( "MahjongConstant/GlobalFunction" );

function event_load ( width, height )
	print("error");

	System.setLayoutWidth(1280);
    System.setLayoutHeight(720);


    local errorTips = System.getLuaError() or ""
    errorTips = errorTips..", Version.mini_ver:"..Version.mini_ver

	--上报友盟错误
	if not isPlatform_Win32() then
		local umengStr = "LUAmessage:"..errorTips;
        local data = {} 
        data.msg = umengStr
		native_to_java("UmengError", json.encode(data));
	end
	DebugLog("ResultViewUmengError: error,event_load,socket_close")
	--同步关闭room/hall socket
	socket_close("hall",-1);

	local errorBackBtn = nil;
	local errorScene = nil;

	--删除全部4类对象
	res_delete_group(-1);
	anim_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();
	

	GameMusic.getInstance():stop();
	
	if 1 == DEBUGMODE then
        Window.instance().debug = true
		errorScene = SceneLoader.load(errorLayout_debug);
		errorScene:addToRoot();
		local errorContent = errorScene:getChildByName("subWindow"):getChildByName("errorInfo");
		errorContent:setText(""..errorTips);
		errorBackBtn = errorScene:getChildByName("subWindow"):getChildByName("confirm");
	else
	    if PlatformConfig.platformWDJ == GameConstant.platformType or PlatformConfig.platformWDJNet == GameConstant.platformType then 
	    	errorScene = SceneLoader.load(errorLayout);
			errorScene:addToRoot();
			errorBackBtn = errorScene:getChildByName("subWindow"):getChildByName("confirm");
			errorScene:getChildByName("subWindow"):getChildByName("logo"):setFile("Login/wdj/Loading/load_logo.png");

		elseif PlatformConfig.platformYiXin == GameConstant.platformType then 
			errorScene = SceneLoader.load(errorLayout);
			errorScene:addToRoot();
			errorBackBtn = errorScene:getChildByName("subWindow"):getChildByName("confirm");
			errorScene:getChildByName("subWindow"):getChildByName("logo"):setFile("Login/yx/Loading/load_logo.png");
		else 
			errorScene = SceneLoader.load(errorLayout);
			errorScene:addToRoot();
			errorBackBtn = errorScene:getChildByName("subWindow"):getChildByName("confirm");
		end
	end
	
    errorBackBtn:setLevel(100)
	errorBackBtn:setOnClick(nil,function()
		errorScene:removeFromSuper();
		to_lua("main.lua");	
	    local MahjongDiskData = require('MahjongCommon/MahjongDiskData')
	    g_DiskDataMgr = g_DiskDataMgr or new(MahjongDiskData)		
		require( "MahjongData/NetCacheDataManager" );
		NetCacheDataManager.getInstance():clearCache();
	end);
end

