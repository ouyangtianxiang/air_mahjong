-----------------------------------------------
--1、property 最后两个参数，true变为false，false变为true
--2、DrawingImage.setResRect 原型从 function(self, index, x, y, width, height)
--	变为 function(self, index, res) 
--	如果有用这个函数，需要手动修改
--3、require("core/scene"); 替换为 require("core/sceneLoader");
--4、main.lua 加上 require("compatible");
-----------------------------------------------

--constants.lua
kTextAlignCenter		= 0
kTextAlignTop			= 1
kTextAlignTopRight		= 2
kTextAlignRight			= 3
kTextAlignBottomRight	= 4
kTextAlignBottom		= 5
kTextAlignBottomLeft	= 6
kTextAlignLeft			= 7
kTextAlignTopLeft		= 8


contructSuper = super;


StateMachine.registerStyles = function(key,func)
	StateMachine.getInstance():registerStyle(key,func);
end


Joins = function(t, mtkey)
    local str = "K";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
        end
    end
    return str;
end

getNumFromJsonTable = GetNumFromJsonTable;
getStrFromJsonTable = GetStrFromJsonTable;
getBooleanFromJsonTable = GetBooleanFromJsonTable;
getTableFromJsonTable = GetTableFromJsonTable;

----if DEBUGMODE == 1 then
	System.setWin32TextCode("utf-8");
----else
----	System.setWin32TextCode((LanguageConfig and LanguageConfig.isZhHant) 
--			--			and "gbk" or "gb2312");
----end
						
GameString.convert = function(str)
	return GameString.convert2Platform(str)
end

filterPicker = function(path,filename)
	return ResConfig and ResConfig.Filter or kFilterLinear;
end

formatPicker = function(path,filename)
	if not ResConfig then
		return nil;
	end
	local configFormatFileMap = ResConfig.FormatFileMap or {};

	local fmt;
	fmt = configFormatFileMap[fileName];
	if (not fmt) and ResConfig.FormatFolderMap then
		for k,v in pairs(ResConfig.FormatFolderMap) do 
			if string.find(fileName,k) then
				fmt = v;
				break;
			end
		end
	end
	fmt = fmt or ResConfig.FormatDefault or kRGBA8888;

	return fmt;
end

pathPicker = function(fileName)
	return "";
end

System.setImageFormatPicker(formatPicker);
System.setImageFilterPicker(filterPicker);
System.setImagePathPicker(pathPicker);


Socket.setOnEvent = Socket.setEvent;

System.getFrameTime = function()
	return sys_get_int("frame_time",0);
end

System.setAnimInterval = function(doubleValue)
	return System.setFrameRate(1.0/(doubleValue or 60.0));
end

System.getTextureAlloc = System.getTextureMemory;
System.getTextureSwitch = System.getTextureSwitchTimes;
System.setClearBackground = System.setClearBackgroundEnable;
System.setAlertError = System.setAlertErrorEnable;
System.setShowImageRect = System.setShowImageRectEnable;
System.setAndroidLog = System.setAndroidLogEnable;
System.setSocketLog = System.setSocketLogEnable;
System.setBackpressExit = System.setBackpressExitEnable;
System.setToErrorLuaInWin32 = System.setToErrorLuaInWin32Enable;
System.setEventTouchRaw = System.setEventTouchRawEnable;
System.setEventResume = System.setEventResumeEnable;
System.setEventPause = System.setEventPauseEnable;
System.setLastLuaError = System.setLuaError;


dict = Dict;


Http.getAbort = function(self)
	return self:isAbort() and kTrue or kFalse;
end

Http.setInt = function(self,key,val)
	--useless
end

Http.getInt = function(self,key,defaultVal)
	--useless
end

--scene.lua


Scene = class();

Scene.registLoadFunc = function(name,func)
	return SceneLoader.registLoadFunc(name,func);
end

Scene.ctor = function(self,t)
	self.m_root = SceneLoader.load(t);
end

Scene.load = function(self,t)
	return SceneLoader.load(t);
end

Scene.getRoot = function(self)
	return self.m_root;
end

Scene.dtor = function(self)
	delete(self.m_root);
	self.m_root = nil;
end

