-- NetCacheDataManager.lua
-- author: OnlynightZhang
-- description: 网络缓存数据管理器
-- usage:
-- 1. 添加命令行，php会为每一个请求定义一个命令id，你需要将这个命令id添加到 NetCacheDataManager.cmds 中。
-- 2. 给命令添加对应的数据处理函数，并将数据return用于之后的事件广播中的数据。
-- 3. 注册数据广播事件，NetCacheDataManager.DataEvent 中注册事件，每一个事件赋默认值-1，manager初始化时会主动申请事件id
-- 4. 在需要接收数据的地方注册事件，接收并处理数据。

require("MahjongData/MultiRequestManager");
require("MahjongData/NetCacheDataRequester");
require("MahjongData/ConfigManager");
require("MahjongSocket/socketCmd")
require("MahjongSocket/socketManager")
require("MahjongSocket/NetConfig")
NetCacheDataManager = class(MultiRequestManager);

NetCacheDataManager.instance = nil;
function NetCacheDataManager.getInstance()
	if not NetCacheDataManager.instance then
		NetCacheDataManager.instance = new(NetCacheDataManager);
	end
	return NetCacheDataManager.instance;
end

-- if DEBUGMODE == 1 then
-- 	NetCacheDataManager.REFRESH_TIME = 60 * 1000; -- 60秒
-- else
-- 	NetCacheDataManager.REFRESH_TIME = 60 * 10 * 1000; -- 10分钟
-- end

NetCacheDataManager.REFRESH_TIME = 60 * 10 * 1000; -- 10分钟

-- 构造并注册事件
function NetCacheDataManager:ctor()
    DebugLog("[NetCacheDataManager]:ctor");
	self:isUpdated(); -- 检查是否升级，如果升级则清除缓存

	self.cacheTable = {}; -- 缓存数据表
	self.eventTable = {}; -- 注册广播事件
	self.uniqueEventId = 0; -- 为了不给每个http command 注册事件，这里在你需要的module里注册一个unique事件id即可
	self.isFirstRequest = true; -- 是否是第一次请求，如果过是第一次请求，不刷新本地数据，需要将本地数据读取并且分发出去
	self.isConfigManagerInit = false;
	self.httpCmdIsRequesting = {}; -- 标记某一个请求正在请求中，如果正在请求中则不再次请求

	self.currentRefreshTimeMap = { -- 当前php返回最新更新时间
		s1 = {};
		s2 = {};
	};

	self.dispatchCmdMap = { -- 分发命令映射，http cmd ==> cmd
		s1 = {};
		s2 = {};
	};

	self.isRequestFinish = false; -- 请求完成标记

	self:initDispatchCmdMap();
end

function NetCacheDataManager:dtor()
    DebugLog("[NetCacheDataManager]:dtor");
	delete(self.freshCounter);
	self.freshCounter = nil;
end

function NetCacheDataManager:beforeRequestData()
    DebugLog("[NetCacheDataManager]:beforeRequestData");

	require("MahjongPopu/NewUpdateWindow");

	NewUpdateWindow.isShowUpdateWndAuto = true;
	GlobalDataManager.isAutoNotice = true;
end

function NetCacheDataManager:isUpdated()
	DebugLog("[NetCacheDataManager]:isUpdated");

	local lastVersion = g_DiskDataMgr:getAppData("curr_version","")
	if lastVersion ~= GameConstant.Version then
		self:clearCache();
	end
	g_DiskDataMgr:setAppData("curr_version",GameConstant.Version)
end

function NetCacheDataManager:initDispatchCmdMap()
    DebugLog("[NetCacheDataManager]:initDispatchCmdMap");
	for paramIndex,cmdsMap in pairs(NetCacheDataManager.handler) do
		if not self.dispatchCmdMap[paramIndex] then
			self.dispatchCmdMap[paramIndex] = {};
		end
		for configCmd,httpCmd in pairs(cmdsMap) do
			self.dispatchCmdMap[paramIndex][httpCmd] = configCmd;
		end
	end
end

function NetCacheDataManager:requestHttpCmd( handlerTable )
	DebugLog("[NetCacheDataManager]:requestHttpCmd");
	if not handlerTable then
		DebugLog( "NetCacheDataManager:requestHttpCmd handlerTable is nil" );
	end

	for k,v in pairs(handlerTable) do
		local httpCommand = v;
		if httpCommand then
			self:realRequestHttpCmd( httpCommand );
		end
	end
end

function NetCacheDataManager:realRequestHttpCmd( httpCommand )
    DebugLog("[NetCacheDataManager]:realRequestHttpCmd:"..tostring(httpCommand));
    if httpCommand then
        DebugLog(string.format("cmd: 0x%03x",httpCommand));
    end
	if NetCacheDataManager.httpRequstCommandMap[httpCommand] then
		if not self.httpCmdIsRequesting then
			self.httpCmdIsRequesting = {};
		end

		if not self.httpCmdIsRequesting[httpCommand] then
			self.httpCmdIsRequesting[httpCommand] = {};
		end

		if not self.httpCmdIsRequesting[httpCommand].isRequesting then
			self.httpCmdIsRequesting[httpCommand].isRequesting = true;
			NetCacheDataManager.httpRequstCommandMap[httpCommand](  self );
		end
	end
end

-- 检测是否需要更新数据
-- cmdTable: 需要刷新的命令table，可为空，当该参数为空时请求默认重要配置的刷新列表
function NetCacheDataManager:checkForUpdate()
	DebugLog("[NetCacheDataManager]:checkForUpdate");

	local needRefreshCmdMap = self:getNeedRefreshConfigCmd( self.currentRefreshTimeMap );
	local cmdTable = self:getRefreshCmdTable(needRefreshCmdMap);

	for k,v in pairs(cmdTable) do
		self:requestHttpCmd( v );
	end
end

-- 获取需要刷新的数据的命令，如果不需要刷新的接口，直接读取本地缓存（内存或硬盘）分发出去
function NetCacheDataManager:getNeedRefreshConfigCmd( currentTimestampMap )
	DebugLog("[NetCacheDataManager]:getNeedRefreshConfigCmd:"..tostring(currentTimestampMap));

	local tempTimestampMap = nil;

	if not currentTimestampMap then
		return tempTimestampMap;
	end

	tempTimestampMap = {};
	for k,paramTable in pairs(currentTimestampMap) do
		for cmd,currentTimestamp in pairs(paramTable) do
			local localTimestamp = self:readTimestampFromFile( k, cmd );

			DebugLog( "cmd = "..cmd.." localTimestamp = "..localTimestamp.." and currentTimestamp = "..currentTimestamp );

			if not localTimestamp then -- 如果是参数错误的话需要强制刷新一下这个接口
				if not tempTimestampMap[k] then
					tempTimestampMap[k] = {};
				end
				table.insert( tempTimestampMap[k], tonumber( cmd ) );
			else
				-- 当获取的时间戳大于本地时间戳的时候刷新数据

				if tonumber( currentTimestamp or 0 ) ~= tonumber( localTimestamp or 0 ) then

					if not tempTimestampMap[k] then
						tempTimestampMap[k] = {};
					end
					table.insert( tempTimestampMap[k], tonumber( cmd ) );
				else -- 否则意思就是分发本地数据
					if self.isFirstRequest then
						self:dispatchDataFromCache( k, cmd );
					end
				end
			end
		end
	end

	self.isFirstRequest = false;
	return tempTimestampMap;
end

function NetCacheDataManager:dispatchDataFromCache( key, cmd )
	DebugLog("[NetCacheDataManager]:dispatchDataFromCache key:"..tostring(key).." cmd:"..tostring(cmd));

	if NetCacheDataManager.handler[key] and NetCacheDataManager.handler[key][cmd] then
		local httpCmd = NetCacheDataManager.handler[key][cmd];
		local cache = self:getCacheData( httpCmd );
		if cache then
			self:dispatchEvent( httpCmd, cache );
		end
	end
end

function NetCacheDataManager:getRefreshCmdTable( configCmdMap )
	DebugLog("[NetCacheDataManager]:getRefreshCmdTable");
	local temp = {};
	for k,v in pairs(configCmdMap) do
		if #v > 0 then
			temp[k] = {};
			for _,cmd in pairs(v) do
				if NetCacheDataManager.handler[k] then
					temp[k][cmd] = NetCacheDataManager.handler[k][cmd];
				end
			end
		end
	end

	return temp;
end

function NetCacheDataManager:checkHttpDataIsOk( data )
	if data and data.status and data.status == 1 then
		return true
	end
	return false
end

-- Override
function NetCacheDataManager:onPhpMsgResponse(data, command, isSuccess,jsonData, ... )
	DebugLog("[NetCacheDataManager]:onPhpMsgResponse: cmd:" ..tostring(command) .. ", func:" .. tostring(self.phpMsgResponseCallBackFuncMap[command]))
	if self.phpMsgResponseCallBackFuncMap[command] then
		self.phpMsgResponseCallBackFuncMap[command](self,data,command,isSuccess,jsonData,...)
	end
end

function NetCacheDataManager:onReqestDataResponse( data, command, isSuccess, jsonData, ... )
    DebugLog("[NetCacheDataManager]:onReqestDataResponse cmd:"..tostring(command));
    if command then
        DebugLog(string.format("cmd: 0x%03x",command));
    end

	-- data = {};
	-- jsonData = "{}";
	-------------------这里存在一个bug,保存时间戳的时候未判断数据是否拉取成功了
	-------------------如果拉取失败，这时候也保存了最新的时间戳,导致配置不再更新

	for k,sparamsMap in pairs(self.dispatchCmdMap) do
		configCmd = sparamsMap[command];
		if configCmd and self:checkHttpDataIsOk(data) then
			self:writeTimestampToFile( self.currentRefreshTimeMap[k][configCmd], k, configCmd);
			break;
		end
	end

	-- 分发数据，就算不能缓存也要分发数据
	self:dispatchEvent( command, data, jsonData );

	-- 取消标记，表示可再次请求
	if self.httpCmdIsRequesting[command] then
		self.httpCmdIsRequesting[command].isRequesting = false;
	else
		self.httpCmdIsRequesting[command] = {};
		self.httpCmdIsRequesting[command].isRequesting = false;
	end
end

function NetCacheDataManager:onRefreshTimeResponse( data, command, isSuccess, jsonData, ... )
	DebugLog( "[NetCacheDataManager]:onRefreshTimeResponse cmd:"..tostring(command) );
    if command then
        DebugLog(string.format("cmd: 0x%03x",command));
    end
	if self.isFirstRequest then
		Loading.hideLoadingAnim();
	end
	if not data or not isSuccess then
		self:onCacheInterfaceErr();
        if HallScene_instance then
            HallScene_instance:init_request_after_netcache_requeset();
        end
		return;
	end

	local status = data.status and tonumber(data.status) or -1;

	-- DEBUG ERROR
	-- status = -10;

	-- DEBUG if the interface on the code should be commented
	-- ############################################################
	local server = NetConfig.getInstance():getCurSocketType()
	-- if DEBUGMODE == 1 then
	-- 	-- 1正式服，2开发服，3测试服，4自定义服
	-- 	local server = MahjongCacheData_getDictKey_IntValue(kSystemConfigDict,kSystemConfigDictKey_Value.LocalSocketType,1);
	-- 	if 1 == tonumber( server ) then
	-- 		status = -10;
	-- 	end
	-- end
	-- ###########################################################
	-- DEBUG

	DebugLog( "NetCacheDataManager:onRefreshTimeResponse status = "..status );

	if status == 1 then
		local allData = data.data;
		if not data.data then
			return;
		end

		for k,param in pairs(allData) do
			if allData[k] then
				self:updateRefreshTimeMap( allData[k], k, self.currentRefreshTimeMap );
			end
		end

		if not self.isConfigManagerInit then
			self.isConfigManagerInit = true;
			ConfigManager.getInstance():initConfig();
		end

		self:checkForUpdate();
		self:onRequestTimestampFinishListener();

        if HallScene_instance then
            HallScene_instance:init_request_after_netcache_requeset();
        end
	else
		self:onCacheInterfaceErr();

		-- ######################这里不再设置刷新，否则还会出现同样的情况################################
	end
end



-- 将时间戳保存到本地文件
function NetCacheDataManager:writeTimestampToFile( timestamp, paramIndex, configCmd )
	DebugLog( "[NetCacheDataManager]:writeTimestampToFile" );
	if not paramIndex or not configCmd then
		DebugLog( "NetCacheDataManager:wirteTimestampToFile paramIndex 参数错误" );
		return;
	end
    if configCmd == PHP_CMD_REQUEST_FIRST_CHARGE_DATA then
        DebugLog("configCmd == PHP_CMD_REQUEST_FIRST_CHARGE_DATA");
    end
	local cacheFilename = kNetCacheFilePrefix..paramIndex;
	local key = kNetCacheFileKeyPrefix..configCmd;
	g_DiskDataMgr:setFileKeyValue(cacheFilename, key, timestamp or 0)
end

-- 返回默认为-1，表示需要主动刷新
-- 返回nil表示参数错误
function NetCacheDataManager:readTimestampFromFile( paramIndex, configCmd )
    DebugLog( "[NetCacheDataManager]:readTimestampFromFile:paramIndex:"..tostring(paramIndex).." configCmd:"..tostring(configCmd) );
	if not paramIndex or not configCmd then
		DebugLog( "NetCacheDataManager:readTimestampFromFile paramIndex 参数错误" );
		return nil;
	end
	local cacheFilename = kNetCacheFilePrefix..paramIndex;
	local key = kNetCacheFileKeyPrefix..configCmd;
	return g_DiskDataMgr:getFileKeyValue(cacheFilename, key, -1)
end

-- register event function will like this:
-- function temp( httpCmd, data ) end
-- 分发事件
-- data 原始解析成table后的数据
-- orgJsonData 原始json数据
function NetCacheDataManager:dispatchEvent( httpCmd, data, orgJsonData )
	DebugLog( "[NetCacheDataManager]:dispatchEvent:cmd"..tostring(httpCmd) );
	DebugLog( orgJsonData );
	if self.eventTable and self.eventTable[httpCmd] then
		EventDispatcher.getInstance():dispatch( self.eventTable[httpCmd], httpCmd, data );
	end
	self:updateToCache( httpCmd, data, orgJsonData );
end

-- 主动通知接收器更新数据
function NetCacheDataManager:activeNotifyReceiver( httpCmd )
	DebugLog( "[NetCacheDataManager]:activeNotifyReceiver httpcmd = "..tostring(httpCmd) );
	local cache = self:getCacheData( httpCmd );
	if cache then
		self:dispatchEvent( httpCmd, cache );
	end
end




function NetCacheDataManager:onCacheInterfaceErr()
    DebugLog( "[NetCacheDataManager]:onCacheInterfaceErr");
	-- TODO clear cache and request all command and reset the REFRESH_TIME
	self:clearCache();
	for k,v in pairs(NetCacheDataManager.handler) do
		self:requestHttpCmd( v );
	end

	-- 出现异常后，直接请求签到和首冲
	if NetCacheDataManager.httpRequstCommandExceptionMap then
		for k,func in pairs(NetCacheDataManager.httpRequstCommandExceptionMap) do
			func( self );
		end
	end
    if HallScene_instance then
        HallScene_instance:init_request_after_netcache_requeset();
    end
end

function NetCacheDataManager:onRequestTimestampFinishListener()
    DebugLog( "[NetCacheDataManager]:onRequestTimestampFinishListener");
	if not self.isRequestFinish then
		self.isRequestFinish = true;

		self.freshCounter = new(AnimInt, kAnimRepeat, 0, 1, NetCacheDataManager.REFRESH_TIME, 0 );
		self.freshCounter:setDebugName("NetCacheDataManager|freshCounter Anim");
		self.freshCounter:setEvent( self, function( self )
			self:requestRefreshTime();
		end);
	end
end

function NetCacheDataManager:stopRefreshTimestamp()
    DebugLog( "[NetCacheDataManager]:stopRefreshTimestamp");
	delete(self.freshCounter);
	self.freshCounter = nil;
	self.isRequestFinish = false;
end

function NetCacheDataManager:requestRefreshTimeOnLiginFinish()
    DebugLog( "[NetCacheDataManager]:requestRefreshTimeOnLiginFinish");
	Loading.showLoadingAnim("正在努力为您请求...");
	self.isFirstRequest = true;
	self:beforeRequestData();
	self:requestRefreshTime();
end

function NetCacheDataManager:requestRefreshTime()
	DebugLog( "[NetCacheDataManager]:requestRefreshTime");

	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.cfgParam = self:getAllRequestCmd();
	self:request( PHP_CMD_REQUEST_COMMON_CONFIG, param );
end

function NetCacheDataManager:getAllRequestCmd()
    DebugLog( "[NetCacheDataManager]:getAllRequestCmd");

	local confCmds = ConfigManager.getInstance():getAllRequestCmd();
	local refreshCmds = self:getRefreshCmds();

	local requestCmds = {};

	for k,v in pairs(confCmds) do
		requestCmds[k] = bit.bor(v, refreshCmds[k] or 0 );
	end

	for k,v in pairs(refreshCmds) do
		requestCmds[k] = bit.bor(v, confCmds[k] or 0 );
	end

	return requestCmds;
end

function NetCacheDataManager:getRefreshCmds()
    DebugLog( "[NetCacheDataManager]:getRefreshCmds");

	local requestCmdsTable = {};
	for k,paramsTable in pairs(NetCacheDataManager.cmds) do
		if NetCacheDataManager.cmds[k] then
			requestCmdsTable[k] = self:calculateCmds( NetCacheDataManager.cmds[k] );
		end
	end

	return requestCmdsTable;
end

function NetCacheDataManager:updateRefreshTimeMap( data, paramTablename, timeMap )
	DebugLog( "[NetCacheDataManager]:updateRefreshTimeMap");

	if not data or not paramTablename then
		DebugLog( "NetCacheDataManager:handle data or command table or table name is nil" );
		return;
	end

	for cmd,timestamp in pairs(data) do
		-- 如果存在命令则添加数据到命令刷新列表中
		cmd = tonumber(cmd);
		DebugLog( paramTablename.." "..cmd );
        if cmd then
            DebugLog(string.format("cmd: 0x%03x",cmd));
        end
		if self:existConfigCmd( cmd, NetCacheDataManager.cmds[paramTablename] ) then
			-- 会添加多个名字参数字段，这个为每个命令参数字段穿件一个表，以免冲突
			if not timeMap[paramTablename] then
				timeMap[paramTablename] = {};
			end
			if type(timestamp) == "table" then
				timeMap[paramTablename][cmd] = tonumber(timestamp);
			elseif type(timestamp) == "number" or type(timestamp) == "string" then
				timeMap[paramTablename][cmd] = tonumber(timestamp);
			end
		else
			if self:existConfigCmd( cmd, ConfigManager.cmds[paramTablename] ) then -- 如果命令字在ConfigManager中包含的话则在configmanager中处理数据
				local needHandle, needReq, httpCmd = ConfigManager.getInstance():handleSingle( timestamp, ConfigManager.handler[paramTablename][cmd], cmd );
                if httpCmd == PHP_CMD_REQUEST_FIRST_CHARGE_DATA then
                    DebugLog("needHandle:"..tostring(needHandle).." needReq:"..tostring(needReq));
                end
				-- 返回true的意思就是要你在 NetCacheDataManager
                --modify by NoahHan: 首冲每次请求都直接请求--因为如果用缓存的话，切换不同用户，会有bug
				if (needHandle and needReq) or httpCmd == PHP_CMD_REQUEST_FIRST_CHARGE_DATA then
					-- ##############################################
					-- 此处没有做请求限制，是因为调用这个只是做了一次二次请求
					if NetCacheDataManager.httpRequstCommandMap[httpCmd] then
						NetCacheDataManager.httpRequstCommandMap[httpCmd](  self );
					end
				end
			end
		end
	end
end

function NetCacheDataManager:existConfigCmd( cmd, commandTable )
    DebugLog( "[NetCacheDataManager]:existConfigCmd: cmd"..tostring(cmd));
	if not commandTable then
		return false;
	end

	for k,v in pairs(commandTable) do
		if tonumber(v) == tonumber(cmd) then
			return true;
		end
	end

	return false;
end

-- 保存到缓存
function NetCacheDataManager:updateToCache( httpCmd, data, orgJsonData )
    DebugLog( "[NetCacheDataManager]:updateToCache: cmd"..tostring(httpCmd));

	if not self:checkHttpDataIsOk(data) then
		return
	end


	self:updateToRamCache( httpCmd, data );

	if orgJsonData then
		self:writeToCacheFile( httpCmd, data );
	end
end

-- 更新到内存缓存
function NetCacheDataManager:updateToRamCache( httpCmd, data )
    DebugLog( "[NetCacheDataManager]:updateToRamCache: cmd"..tostring(httpCmd));
	if not self:checkHttpDataIsOk(data) then
		return
	end

	if not self.cacheTable then
		self.cacheTable = {};
	end

	if not self.cacheTable[httpCmd] then
		self.cacheTable[httpCmd] = {};
	end

	if data then
		self.cacheTable[httpCmd] = data;
	end
end

-- 写入本地磁盘
function NetCacheDataManager:writeToCacheFile( httpCmd, data )
	DebugLog( "[NetCacheDataManager]:writeToCacheFile: cmd"..tostring(httpCmd));
	if not data or not httpCmd then
		DebugLog( "NetCacheDataManager:writeToCacheFile data or httpCmd is nil" );
		return;
	end

	local key = kNetCacheFileKeyPrefix..httpCmd;
	g_DiskDataMgr:setFileKeyValue(kNetCacheDataFilename, key, data)
end

-- 从本地磁盘读取缓存数据
function NetCacheDataManager:readFromCacheFile( httpCmd )
	DebugLog( "[NetCacheDataManager]:readFromCacheFile: cmd"..tostring(httpCmd));

	if not httpCmd then
		errlog( "NetCacheDataManager:readFromCacheFile httpCmd is nil" );
		return nil;
	end
	local key = kNetCacheFileKeyPrefix..httpCmd;
	return g_DiskDataMgr:getFileKeyValue(kNetCacheDataFilename, key, nil)
end

-- 获取缓存数据
function NetCacheDataManager:getCacheData( httpCmd )
	DebugLog( "[NetCacheDataManager]:getCacheData: cmd"..tostring(httpCmd));

	if not httpCmd then
		DebugLog( "NetCacheDataManager:getCacheData httpCmd is nil" );
	end

	-- 缓存使用策略，首先读取内存缓存
	local ramCache = nil;
	if self.cacheTable then
		ramCache = self.cacheTable[httpCmd];
	end
	-- 如果内存缓存有的话就直接返回，如果内存缓存不存在的话就
	if ramCache then
		return ramCache;
	end

	-- 如果没有内存缓存则读取文件缓存
	local cache = self:readFromCacheFile( httpCmd );
	if cache and httpCmd ~= PHP_CMD_REQUEST_NOTICE_INFO then--新需求公告不做缓存
		--TODO
		self:updateToCache( httpCmd, cache );
		self:updateToRamCache( httpCmd, cache );
		return cache;
	end

	self:realRequestHttpCmd( httpCmd );

	return nil;
end

-- 清除所有缓存
function NetCacheDataManager:clearCache()
	DebugLog( "[NetCacheDataManager]:clearCache");

	self:clearRamCache();
	self:clearTimestampCache();
	self:clearMap( kNetCacheDataFilename );
end

-- 清除RAM缓存
function NetCacheDataManager:clearRamCache()
	self.cacheTable = {};
end

-- 清除时间戳缓存
function NetCacheDataManager:clearTimestampCache()
	if not NetCacheDataManager.handler then
		return;
	end

	for paramIndex,mapped in pairs(NetCacheDataManager.handler) do
		if paramIndex then
			self:clearMap( tostring( kNetCacheFilePrefix..paramIndex ) );
		end
	end
end

--订单号php返回
function NetCacheDataManager:onCreateOrderCallBack( phpData, cmd, isSuccess )
	DebugLog("[NetCacheDataManager]: onCreateOrderCallBack cmd:" .. tostring(cmd) .. ", isSuccess:" .. tostring(isSuccess))
	if isSuccess then
		local luaTable = {}
		for k, v in pairs(phpData.data) do
			luaTable[k] = phpData.data[k]
		end
		PayController:createOrderCallback(luaTable)
		PayController:requestPaySceneReport(luaTable)  --支付场景上报	
	end
end

function NetCacheDataManager:requestAppleDeliverCallBack( phpData, cmd, isSuccess )
	local jsonStr = json.encode(phpData)
	native_to_java("ApplePayDeliverRequestCallBack", jsonStr)
end

-- 清除map内容
function NetCacheDataManager:clearMap( mapName )
	DebugLog( "ERROR: NetCacheDataManager:clearMap = "..mapName );
	g_DiskDataMgr:setFileData(mapName, nil)
	--dict_delete(mapName);
	--dict_save(mapName);
end

-- 从缓存中获取数据
function NetCacheDataManager:getData( httpCmd )
	return self:getCacheData( httpCmd );
end

-- 获取事件，每在一个新文件中注册事件时需要调用该方法注册一个新事件
function NetCacheDataManager:getEvent()
	self.uniqueEventId = self.uniqueEventId + 1;
	return self.uniqueEventId;
end

function NetCacheDataManager:register( event, httpCmdTab, obj, func )
	if not obj or not func or not httpCmdTab then
		DebugLog( "NetCacheDataManager:register obj or func is nil" );
		return;
	end

	if not self.eventTable then
		self.eventTable = {};
	end

	local regEvent = event;
	for k,cmd in pairs(httpCmdTab) do
		self.eventTable[k] = regEvent;
	end

	EventDispatcher.getInstance():register( regEvent, obj, func );
end

function NetCacheDataManager:unregister( event, obj, func )
	if not obj or not func then
		DebugLog( "NetCacheDataManager:unregister obj or func is nil" );
		return;
	end

	if self.eventTable then
		for k,v in pairs(self.eventTable) do
			if v == event then
				self.eventTable[k] = nil;
			end
		end
	end

	EventDispatcher.getInstance():unregister( event, obj, func );
end


NetCacheDataManager.cmds = {
	-- 最多32个命令字，超出后需要重新添加一个配置表
	s1 = {
		--CMD_UPDATE_VERSION				= 0x00000010; --版本更新
		--CMD_ACTIVITY_URL				= 0x00000020; -- 活动中心url
		CMD_GET_LIST					= 0x00000040; -- 大厅配置
		CMD_GET_BANKRAPTCY_CONFIG		= 0x00000080; -- 破产配置
		CMD_NOTICE						= 0x00000100; -- 公告
		CMD_EXCHANGE_LIST               = 0x00000200; --兑换列表
		CMD_GET_PRODUCT_PROXY			= 0x00000400; -- 商品列表
		CMD_GET_TUI_JIAN_PRODUCT		= 0x00000800; -- 推荐商品列表
		--CMD_GET_IP_PORT        			= 0x00001000;
		CMD_SECOND_CONFIRM_TEXT         = 0x00002000;
		-- CMD_PAY_CONFIG					= 0x00004000; -- 支付配置
	};

	s2 = {
	};
};

NetCacheDataManager.handler = {
	s1 = {

		[NetCacheDataManager.cmds.s1.CMD_NOTICE] 			  	= PHP_CMD_REQUEST_NOTICE_INFO;
		[NetCacheDataManager.cmds.s1.CMD_SECOND_CONFIRM_TEXT] 	= PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT;
		[NetCacheDataManager.cmds.s1.CMD_EXCHANGE_LIST] 		= PHP_CMD_REQUEST_EXCHANGE_LIST;
		[NetCacheDataManager.cmds.s1.CMD_GET_LIST] 				= PHP_CMD_REQUEST_NEW_HALL_CONFIG;
		[NetCacheDataManager.cmds.s1.CMD_GET_TUI_JIAN_PRODUCT]  = PHP_CMD_GET_TUI_JIAN_PRODUCT;
		[NetCacheDataManager.cmds.s1.CMD_GET_PRODUCT_PROXY] 	= PHP_CMD_GET_PRODUCT_PROXY;
		[NetCacheDataManager.cmds.s1.CMD_GET_BANKRAPTCY_CONFIG] = PHP_CMD_GET_BANKRAPTCY_CONFIG;

	};

	s2 = {
	};
};

-- http请求映射表
NetCacheDataManager.httpRequstCommandMap = {

	[PHP_CMD_REQUEST_NOTICE_INFO]					= NetCacheDataRequester.requestNoticeInfo;
	[PHP_CMD_REQUEST_NEW_HALL_CONFIG]				= NetCacheDataRequester.requestNewHallConfig;
	[PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT] 		= NetCacheDataRequester.requestSecondConfirmWndText;
	[PHP_CMD_REQUEST_EXCHANGE_LIST] 				= NetCacheDataRequester.requestExchangeList;

	--[PHP_CMD_GET_TUI_JIAN_PRODUCT]					= NetCacheDataRequester.getTuiJianProduct;
	[PHP_CMD_GET_PRODUCT_PROXY]						= NetCacheDataRequester.getProductProxy;
	[PHP_CMD_GET_BANKRAPTCY_CONFIG]					= NetCacheDataRequester.getBankraptcyConfig;

	--[PHP_CMD_REQUEST_DETAIL_SIGN_INFO] 				= NetCacheDataRequester.requestSignInfo;
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA] 			= NetCacheDataRequester.requestFirstChargeData;
};

NetCacheDataManager.httpRequstCommandExceptionMap = {
	--[PHP_CMD_REQUEST_DETAIL_SIGN_INFO] 				= NetCacheDataRequester.requestSignInfo;
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA] 			= NetCacheDataRequester.requestFirstChargeData;
};

NetCacheDataManager.phpMsgResponseCallBackFuncMap = {
	[PHP_CMD_REQUEST_COMMON_CONFIG]					= NetCacheDataManager.onRefreshTimeResponse;
	-----------------------------
	[PHP_CMD_REQUEST_NOTICE_INFO]					= NetCacheDataManager.onReqestDataResponse;
	[PHP_CMD_REQUEST_NEW_HALL_CONFIG]				= NetCacheDataManager.onReqestDataResponse;
	[PHP_CMD_REQUEST_SECOND_CONFIRM_WND_TEXT]		= NetCacheDataManager.onReqestDataResponse;
	[PHP_CMD_REQUEST_EXCHANGE_LIST]					= NetCacheDataManager.onReqestDataResponse;
	--[PHP_CMD_GET_TUI_JIAN_PRODUCT]					= self.onReqestDataResponse;
	[PHP_CMD_GET_PRODUCT_PROXY]						= NetCacheDataManager.onReqestDataResponse;

	[PHP_CMD_GET_BANKRAPTCY_CONFIG]					= NetCacheDataManager.onReqestDataResponse;
	--[PHP_CMD_REQUEST_DETAIL_SIGN_INFO]				= NetCacheDataManager.onReqestDataResponse;
	[PHP_CMD_REQUEST_FIRST_CHARGE_DATA]				= NetCacheDataManager.onReqestDataResponse;
  [PHP_CMD_CREATE_ORDER]                          = NetCacheDataManager.onCreateOrderCallBack;
	[PHP_CMD_REQUEST_APPLE_PAY] = NetCacheDataManager.requestAppleDeliverCallBack;
}
--PHP_CMD_REQUEST_COMMON_CONFIG
