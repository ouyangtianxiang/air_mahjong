require("libs/LogUtils")
-- 0 正式 1 测试
DEBUGMODE = 0;

-- 设置是否打开重连 主要用于测试
isClickBackToReconnect = false;

-- 0 正式，1测试 主版本测试专用变量
TEST_PAY = 0;

-- 热更新开关，0表示关闭，1表示打开
HOTUPDATE_SWITCH = 1;

DebugLog = function ( logString,tag )
	if 1 == DEBUGMODE then
		printLog(logString,tag);
	end
end

if DEBUGMODE == 0 then
	DebugLog = function ()
		-- body
	end
	print = function ()
		-- body
	end
end

ViewLuaPath = "view/SC_800_480/";

SCREEN_WIDTH = System.getScreenWidth();
SCREEN_HEIGHT = System.getScreenHeight();

MahjongLayout_W = 1280;
MahjongLayout_H = 720;


