-- MultiRequestManager.lua
-- 
-- 多接口请求基类管理器

MultiRequestManager = class();

function MultiRequestManager:ctor()
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

function MultiRequestManager:dtor()
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

-- cmdsTable: 传入参数必须是如下格式，table中的每个元素必须是int类型，否则计算时会报错
-- temp = {
-- 	CMD1 = 0x000001,
-- 	CMD2 = 0x000002
-- }
-- 
-- ignoreTable: 传入参数必须是如下格式，table中的每个元素必须是int类型，否则计算时会报错
-- temp = {
-- 	CMD1 = 0x000001,
-- 	CMD2 = 0x000002
-- }
-- 
function MultiRequestManager:calculateCmds( cmdsTable, ignoreTable )
	DebugLog( "MultiRequestManager.calculateCmds" );
	local cmds = 0;
	local ignore = false;

	if not cmdsTable then
		return cmds;
	end

	if not ignoreTable then
		-- there is no ignore table
		for k, v in pairs(cmdsTable) do 
			cmds = bit.bor(v, cmds);
		end
	else
		-- there is some ignore cmds
		for k,cmd in pairs(cmdsTable) do
			for i,ignoreCmd in pairs(ignoreTable) do
				if cmd == ignoreCmd then
					ignore = true;
					break;
				end
			end

			if ignore then
				ignore = false;
			else
				cmds = bit.bor(cmd, cmds);
			end
		end
	end

	return cmds;
end

function MultiRequestManager:requestParts( cmdsTable, httpCmd )
	local infoParam = {};
	for key,cmdTable in pairs(cmdsTable) do
		local cmds = self:calculateCmds( cmdTable );
		infoParam[key] = cmds;
	end

	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.infoParam = infoParam;

	self:request( httpCmd, param );
end

-- invoke the functions with the data.
-- data: this is the php interface returned data, it contains all data, you must seperate it to different function.
-- funcTable: 参数描述如下，key必须为整型，每一个key对应请求的参数中的key，value必须为function类型
-- funcTable = {
-- 	[CMD1] = func1,
-- 	[CMD2] = func2
-- }
function MultiRequestManager:handle( data, funcTable )
	if not funcTable or not data then
		log( "MultiRequestManager:handle data or function table is nil" );
		return;
	end

	for k,v in pairs(data) do
		local method = funcTable[tonumber(k)];
		if method then
			method( self, v, tonumber(k) );
		end
	end
end

function MultiRequestManager:handleSingle( data, func, cmd )
	if not func or not data then
		log( "MultiRequestManager:handleSingle data or function table is nil" );
		return;
	end

	return func( self, data, cmd );
end

-- 将所有命令行位与以后请求
function MultiRequestManager:request( httpCmd, params )
	DebugLog( "MultiRequestManager.requestConfig" );	

	SocketManager.getInstance():sendPack(httpCmd, params)
end

MultiRequestManager.onPhpMsgResponse = function ( self, data, command, isSuccess,jsonData )
end

function MultiRequestManager:getAllRequestCmd()
end
