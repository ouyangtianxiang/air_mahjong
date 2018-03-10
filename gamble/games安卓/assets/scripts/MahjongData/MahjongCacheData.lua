---------  数据存储的封装类 --------- 

require("MahjongConstant/GameDefine")

MahjongCacheData_loadFileList = {};

function MahjongCacheData_loadFile( fileName )
	for k,v in pairs(MahjongCacheData_loadFileList) do
		if 1 == MahjongCacheData_loadFileList[fileName] then
			DebugLog(fileName.." has load .");
			return;
		end
	end
	dict_load(fileName);
	MahjongCacheData_loadFileList[fileName] = 1;
end

function MahjongCacheData_saveDict( dictName )
	if dictName then
		dict_save(dictName);
	end
end

function MahjongCacheData_deleteDict( dictName )
	if dictName then
		dict_delete(dictName);
	end
end

-- Get函数的参数定义
-- dictName(string)       需要load的dict表
-- key(string)            需要获取的key值
-- default(函数各异)	  默认值(可以不传)
function MahjongCacheData_getDictKey_IntValue( dictName , key , default)
	MahjongCacheData_loadFile(dictName);
	return dict_get_int(dictName,key,default or 0);
end

function MahjongCacheData_getDictKey_BooleanValue( dictName , key , default)
	MahjongCacheData_loadFile(dictName);
	local ret = dict_get_int(dictName,key,default and kTure or kFalse);
	return (kTure == ret);
end

function MahjongCacheData_getDictKey_DoubleValue( dictName , key , default)
	MahjongCacheData_loadFile(dictName);
	return dict_get_double(dictName,key,default or 0.0);
end

function MahjongCacheData_getDictKey_StringValue( dictName , key , default)
	MahjongCacheData_loadFile(dictName);
	return dict_get_string(dictName,key) or default;
end

function MahjongCacheData_getDictKey_TableValue( dictName , key , default)
	require("coreex/serializer");
	return Serializer.load(dictName , key) or default;
end

-- Set函数的参数定义
-- dictName(string)       需要load的dict表
-- key(string)            需要获取的key值
-- data(函数各异)		  需要设置的数据
-- needSave（Boolean）    是否需要存入硬盘(可以不传，默认不存)
function MahjongCacheData_setDictKey_IntValue( dictName , key , data , needSave)
	local ret = dict_set_int(dictName,key,data or 0);
	if ret ~= -1 and needSave then
		MahjongCacheData_saveDict(dictName);
	end
end

function MahjongCacheData_setDictKey_BooleanValue( dictName , key , data , needSave)
	local ret = dict_set_int(dictName,key,data and kTrue or kFalse);
	if ret ~= -1 and needSave then
		MahjongCacheData_saveDict(dictName);
	end
end

function MahjongCacheData_setDictKey_DoubleValue( dictName , key , data , needSave)
	local ret = dict_set_double(dictName,key,data or 0.0);
	if ret ~= -1 and needSave then
		MahjongCacheData_saveDict(dictName);
	end
end

function MahjongCacheData_setDictKey_StringValue( dictName , key , data , needSave)
	local ret = dict_set_string(dictName,key,data or "");
	if ret ~= -1 and needSave then
		MahjongCacheData_saveDict(dictName);
	end
end

function MahjongCacheData_setDictKey_TableValue( dictName , key , data , needSave)
	require("coreex/serializer");
	local ret = Serializer.save(dictName,key,data or {});
	if ret ~= -1 and needSave then
		MahjongCacheData_saveDict(dictName);
	end
end

function clearBufferDict()
	g_DiskDataMgr:clearAllFile()
 	require("MahjongHall/HallConfigDataManager");
 	HallConfigDataManager.getInstance():clearAllHallData();
 	GameConstant.privateDiZhuList = {};
 	GameConstant.privateLFPDiZhuList = {};
 	require( "MahjongData/ProductManager" );
 	ProductManager.getInstance():clearProductList();
 	PlatformConfig.ACTIVITY_URL                  = ""; --活动的地址
	PlatformConfig.PUSH_URL                  	 = ""; --强推的地址
    require("MahjongCommon/FirstChargeView");
	SocketManager.getInstance():openReportSocketData();
	FirstChargeView.getInstance():clearData();
	new_pop_wnd_mgr.get_instance():clear_wnd_list();
	NetCacheDataManager.getInstance():stopRefreshTimestamp();
	NetCacheDataManager.getInstance():clearCache();
end 


