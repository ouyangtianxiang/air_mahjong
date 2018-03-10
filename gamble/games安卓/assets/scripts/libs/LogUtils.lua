require("libs/bit")
inspect = require("libs/inspect")



LTMap = {
	Default    		= 0x0001,--默认
	NetMsgSend 		= 0x0002,
	NetMsgRecv 		= 0x0004,
	MahjongDisplay  = 0x0008,
	CCSprite        = 0x0010,
	Profile            = 0x0020,
	Loading         = 0x0040,
}

LCMap = {
	[LTMap.Default] 				= { 0xFFFFFF,"Default"},--color,tag,splitSign,
	[LTMap.NetMsgSend] 				= { 0xB5E61D,"SendMsg"},--   "*",100},--color,tag,
	[LTMap.NetMsgRecv] 				= { 0xFFB90F,"RecvMsg"},--   "*",100},--color,tag,
	[LTMap.MahjongDisplay] 			= { 0xFFFFFF,"MajongView","#",100},--color,tag,
	[LTMap.CCSprite]				= { 0xFFFFFF,"CCSprite"},
	[LTMap.Profile]                 = { 0xFFB90F,"Profile:$$$$"},
	[LTMap.Loading]                 = { 0xFFB90F,"Loading:$$$$"},
}

LOG_LINE_SPLIT = {
socket_send = "====================================socket send=============================================",--sockt命令的分隔显示
socket_recv = "====================================socket recv=============================================",--sockt命令的分隔显示
}

LOG_SWITCH =  0xff--0x0040--0xff--0xe


local old_print = print_string
print_string = function ( ... )
	-- body
end

function printLog( log, tag )
	if not log then 
		return 
	end
    tag = tag or LTMap.Default 

	--获取配置
	local config = __getConfigByTag(tag)

	if not config then 
		return 
	end

	local logStr = nil
	--设置颜色
	System.setWin32ConsoleColor(config[1]);
	--分割线,日志内容,分割线
	logStr = __gernerateSplit(config) .. __gernerateBody(log) .. __gernerateSplit(config)
	---打印日志
    add_log_split_begin(tag);
	__log(logStr)
    add_log_split_end(tag);

end

function __log( str )
	old_print(str)
end

function add_log_split_begin(tag)

    if tag == LTMap.NetMsgSend then
        __log(LOG_LINE_SPLIT.socket_send..":begin");
    elseif tag == LTMap.NetMsgRecv then
        __log(LOG_LINE_SPLIT.socket_recv..":begin");
    end
end

function add_log_split_end(tag)

    if tag == LTMap.NetMsgSend then
        __log(LOG_LINE_SPLIT.socket_send..":end");
    elseif tag == LTMap.NetMsgRecv then
        __log(LOG_LINE_SPLIT.socket_recv..":end");
    end
end

----通过tag找到配置,找不到用default配置
function __getConfigByTag( tag )
	tag = tag or LTMap.Default
	
	if bit.band(tag,LOG_SWITCH) ~= 0 then 
		return LCMap[tag]
	end
end

--分割线
function __gernerateSplit( config )
	local ret = ""
	if config[3] then 
		ret = "\n"..string.rep(config[3], config[4] or 100).."\n"
	end 	
	return ret 
end
--解析日志正文
function __gernerateBody( log )
	return inspect(log, {indent="    "})
end


