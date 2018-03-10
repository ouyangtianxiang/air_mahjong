require("audioConfig");

global_share_data = {d = nil, t = nil, qrcode = nil, bPortrait == false};

g_current_view_tag = GameConstant.view_tag.hall

function SystemGetSitemid()
	local platformStr = sys_get_string("platform");
	if(platformStr == "win32") then
		GameConstant.imei2 = System.getWindowsGuid();
		return GameConstant.imei2.."id".. 200;
	else
		-- 原生的
		return GameConstant.imei;
	end
end

function getLocalImsi()
	local platformStr = sys_get_string("platform");
	if(platformStr == "win32") then
		return System.getWindowsGuid();
	else
		return GameConstant.imsi;
	end
end

-- 修改是否是第一次启动的标记
function writeFirstStartGameState()
	local val = g_DiskDataMgr:getAppData("FirstStartGame", -1)
	if tonumber(val) == -1 then
		g_DiskDataMgr:setAppData("FirstStartGame",1)
	end
end


function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function toSplitPayMethod(array)
	if not array then
		return;
	end

	local splitFront = string.split(array,"{");
	local allNeedSplit = "";
	for i=1,#splitFront do
		if i == 2 then
			local text = string.split(splitFront[i],"}");
			allNeedSplit = text[1];
		end
	end

	local payTable = {};

	if allNeedSplit == "" then
		return;
	end

	local paymethods = string.split(allNeedSplit,",");
	for i=1,#paymethods do
		table.insert(payTable,tonumber(paymethods[i]));
	end
	-- local finish = string.find(array,"}");

	return payTable;
end

-- 是否是第一次启动游戏
-- 1是第一次启动游戏
function isFirstStartGame()
	return 1 == g_DiskDataMgr:getAppData("FirstStartGame",-1)
end

-- 将数字变成3位一节的形式
-- need 是否需要以亿、万为单位显示--ignoreNumCoun这个参数表明不需要7位以上才显示万
function trunNumberIntoThreeOneFormWithInt(value, need, ignoreNumCount)
	local valueString = tostring(value);
	local preSub = "";
	if "-" == string.sub(valueString,1,1) then
		valueString = string.sub(valueString , 2 ,-1);
		preSub = "-";
	elseif "+" == string.sub(valueString,1,1) then
		valueString = string.sub(valueString , 2 ,-1);
		preSub = "+";
	end
	local retString = "";
	local index = 0;
	local lastSub = "";
	if (ignoreNumCount and #valueString >= 5)  or (need and #valueString >= 7) then
		local intStr, flootStr ;
		if #valueString >= 9 then
			intStr, flootStr = math.modf(tonumber(valueString)/100000000);
			lastSub = "亿";
		else
			intStr, flootStr = math.modf(tonumber(valueString)/10000);
			lastSub = "万";
		end
		if flootStr > 0 then
			local temp;
			flootStr = flootStr * 10;
			flootStr = math.ceil( flootStr );
			temp, flootStr = math.modf(tonumber(flootStr)/10);
			flootStr = string.sub(flootStr, 2, 3);
		else
			flootStr = "";
		end
		retString = intStr..flootStr;
	else
		for i = 1 , string.len(valueString) do
			retString = string.format(retString..string.sub(valueString,i,i));
			index = string.len(valueString) - i;
			if index > 0 and 0 == (index % 3)  then
				retString = string.format(retString..",");
			end
		end
	end
	return preSub..retString..lastSub;
end

--得到一个小数的整数部分
function getIntPart(x)
    if x <= 0 then
       return math.ceil(x);
    end
    if math.ceil(x) == x then
       x = math.ceil(x);
    else
       x = math.ceil(x) - 1;
    end
    return x;
end

-- 返回需要的长度字段
function stringFormatWithString( aString , strMax, needDian)
	if nil == aString or aString == "" then
		return "";
	end
	aString = GameString.convert2UTF8(aString);
	local ret = getUTF_8String(aString , strMax);
	if nil == needDian or needDian then
		if ret ~= aString then
			ret = getUTF_8String(aString  , strMax-2).."..";
		end
	end
	return ret or "";
end

-- 获得utf8  strMax的长度字符串
function getUTF_8String(aString  , strMax)
	local ret = "";
	local n = string.len(aString);
	local offset = 1;
	local cp , b, e;
	local first = 1;
	local i = 1;
	while i <= n do
		if not b then
			b = i;
		end
		if offset > strMax then
			break;
		end
		cp = string.byte(aString, i);
		if cp >= 0xF0 then
			i = i + 4;
			offset = offset + 2;
		elseif cp >= 0xE0 then
			i = i + 3;
			offset = offset + 2;
		elseif cp >= 0xC0 then
			i = i + 2;
			offset = offset + 2;
		else
			i = i + 1;
			offset = offset + 1;
		end
		e = i;
	end
	if not b then
		return "";
	end
	if not e then
		e = n + 1;
	end
	ret = string.sub(aString, b, e-b);
	return ret;
end

-- 获得字符串的长度
function getStringLen( aString )
	if not aString or aString == "" then
		return 0;
	end
	local n = string.len(aString);
	local offset = 0;
	local cp ;
	local i = 1;
	while i <= n do
		cp = string.byte(aString, i);
		if cp >= 0xF0 then
			i = i + 4;
			offset = offset + 2;
		elseif cp >= 0xE0 then
			i = i + 3;
			offset = offset + 2;
		elseif cp >= 0xC0 then
			i = i + 2;
			offset = offset + 2;
		else
			i = i + 1;
			offset = offset + 1;
		end
	end
	return offset;
end

function native_muti_login(param)
	param = param or {}
	param.pluginId = PluginUtil:convertLoginId2Plugin(param.loginType or 0)
	local jsonStr = json.encode(param)
	native_to_java(kMutiLogin, jsonStr)
end

function native_muti_exit( param )
	g_DiskDataMgr:save()
	local param = {}
	param.pluginId = PluginUtil:convertPlatformId2Plugin(GameConstant.platformType or 0)
	local jsonStr = json.encode(param)
	native_to_java(kMutiExit, jsonStr)
end

function native_to_java(key, callParam)
	if not key or isPlatform_Win32() then
		DebugLog("No Win32 function-->" .. key);
		mahjongPrint(callParam)
		return false;
	end
	dict_set_string(kcallEvent, kcallEvent, key)

	if callParam then
		dict_set_string(key, key .. kparmPostfix, callParam);
	else
		dict_set_string(key, key .. kparmPostfix, json.encode({isGetValue = false}))
	end

	call_native("OnLuaCall")
	return true;
end

function native_to_get_value(key, callParam)
	local data
	if callParam == "" or callParam == nil then
		data = {}
	else
		data = json.decode(callParam)
	end
	data.isGetValue = true
	return native_to_java(key, json.encode(data))
end

-- 检查 原生语言返回 结果值
function initResult(keyParam)
	local callResult = dict_get_int(keyParam , kCallResult , -1);
	-- 获取数值失败
	if callResult == -1 then
		return nil;
	end
	local result = dict_get_string(keyParam , keyParam..kResultPostfix);
	-- dict_delete(keyParam);
    DebugLog("initResult result:"..tostring(result));
	local json_data = json.mahjong_decode_node(result);
	-- 返回错误json格式.
	if json_data then
		return json_data;
	else
		return nil;
	end
end

--判断图片是否存在：true 存在 false 不存在
function publ_isFileExsit_lua(imageName, fileFolder)
	if(nil == imageName or "" == imageName)then
		return false;
	end
	local folder = fileFolder or ""
	local param = {}
	param.imageName = imageName
	param.fileFolder = folder
	native_to_get_value(kIsFileExist, json.encode(param));
	local str = dict_get_string(kIsFileExist,kIsFileExist..kResultPostfix);
	if 1 == tonumber(str) then
		return true;
	else
		return false;
	end
end

function publ_IsResDownLoaded( type )
	local param = {};
	param.type = type;
	native_to_get_value(kIsResDownloaded, json.encode( param ));
	local str = dict_get_string(kIsResDownloaded,kIsResDownloaded..kResultPostfix);
	if not str then
		return false;
	end
	print( "publ_IsResDownLoaded="..str );
	if 1 == tonumber(str) then
		return true;
	else
		return false;
	end
end

--  下载单张图片,并且返回图片在sd卡中的名称(名称为pic_url通过md5生成的签名)
function publ_downloadImg( pic_url )
	if not pic_url or isPlatform_Win32() then
		DebugLog(" downloadImg failed : not pic_url or platform if win32 ");
		return "";
	end

	if string.find(pic_url, "default_woman") or string.find(pic_url, "default_man") then
		return "";
	end

	local picName = md5_string( pic_url );

	if not picName then
		return "";
	end

	if publ_isFileExsit_lua( picName..".png" ) then
		DebugLog(" image exsit in sdCard ");
		return picName..".png";
	end

	local post_data = {};
	post_data.ImageName = picName;
	post_data.ImageUrl = pic_url;
	DebugLog("native_to_java pic_url:"..pic_url);
	local dataStr = json.encode(post_data);
	native_to_java(kDownloadImageOne,dataStr);
	return picName..".png";
end

-- 下载多张图片，返回保存的图片名称数组（只下载SD卡中不存在的图片）
function publ_downloadImgs( imgUrlArray )
	if not imgUrlArray or sys_get_string("platform") == "win32" then
		DebugLog(" downloadImg failed : not pic_url or platform if win32 ");
		return "";
	end
	local nameTable = {};
	local post_data = {};
	for k,v in pairs(imgUrlArray) do
		if v then
			local picName = md5_string( v );
			if publ_isFileExsit_lua( picName..".png" ) then
				DebugLog(" image exsit in sdCard : "..v);
			else
				local entity = {};
				entity.ImageName = picName;
				entity.ImageUrl = v;
				table.insert(post_data, entity);
				table.insert(nameTable, picName..".png");
			end
		end
	end
	local platformStr = sys_get_string("platform");
	local data = {};
	data.entities = post_data;
	local dataStr = json.encode(data);
	native_to_java(kDownLoadImages,dataStr);
	return nameTable;
end

-- lua 切割字符串方法：str 待切割字符串， split_char 切割标志
function publ_luaStringSplit(str, split_char)
	local sub_str_tab = {};
	while (true) do
		local pos = string.find(str, split_char);
		if (not pos) then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end

	return sub_str_tab;
end

--根据图片名称删除图片
function publ_deleteImageByName_lua(imageName,prefix)

	if(imageName == nil)then
		return 0;
	end
	if(prefix == nil) then
		 prefix =" ";
	end
	local post_data={};
	post_data.imageName=imageName;
	post_data.prefix=prefix;
	local dataStr = json.encode(post_data);
	native_to_java(kDeleteImageByName, dataStr);
end


--显示textEdit 输入框
function publ_showEditText_lua(textValue)
	textValue = textValue or "";
	local  post_data = {};
	post_data.textValue = textValue;
	local  dataStr = json.encode(post_data);
	native_to_java(kShowEditText, dataStr);
end

-- url转码
function publ_urlEncodeLua(str)
	if str == nil then
		return "";
	end

	local platformStr = sys_get_string("platform");
	if platformStr == "win32" then
		str = string.gsub (str, "\n", "\r\n");
      	str = string.gsub (str, "([^%w ])",
         	function (c) return string.format ("%%%02X", string.byte(c)) end);
      	str = string.gsub (str, " ", "+");
		return str;
	end

	local data = {}
	data.str = str
	native_to_get_value(kurlEncode, json.encode(data))

	local str = dict_get_string(kurlEncode, kurlEncode .. kResultPostfix);
	return str;
end

-- 按照字符字节长度切割字符串
function publ_cutStringByByte( str, byteLen )
	if not str or not byteLen then
		return;
	end
	dict_set_string(kcutStringByByte, kcutStringByByte_str, str);
	dict_set_string(kcutStringByByte, kcutStringByByte_len, byteLen);
	native_to_java(kcutStringByByte);

	local str = dict_get_string(kcutStringByByte, kcutStringByByte..kResultPostfix);
	return str;
end


function publ_getItemFromTree( node, dir )
	if #dir < 1 or not node then
		return nil;
	end
	for i=1,#dir do
		node = node:getChildByName(dir[i]);
		if not node then
				return nil;
		end
	end
	return node;
end

function publ_isPointInRect(x, y, rextX, rectY, rectW, rectH)
	if x < rextX or x > rextX + rectW or y < rectY or y > rectY + rectH then
		return false;
	else
		return true;
	end
end

--去掉前后空格
function publ_trim (s)
	if s == nil then
		return;
	end
	return (string.gsub(s,"^%s*(.-)%s*$","%1"))
end

--深度拷贝一个table
function publ_deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end


--上传图片
function publ_updateImage(imageName,uploadUrl,api)
	local post_data = {};
	post_data.imageName = imageName;
	post_data.Url = uploadUrl;
	post_data.type = kUpdatePicType;
	local dataStr = json.encode(post_data);
	native_to_java(kUpLoadImage,dataStr);
end


function getPhoneIP()
    if isPlatform_Win32() then
        return "";
    end
    native_to_get_value(kGetPhoneNetIp);
    local str = dict_get_string(kGetPhoneNetIp,kGetPhoneNetIp..kResultPostfix);
    return str or "";
end

function publ_selectImage( imgName, url, api )
    if isPlatform_Win32() then
        DebugLog("【WIN32下无法选择图片】");
        return;
    end
    local post_data = {};
    post_data.ImageName = imgName;
    post_data.Url = url or "";
    post_data.Api = api or "";
    local dataStr = json.encode(post_data);
    native_to_java(kSelectImage, dataStr)
end

--下载资源
function publ_downloadResLua(dataStr)
	if(dataStr == nil) then
      return false;
	end
	if isPlatform_Win32() then
		DebugLog("Win32无法下载资源");
		return true;
	end
	return native_to_java(kDownloadRes, dataStr);
end

function pairsByKeys(t) --按key从小到大排序
	local a ={};
	for n in pairs(t) do
		table.insert(a,tonumber(n));
	end
	table.sort(a);
	local i = 0 ;
	local iter = function ()
		i = i + 1;
		if a[i] == nil then
			return nil;
		else
			return a[i],t[tostring(a[i])]
		end
	end
	return iter;
end

-- 获取某一年的某一月最大天数
function publ_getMaxDaysInMonth( year,month )
	local bigmonth = "(1)(3)(5)(7)(8)(10)(12)";
	local strmonth = "(" .. month .. ")";
	if tonumber(month) == 2 then
		if year % 4 == 0 or (year % 400 == 0 and year % 400 ~= 0) then
			return 29;
		else
			return 28;
		end
	elseif string.find(bigmonth,strmonth) ~= nil then
		return 31;
	else
		return 30;
	end
end

--跳转应用商店评分
function publ_launchTargetMarket(  )
	native_to_java(kLaunchMarket, "")
end
-- 友盟行为统计
function umengStatics_lua( msg )
	if(msg == nil or #msg==0) then
		return;
	end
	native_to_java(kUmengStatistics, msg);
end

--开启线程预加载声音
function preloadSound( music, effectTable )
	if isPlatform_Win32() or GameConstant.soundLoaded then
        return;
    end
	local params = {};
    params.bgMusic = music;
    params.soundRes = effectTable;
    local dataStr = json.encode(params);
    native_to_java(kLoadSoundRes, dataStr);
end

-- 精灵的显示和隐藏（0：隐藏   1：显示）
function showOrHide_sprite_lua(value)
    -- 如果不是在大厅或者还没初始化
    if not HallScene_instance and not PlatformFactory.curPlatform then
        return;
    end
    if PlayerManager.getInstance():myself().mid <= 0 then
        return;
    end
    local param = {}
    param.pluginId = PluginUtil:convertPlatformId2Plugin(GameConstant.platformType)
	if 0 == tonumber(value) then
		native_to_java(kMutiHideSprite, json.encode(param));
	else
		native_to_java(kMutiShowSprite, json.encode(param));
	end
end


function loadSoundCallback( callParam )
	GameConstant.soundLoaded = true;
    DebugLog("声音加载完毕，开始设置音量大小。");
    local jsonvalue = initResult(callParam);
    local status = jsonvalue.status
    if status and tonumber(status) == 1 then
        -- 设置当前音效、音乐音量
	    GameConstant.curMaxMusic = GameMusic.getInstance():getMaxVolume();
	    GameConstant.curMaxVoiceEffect = GameEffect.getInstance():getMaxVolume();
	    local voice = g_DiskDataMgr:getAppData('voice',-1)
	    local music = g_DiskDataMgr:getAppData('music',-1)
	    if voice == -1 then -- 还没有保存过值，默认0.5, 并且保存到本地
	        voice = 0.5;
	        music = 0.5;
	        g_DiskDataMgr:setAppData('music',music)
	        g_DiskDataMgr:setAppData('voice',voice)
	    end
	    GameMusic.getInstance():setVolume(music);
	    GameEffect.getInstance():setVolume(voice);
    end
    GameMusic.getInstance().m_loadedSounds["bgm"] = true;
    GameMusic.getInstance().m_loadedSounds["bgmHu"] = true;
    for k, v in pairs(EffectConfig) do
  		GameEffect.getInstance().m_loadedSounds[k] = true;
    end
end

-- 初始化下载音效
function initDownloadAudio( ver )
	DebugLog("开始预加载"..os.clock() * 1000);
	local music = GameMusic.getInstance();
    local effect = GameEffect.getInstance();
    DebugLog("开始预加载"..os.clock() * 1000);
    -- 完成配置信息
    music:setSoundFileMap(MusicConfig);

    effect:setSoundFileMap( g_DiskDataMgr:getAppData("language", kSichuanese) == kMandarin and MandarinDownloadEffectConfig or
    	DownloadEffectConfig);
		if GameConstant.iosDeviceType>0 then
			music:setPathPrefixAndExtName("music/", ".mp3");
		else
			music:setPathPrefixAndExtName("music/", ".ogg");
		end
    effect:setPathPrefixAndExtName("effect/", ".mp3");
end

function switchLanguageAudio( bMandarin )
	GameEffect.getInstance():unloadAll();
	GameEffect.getInstance():setSoundFileMap(bMandarin == kMandarin and MandarinDownloadEffectConfig or DownloadEffectConfig);
end

-- 初始化音频配置以及预加载音频文件
function initAudio( ver )
	if "1.2.1" == ver then
		return;
	end
    DebugLog("【开始音频初始化】"..os.clock() * 1000);
    local music = GameMusic.getInstance();
    local effect = GameEffect.getInstance();
    --完成配置信息
    music:setSoundFileMap(MusicConfig);
    effect:setSoundFileMap(EffectConfig);
		if GameConstant.iosDeviceType>0 then
			music:setPathPrefixAndExtName("music/", ".mp3");
	    effect:setPathPrefixAndExtName("effect/", ".mp3");
		else
			music:setPathPrefixAndExtName("music/", ".ogg");
	    effect:setPathPrefixAndExtName("effect/", ".ogg");
		end

    DebugLog("【音频初始化结束】"..os.clock() * 1000);
end

--将十进制数转换成十六进制字符串
function toHexByTen(num)
	local str = "";
	local locStr = "";
	while(num >=16) do
		local c = num % 16;
		locStr = changedCoreToHex(c);
		str = locStr .. str;
		num = math.modf(num / 16);
	end
	if num ~= 0 then
		str = changedCoreToHex(num) .. str;
	end
	if tonumber(str)<10 then
		str = "0" .. str;
	end
	return "0x" .. str;
end

--十六进制数字符串核心转换
function changedCoreToHex(num)
	if num == 10 then
		return "A";
	elseif num == 11 then
		return "B";
	elseif num == 12 then
		return "C";
	elseif num == 13 then
		return "D";
	elseif num == 14 then
		return "E";
	elseif num == 15 then
		return "F";
	else
		return tostring(num);
	end

end

--插值
--[[]]
function interpolator(from,to,duration,now)
	-- sin interpolate
	return now < duration and (from + (to - from ) * math.sin((now * math.pi)/ (2* duration))) or (to);
end

local mahjongScaleHeight_y = SCREEN_HEIGHT / MahjongLayout_H;
local mahjongScaleWidth_x = SCREEN_WIDTH / MahjongLayout_W;

--[[
	适配方案为以最小比例拉伸，微调拉伸差值
	control 为控件
	adaptXY == 0 或nil 则x y都微调
	adaptXY == 1 则x微调
	adaptXY == 2 则y微调
--]]
function makeTheControlAdaptResolution( control , adaptXY)
	if not adaptXY then
		adaptXY = 0;
	end
	if mahjongScaleHeight_y > mahjongScaleWidth_x then
		if 1 == adaptXY then
			return;
		end
		local height = control.m_height;
		local y1 = control.m_y / mahjongScaleWidth_x;
		local y2 = MahjongLayout_H - y1 - control.m_height;
		-- DebugLog("y1 : "..y1.."         y2 : "..y2);
		local offset = (height * mahjongScaleHeight_y - height * mahjongScaleWidth_x) / 2;
		local y = control.m_y * mahjongScaleHeight_y / mahjongScaleWidth_x;
		-- DebugLog("计算后的offest : "..offset);
		control:setPos(control.m_x / mahjongScaleWidth_x, (y + offset) / mahjongScaleWidth_x);
	else
		if 2 == adaptXY then
			return;
		end
		local width = control.m_width;
		local offset = (width * mahjongScaleWidth_x - width * mahjongScaleHeight_y) / 2;
		local x = control.m_x * mahjongScaleWidth_x / mahjongScaleHeight_y;
		control:setPos((x + offset) / mahjongScaleHeight_y , control.m_y / mahjongScaleHeight_y);
	end
	-- DebugLog("control.m_x : "..control.m_x.."      control.m_y :"..control.m_y);
end

--[[
	t 为适配前的大小
]]
function getAdapt( t )
	return t / System.getLayoutScale()
end

function showSceneTransitionAnim( oldScene , newScene )
	oldScene:setPos(0 , 0);
	newScene:setPos(MahjongLayout_W , 0);
	local anim = oldScene:addPropScale(1, kAnimNormal, 1000, 0, 1.0, 0.0, 1.0, 1.0);
	newScene:addPropScale(1, kAnimNormal, 1000, 0, 0.0, 1.0, 1.0, 1.0);
	anim:setEvent(nil , function (  )
		oldScene:setPos(-MahjongLayout_W , 0);
		oldScene:setSize(MahjongLayout_W , MahjongLayout_H);
		newScene:setPos(0 , 0);
		newScene:setSize(MahjongLayout_W , MahjongLayout_H);
	end);
end

-- 打印各种数据，便于查看
function mahjongPrint( data , dataName , spaceString, layer )
	DebugLog(data)
	-- if true then
	-- 	return
	-- end

	-- local layer = layer or 1

	-- if not data or 1 ~= DEBUGMODE then
	-- 	DebugLog("mahjongPrint : data not a vaild value");
	-- 	return;
	-- end
	-- System.setWin32ConsoleColor(0xB5E61D);
	-- -- if layer == 1 and type(data) == "table" then

	-- -- elseif layer == 1 then

	-- -- end

	-- spaceString = spaceString or "";
	-- dataName = dataName or "data";
	-- dataName = GameString.convert2UTF8(dataName) or "";
	-- if type(data) == "table" then
	-- 	-- for k , v in pairs(data) do
	-- 	-- 	-- if tostring(k) == "__value" then
	-- 	-- 		local outString = v or "nil";
	-- 	-- 		if type(v) == "string" then
	-- 	-- 			outString = "\""..outString.."\"";
	-- 	-- 		end
	-- 	-- 		if type(v) == "boolean" then
	-- 	-- 			if v then
	-- 	-- 				outString = "true";
	-- 	-- 			else
	-- 	-- 				outString = "false";
	-- 	-- 			end
	-- 	-- 		end
	-- 	-- 		DebugLog(spaceString..dataName.." = "..outString);
	-- 	-- 		return;
	-- 	-- 	-- end
	-- 	-- end---string.rep("abcd",2)	abcdabcd
	-- 	local pre = spaceString..dataName.." = {"
	-- 	local curPre = string.rep(" ",layer*4)
	-- 	DebugLog(pre);
	-- 	for k , v in pairs(data) do
	-- 		if type(v) == "table" then
	-- 			mahjongPrint(v , k , spaceString.."    ",layer+1);
	-- 		else
	-- 			local outString = v or "nil"
	-- 			if type(v) == "string" then
	-- 				outString = "\""..outString.."\""
	-- 			end
	-- 			if type(v) == "boolean" then
	-- 				if v then
	-- 					outString = "true"
	-- 				else
	-- 					outString = "false"
	-- 				end
	-- 			end
	-- 			System.setWin32ConsoleColor(0xB5E61D);
	-- 			DebugLog(curPre..k.." = ".. outString)
	-- 		end
	-- 	end
	-- 	System.setWin32ConsoleColor(0xB5E61D);
	-- 	DebugLog(spaceString.."}");

	-- else
	-- 	if type(data) == "boolean" then
	-- 		if data then
	-- 			data = "true";
	-- 		else
	-- 			data = "false";
	-- 		end
	-- 	end

	-- 	if not data then
	-- 		data = "";
	-- 	end
	-- 	data = GameString.convert2UTF8(data or "") or "";
	-- 	DebugLog(spaceString..dataName.." : ".. data);
	-- end

	-- System.setWin32ConsoleColor(0xffffff);
end

function getDateStringFromTime( time )
    if not time or string.len(publ_trim(time)) <= 0 then
        time = os.time();
    end
	local date = os.date("*t", time);
	return string.format("%02d月%02d日 %02d:%02d", date.month, date.day, date.hour, date.min);

end

function callPhone( phoneNumber )
	if GameConstant.iosDeviceType>0  then
		if phoneNumber then
			native_to_java( kCallPhone, tostring(phoneNumber) );
		else
			DebugLog("the phone number is nil");
		end
		return;
	end
	if GameConstant.simType == 0 then
		Banner.getInstance():showMsg("未检测到您的手机卡，请您检查您的手机卡槽。");
		return;
	end

	if phoneNumber then
		native_to_java( kCallPhone, tostring(phoneNumber) );
	else
		DebugLog("the phone number is nil");
	end
end

function callAddGroup(qqGroupNumber)
	if qqGroupNumber then
		local param = {};
		param.qqnumber = qqGroupNumber;
		native_to_java("qqAddGroup",json.encode(param));
	end
end

function isPlatform_Win32()
	local platform = System.getPlatform() or "";
	return kPlatformWin32 == platform;
end

function mahjongError(str)
	if 1 == DEBUGMODE then
		error(str or "");
	end
end

-- 获取table的全部个数，不同于用#
function countTable(_table)
	local count = 0;
	if not _table or "table" ~= type(_table) then
		return count;
	end
	for k , v in pairs(_table) do
		count = count + 1;
	end
	return count;
end

-- 如果微信未安装则返回0，安装了则返回1
function checkWechatInstalled()
	native_to_get_value(kCheckWechatInstalled);
	local res = dict_get_string(kCheckWechatInstalled, kCheckWechatInstalled .. kResultPostfix);
	return tonumber(res) or 0;
end


------------------------------------------调用 显示破产送金界面 全局函数-----------------------------------------------------
--[[
1.关闭结算界面（点击再来一局或者关闭按钮）
2.房间内点击准备和换桌
3.在大厅和房间个人信息点击 + 号
4.点击快速游戏、点击进入某个房间
5.玩家在每局游戏后，还会进行一次金币检测，当金币数低于破产指数（1000 金币），也会触发破产补助界面。（如流局后，扣除台费，金币不足1000）
]]

--[[
	function name	    : globalShowBankruptcyDlg.ctor
	description  	    : the global function to show bankRaptcy dialog
	param 	 	 	    : root 	-- root 	 which node to attach
					     from   -- string    from which scene
					     level  -- int  	 level in room

]]
--function globalShowBankruptcyDlg(level , obj , func)
--	require("MahjongCommon/BankruptcyDlg");
--	if PlayerManager.getInstance():myself().mid > 0 then
-- 		local bankDlg = new(BankruptcyDlg , level , obj , func);
-- 		bankDlg:addToRoot();
-- 	end
--end

--显示金币动画
function showGoldDropAnimation()
	-- body
	require("Animation/AnimationDropCoins");
	AnimationDropCoins.play();
end

--[[
	playerMoney : 玩家当前的金钱
	curLevel 	: 玩家当前的场次
	方法描述 	: 拿到最合适当前钱的level游戏(血战场+血流场)
]]
function getSuitableLevel( playerMoney, curLevel )
	DebugLog("curLevel --- " .. curLevel)
	--1.根据curLevel 找到当前玩家所在的场的大类  血战,血流,两房牌
  	local slevel = tostring(curLevel)
    local curType = HallConfigDataManager.getInstance():returnTypeForLevel(slevel)
	local curKey = HallConfigDataManager.getInstance():returnKeyByType(curType)
    --DebugLog("key: " .. curKey)
    if not curKey then  -- "xz"  or "xl"  or "lfp"
		--一般不会到这里
		DebugLog("配置有误，请查看配置信息，没有找到当前配置");
		return
    end

    local suc,hallData = HallConfigDataManager.getInstance():returnDataByKey(curKey,tonumber(playerMoney))
    if not suc or not hallData then
    	DebugLog("没有找到一个符合条件的场次，破产了或金币都不够")
    	return -1;
    end
    DebugLog("getSuitableLevel --- " .. hallData.level)
    return hallData.level
end

function requestJoinLowLevelRoom( roomlevel )
	local player = PlayerManager.getInstance():myself();
	GameConstant.lowSuitableLevel = getSuitableLevel( player.money, roomlevel );
	GameConstant.curRoomLevel = GameConstant.lowSuitableLevel;

	if not GameConstant.lowSuitableLevel and GameConstant.lowSuitableLevel ~= -1 then
		if RoomScene_instance then
			-- RoomScene_instance:exitGame();
			RoomScene_instance:sendExitCmd( true );
		end
		return;
	end

	GameConstant.isLowLevelClicked = true;
end

-- 友盟统计有多少热更新成功
function umengReportHotUpdate()

	require("Version");
	local mini_ver = g_DiskDataMgr:getAppData('mini_ver', 1)
	mini_ver = tonumber(mini_ver)

	if mini_ver ~= Version.mini_ver then 
		g_DiskDataMgr:setAppData('mini_ver', mini_ver)
		umengStatics_lua(UMENG_HOT_UPDATE_SUCCESS)
	end 
end

-- 记录请求热更新并上报首次请求热跟新
function reportRequstHotupdate()
	local hotupdate = g_DiskDataMgr:getAppData('is_request_hotupdate', -1)
	if hotupdate == -1 then
		g_DiskDataMgr:setAppData('is_request_hotupdate',1)
		umengStatics_lua( UMENG_REQUEST_HOTUPDATE );
	end
	reportSecondStartGame();
end

-- 上报第二次启动游戏
function reportSecondStartGame()
	DebugLog( "reportSecondStartGame" );
	local hotupdate = g_DiskDataMgr:getAppData('is_request_hotupdate', -1)
	if hotupdate == 1 then
		local startTimes = g_DiskDataMgr:getAppData('start_times', 0)--
		local temp = startTimes+1;
		g_DiskDataMgr:setAppData('start_times', temp)
		if temp == 2 then
			DebugLog( "reportSecondStartGame truely report" );
			umengStatics_lua( UMENG_SECOND_START_GAME );
		end
	end
end

-- 打印带时间的日志
function log( str )
	if DEBUGMODE == 1 then
		-- System.setWin32ConsoleColor(0x00A2E8);
		DebugLog( str );
		-- System.setWin32ConsoleColor(0xFFFFFF);
	else
		DebugLog = function()
		end
	end
end

function errlog( str )
	if DEBUGMODE == 1 then
		-- System.setWin32ConsoleColor(0xFF0000);
		DebugLog( str );
		-- System.setWin32ConsoleColor(0xFFFFFF);
	else
		DebugLog = function()
		end
	end
end


-- 弹窗落下
-- obj:    包含移动节点的obj
-- func:   移动结束后回调
-- window: 要移动的节点
function popWindowDown( obj, func, window )
	DebugLog("popWindowDown")
	if obj.isPlaying then
		return;
	end
	obj.isPlaying = true;
	obj:setVisible(true);

	local failedExitAction = function ( obj, func )
		if obj then
			obj.isPlaying = false
		end
		if obj and func then
			func(obj)
		end
	end

	local anim = window:addPropTransparency(0, kAnimNormal, 400, 0, 0.3, 1);
	if anim then
		anim:setEvent(self,function ()
			window:removeProp(0)
		end)
	end


	local anim = window:addPropScale(1, kAnimNormal, 200, 0, 1.2, 0.9, 1.2, 0.9, kCenterDrawing);
	if not anim then
		failedExitAction(obj,func)
		return
	end
	anim:setEvent(self, function()
		window:removeProp(1);
		local anim = window:addPropScale(1,kAnimNormal,100,0,0.9,1.05,0.9,1.05,kCenterDrawing)

		if not anim then
			failedExitAction(obj,func)
			return
		end

		anim:setEvent(self,function ()
			window:removeProp(1)
			local anim = window:addPropScale(1,kAnimNormal,100,0,1.05,1,1.05,1,kCenterDrawing)

			if not anim then
				failedExitAction(obj,func)
				return
			end

			anim:setEvent(self,function()
				window:removeProp(1)
				obj.isPlaying = false;
				if func and obj then
					func(obj);
				end

			end)
		end)
	end);

end

-- 弹窗收起
-- obj:    包含移动节点的obj
-- func:   移动结束后回调
-- window: 要移动的节点
function popWindowUp( obj, func, window )
	if obj.isPlaying then
		return;
	end
	obj.isPlaying = true;


	local exitAction = function ( obj, func )
		if obj then
			obj.isPlaying = false;
			obj:setVisible(false);
		end
		if func and obj then
			func(obj);
		end
	end


	local anim = window:addPropTransparency(0, kAnimNormal, 300, 0, 1, 0);
	if anim then
		anim:setEvent(self,function (  )
			window:removeProp(0)
		end)
	end

	local anim = window:addPropScale(1, kAnimNormal, 300, 0, 1, 1.1, 1, 1.1, kCenterDrawing)
	if not anim then
		exitAction(obj,func)
		return
	end
	anim:setEvent(self, function()
		window:removeProp(1);
		exitAction(obj,func)
	end);

end

function updateChangeNicknameTimes( data )
	DebugLog( "updateChangeNicknameTimes" );
	mahjongPrint( data );
	if not data then
		return;
	end
	--rawget(data,"data")
	local times1 = -1
	local times2 = -1
	if rawget(data,"viptimes") then
		times1 = tonumber(GetNumFromJsonTable(data, "viptimes", 0))
	end
	if rawget(data,"vipTimes") then
		times2 = tonumber(GetNumFromJsonTable(data, "vipTimes", 0));
	end
	if times1 ~= -1 or times2 ~= -1 then
		GameConstant.changeNickTimes.vipTimes = math.max(times1,times2)
	end

	if rawget(data,"bqknum") then
		GameConstant.changeNickTimes.bqknum = GetNumFromJsonTable(data, "bqknum", 0);
	end

	if rawget(data,"propnum") then
		GameConstant.changeNickTimes.propnum = GetNumFromJsonTable(data, "propnum", 0);
	end

	if rawget(data,"rednum") then
		GameConstant.changeNickTimes.rednum = GetNumFromJsonTable(data, "rednum", 0);
	end

	if rawget(data,"cardnum") then
		GameConstant.changeNickTimes.cardsNum = GetNumFromJsonTable(data, "cardnum", 0);
	end

	if data.goodsid and tonumber( data.goodsid or 0 ) == ItemManager.CHANGE_NICK_CID then
		GameConstant.changeNickTimes.cardsNum = GameConstant.changeNickTimes.cardsNum + 1;
	end

	require("MahjongHall/UserInfo/ChangeNicknameWnd");
	EventDispatcher.getInstance():dispatch( ChangeNicknameWnd.updateLeftTimesEvent );
    --请求道具列表
	GlobalDataManager.getInstance():onRequestMyItemList();
end

function getSign( a )
	if a > 0 then
		return 1
	elseif a < 0 then
		return -1
	else
		return 0
	end
end

function moveby( node, x,y )
	local cx,cy = node:getPos()
	node:setPos(cx+x,cy+y)
end

function setMaskImg( img_node , mask_file_path, img_file_path  )
	if not img_node then
		return
	end

	if img_node.m_photoImageMask then
		img_node.m_photoImageMask:removeFromSuper()
		img_node.m_photoImageMask = nil
	end

	if not mask_file_path then
		return
	end

	require("coreex/mask")
	img_node.m_photoImageMask = new(Mask,img_file_path,mask_file_path)
	img_node:addChild(img_node.m_photoImageMask)
	img_node.m_photoImageMask:setAlign(kAlignCenter)
end


function setImgToResSize( node )
	if node then
        local res = node.m_res
        if res then
            node:setSize(res.m_width or 1, res.m_height or 1)
        end
	end
end

function setMoney3Node( value, node, pinTuMap )
	local str = tostring(value)
	local moneyNode = node or new(Node)
	moneyNode:removeAllChildren()

	local w,h = 0,0
	local x,y = 0,0
	for i=1,#str do
		local img = UICreator.createImg( pinTuMap[string.sub(str,i,i) .. ".png"], x, y)
		moneyNode:addChild(img)
		x = x + img.m_res.m_width
		h = math.max(h, img.m_res.m_height)
	end
	moneyNode:setSize(x,h)
	return moneyNode
end

function setMoney2Node( value,node )
    local number3Pin_map = require("qnPlist/number3Pin")
	local intStr,floatStr = math.modf(value/10000)
	intStr = tostring(intStr)

	local moneyNode = node or new(Node)
	moneyNode:removeAllChildren()

	local w,h = 0,0
	local x,y = 0,0
	for i = 1,string.len(intStr) do
		local img = UICreator.createImg( number3Pin_map[string.sub(intStr,i,i)..".png"] , x, y );
		moneyNode:addChild(img)
		x = x + img.m_res.m_width;
		h = math.max(h, img.m_res.m_height)
	end
	--万金币

	local img = UICreator.createImg( number3Pin_map["wan.png"] , x,y )
	moneyNode:addChild(img)
	x = x + img.m_res.m_width
	h = math.max(h, img.m_res.m_height)

	img = UICreator.createImg( number3Pin_map["jinbi.png"] , x,y )
	moneyNode:addChild(img)
	x = x + img.m_res.m_width
	h = math.max(h, img.m_res.m_height)

	moneyNode:setSize(x,h)
	return moneyNode
end

function blinkNode( node, duration, times )
	if not node then
		return
	end

	local dur       = duration or 100 --ms
	local times     = times or 2
	local animIndex = 0


	if not node:checkAddProp(0) then
		node:removeProp(0)
	end
	local w,h = node:getSize()
	local anim = node:addPropTranslate(0 ,kAnimRepeat ,100 ,0,0,0,0,0)
	anim:setDebugName("Anim | blinkNode")
	anim:setEvent(node,function (node)
		animIndex = animIndex + 1
		if animIndex > times*2+1 then
			node:removeProp(0)
		elseif animIndex % 2 == 1 then
			node:setText(node:getText(),w,h, 0x17, 0xe3, 0x77)--0x17, 0xe3, 0x77
		else
			node:setText(node:getText(),w,h, 0xff, 0x00, 0x00)
		end
	end)
end

function setMoneyNode( value,node )
	if not value then
		return nil
	end

	local valueString = tostring(value);

	local preSign = nil
	if "-" == string.sub(valueString,1,1) then
		valueString = string.sub(valueString , 2 ,-1);
		preSign = true;
	elseif "+" == string.sub(valueString,1,1) then
		valueString = string.sub(valueString , 2 ,-1);
	end


	local retString = "";
	local index = 0;
	local lastSub = nil;
	--parse to string
    local b_hundredMillion = false;
	if #valueString >= 7 then
		local intStr, flootStr ;
		if #valueString >= 9 then
			intStr, flootStr = math.modf(tonumber(valueString)/100000000);
			lastSub = "oneHundredMillion.png";
            b_hundredMillion = true;
		else
			intStr, flootStr = math.modf(tonumber(valueString)/10000);
			lastSub = "hundred.png";
		end

		if flootStr > 0 then
            local str = tostring(flootStr)--"0.125";
            local len = b_hundredMillion == true and 5 or 4
            if string.len(str) >= len then
               str = string.sub(str, len,len);
               if tonumber(str) >= 5 then
                   flootStr = flootStr + (b_hundredMillion == true and 0.01 or 0.1);
                   if flootStr >= 1 then
                      flootStr = flootStr - 1;

                      intStr = intStr + 1;
                      if  intStr >= 10000 then
                         lastSub = "oneHundredMillion.png";
                         b_hundredMillion = true;
                         intStr = 1;
                         flootStr = 0;
                      end
                   else
                       --flootStr = flootStr - 0.01;
                   end
               end
            end
            --本来这一行就可以的，android 的 format 和 win32不一样，所以要下面n多判断，后期再改，先这样 flootStr = string.format("%.1f",flootStr);
            flootStr = string.format("%s",tostring(flootStr))
            if b_hundredMillion then
                if string.len(flootStr) >=4 then
                    flootStr = string.sub(flootStr, 2,4)
                elseif string.len(flootStr) >=2 then
                    flootStr = string.sub(flootStr, 2)
                else
                    flootStr = "";
                end
                --flootStr = string.format("%.2f",flootStr);
            else
                if string.len(flootStr) >= 3 then
                    flootStr = string.sub(flootStr, 2,3)
                elseif string.len(flootStr) >=2 then
                    flootStr = string.sub(flootStr, 2)
                else
                    flootStr = "";
                end
                --flootStr = string.format("%.1f",flootStr);
            end

            --flootStr = string.sub(flootStr, 2);
		else
			flootStr = "";
		end
		retString = intStr..flootStr;

	else
		for i = 1 , string.len(valueString) do
			retString = string.format(retString..string.sub(valueString,i,i));
			index = string.len(valueString) - i;
			if index > 0 and 0 == (index % 3)  then--3位一个,号
				retString = string.format(retString..",");
			end
		end
	end

	if preSign then
		retString = "-"..retString
	end

	local imgPrePath = "Commonx/money/"

	local getImgName = function ( s )
		if s == "." then
			return "point.png"
		elseif s == "," then
			return "split.png"
		elseif s == "-" then
			return "sub.png"
		else
			return s .. ".png"
		end
		--return "0.png"
	end

	local moneyNode = node or new(Node)
	moneyNode:removeAllChildren()

	local w,h = 0,0
	local x,y = 0,0
	for i = 1,string.len(retString) do
		local img = UICreator.createImg( imgPrePath .. getImgName( string.sub(retString,i,i) ) , x, y );
		moneyNode:addChild(img)
		x = x + img.m_res.m_width;
		h = math.max(h, img.m_res.m_height)
	end

	if lastSub then
		local img = UICreator.createImg( imgPrePath ..lastSub , x,y )
		moneyNode:addChild(img)
		x = x + img.m_res.m_width
		h = math.max(h, img.m_res.m_height)
	end

	moneyNode:setSize(x,h)
	return moneyNode

end

function global_http_readUrlFile(url, callback)
	require("coreex/downAddReadFile")
	local request = new(DownAddReadFile, url , 5000)
	request:setEvent(callback)
	request:execute()
end

---目前两房牌只有血战

function global_get_wanfa_desc( wanfa )

    if not wanfa or not tonumber(wanfa) then
        return "";
    end
    wanfa = tonumber(wanfa)

	local pre,mid
	local isLFP = false
	if bit.band(wanfa, 0x10) ~= 0 then
		pre   = "两房牌"
		isLFP = true
	end

	if bit.band(wanfa, 0x02) ~= 0 then
		pre = "血流成河"
	end

	if not pre then
		pre = "血战到底"
	end

	if bit.band(wanfa, 0x04) ~= 0 then
		if isLFP then
			mid = "换两张"
		else
			mid = "换三张"
		end

		return pre .. "、"..mid
	end
	return pre
end


--根据比赛id获得level和matchtype
function global_get_type_and_level_by_matchid(str_matchid)
        --str_matchid:"20160811165914|2|86|8526|8613|0000|2|8616";
        if not str_matchid or type(str_matchid) ~= "string" then
            DebugLog("str_matchid is nil");
            return;
        end
        local tmp = string.split(str_matchid, "|")
        local go_match_type = nil;
        if tmp and #tmp >= 3 then
           return tonumber(tmp[2]), tonumber(tmp[3]);
        end
end

function global_share_create_game(w, data)
    local num_friend_fail_map = require("qnPlist/num_friend_fail")
    local num_friend_win_map = require("qnPlist/num_friend_win")

    local x_msg , y_msg, blank = 0,420, 50;

    local msg_bg = w.k_msg_bg;
    local layout = w.k_layout;
    local v_bg = w.k_v_bg;

    w.k_girl:setPos(0, -100);
    w.k_msg_bg:setPos(x_msg,y_msg);
    w.k_logo:setAlign(kAlignTopRight);
    w.k_logo:setPos(15, 160);
    --w.k_qrCodeBg:setPos(x_msg+blank,y_msg-360);
    w.k_v_bg:setPos(0, 250);

    --title
    local title = new(Image, "share/cup.png");
    title:setAlign(kAlignTop);
    title:setPos(0,-150);
    layout:addChild(title)

    --消息框里的图片
    local msg = new(Image, "share/img_1.png");
    msg:setAlign(kAlignCenter);
    msg:setPos(0,10);
    msg_bg:addChild(msg)

    local root = new(Node);
    --root:setAlign(kAlignCenter);
    --root:setPos(12.5,20);
    root:setAlign(kAlignLeft);
    v_bg:addChild(root);

    local cardScale = 1--0.5625
    local currentX = 0;

	local cardW = 88--*cardScale;
	local cardH = 128--*cardScale;
    local ajustX = -6--*cardScale;
    local ajustCardFW, ajustCardFH = 5,2.5;


    local angangList = data.angang;
    local gangList = data.gang;
    local pengList = data.peng;
    local handList = data.handcard;
	--创建暗杠牌
	if angangList and angangList ~= {} then
		if angangList[1] ~= "0" then
			for i = 2, #angangList do
                local value = angangList[i]
                if not value then
                    break;
                end
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getAnGangImageFileBySeat(kSeatMine, PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, currentX, 0);
					card:setSize(cardW, cardH);
					root:addChild(card);
					currentX = currentX + cardW - 1 + ajustX;
					if k == 2 then
						local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,value,PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
						local card = UICreator.createImg(baseDir, currentX - cardW + 1 - ajustX, -30*cardScale);
						local cardF = UICreator.createImg(faceDir);
						card:addChild(cardF);

--						card:setSize(cardW, cardH);
--						cardF:setSize(faceDir.width*cardScale, faceDir.height*cardScale);
--						cardF:setPos(offsetX*cardScale-ajustCardFW, offsetY*cardScale-ajustCardFH);
						root:addChild(card);
					end
				end
			end
		end
	end

	--创建杠牌
	if gangList and gangList ~= {} then
		if gangList[1] ~= "0" then
			for i = 2, #gangList do
                local value = gangList[i]
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,value,PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, currentX, 0);
					local cardF = UICreator.createImg(faceDir);
					card:addChild(cardF);

--					card:setSize(cardW, cardH);
--					cardF:setSize(faceDir.width*cardScale, faceDir.height*cardScale);
					cardF:setPos(offsetX*cardScale-ajustCardFW, offsetY*cardScale-ajustCardFH);
					root:addChild(card);
					currentX = currentX + cardW + 1 + ajustX;
					if k == 2 then
						local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,gangList[i],PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
						local card = UICreator.createImg(baseDir, currentX - cardW - 1 - ajustX, -30*cardScale);
						local cardF = UICreator.createImg(faceDir);
						card:addChild(cardF);
--						card:setSize(cardW, cardH);
--						cardF:setSize(faceDir.width*cardScale, faceDir.height*cardScale);
--						cardF:setPos(offsetX*cardScale-ajustCardFW, offsetY*cardScale-ajustCardFH);
						root:addChild(card);
					end
				end

			end
		end
	end

	--创建碰牌
	if pengList and pengList ~= {} then
		if pengList[1] ~= "0" then
			for i = 2, #pengList do
                local value = pengList[i];
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,value,PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, currentX, 0);
					local cardF = UICreator.createImg(faceDir);
					card:addChild(cardF);

--					card:setSize(cardW, cardH);
--					cardF:setSize(faceDir.width*cardScale, faceDir.height*cardScale);
--					cardF:setPos(offsetX*cardScale-ajustCardFW, offsetY*cardScale-ajustCardFH);
					root:addChild(card);
					currentX = currentX + cardW + 1 + ajustX;
				end
			end
		end
	end

	--创建手牌
	for k, v in pairs(handList) do
        local value = v.value;
		if value and value ~= "0" then
            local baseDir, faceDir, offsetX, offsetY =  getPengGangImageFileBySeat(kSeatMine,value,PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
			local card = UICreator.createImg(baseDir, currentX, 0);
			local cardF = UICreator.createImg(faceDir);
			card:addChild(cardF);

--			card:setSize(cardW, cardH);
--			cardF:setSize(faceDir.width*cardScale, faceDir.height*cardScale);
--			cardF:setPos(offsetX*cardScale-ajustCardFW, offsetY*cardScale-ajustCardFH);
			root:addChild(card);
			currentX = currentX + cardW + 1 + ajustX;
		end
	end

    local tmpScale = 0.5625;

    local totalOffsetX = (currentX)*tmpScale;
    local v_bgW, _ = v_bg:getSize();
    local nodeX = 0;
    if totalOffsetX <  v_bgW then
        nodeX = (v_bgW-totalOffsetX)/2;
    end
    DebugLog("sharex:"..v_bgW.." :"..totalOffsetX.." :"..nodeX);
    root:setPos(nodeX, 20);

	root:addPropScaleSolid(0,tmpScale, tmpScale, kCenterTopLeft);

    local win_node = new(Node);
--    win_node:setAlign(kAlignCenter);
--    v_bg:addChild(win_node);

    --输赢金币
    local winFile = "";
    local map = "";
    if tonumber(data.money) and tonumber(data.money) >= 0 then
        map = num_friend_win_map;
        winFile = num_friend_win_map["win.png"];
    else
        map = num_friend_fail_map;
        winFile = num_friend_fail_map["fail.png"];
    end
    local x_win, y_win = 0, 0;
    local winImg = new(Image, winFile)
    winImg:setAlign(kAlignLeft);
    --winImg:setScale(currentScale,currentScale);
    winImg:setPos(x_win, y_win);
    win_node:addChild(winImg);

    local money = tostring(data.money or "")
    --money = trunNumberIntoThreeOneFormWithInt(money, true);
    local tmpMap = { --[","] = "point_3.png",
                        --["，"] = "point_2.png",
                        --["."] = "point_1.png",
                        --["万"] = "tenThousand.png",
                        --["亿"] = "hundredMillion.png",
                        ["0"] = "0.png",
                        ["1"] = "1.png",
                        ["2"] = "2.png",
                        ["3"] = "3.png",
                        ["4"] = "4.png",
                        ["5"] = "5.png",
                        ["6"] = "6.png",
                        ["7"] = "7.png",
                        ["8"] = "8.png",
                        ["9"] = "9.png",
                        };
    local cParentW, cParentH = winImg:getSize();
    local cW = 56--*currentScale;
    local blank = 18--*currentScale;
    local charCount = 1;
    for j = 1, string.len(money) do
        local curByte = string.byte(money, j)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = string.sub(money, j, j+byteCount-1)
        j = j + byteCount -1
        if tmpMap[char] and map then
            local img = new(Image, map[tmpMap[char]]);
            img:setAlign(kAlignLeft);
            --img:setScale(currentScale,currentScale);
            tmpW = blank+cParentW+cW*(charCount-1);
            img:setPos(tmpW, 0);
            winImg:addChild(img);

            charCount = charCount + 1;
        end
    end
    local coinImg = new(Image, "share/coin.png");
    coinImg:setAlign(kAlignLeft);
    win_node:addChild(coinImg);
    local px, py = winImg:getPos();
    coinImg:setPos(px+blank+cW*(charCount+1),  13);

    win_node:setSize(cParentW+ blank+cW*(charCount+1),0);
    win_node:setPos(0,-80);
    win_node:setAlign(kAlignCenter);

    v_bg:addChild(win_node);
end

function global_share_create_exchange(w, data)

    local x_msg , y_msg, blank = 0,505, 25;
    local msg_bg = w.k_msg_bg;
    local layout = w.k_layout;
    local v_bg = w.k_v_bg;

    w.k_girl:setPos(0, 0);
    msg_bg:setPos(x_msg,y_msg);
    w.k_logo:setPos(x_msg+blank,y_msg-200);
    --w.k_qrCodeBg:setPos(x_msg+blank, y_msg-360);




    --消息框里的图片
    local msg = new(Image, "share/img_2.png");
    msg:setAlign(kAlignCenter);
    msg:setPos(0,10);
    msg_bg:addChild(msg)

    --title
    local title = new(Image, "Hall/exchange/img_title.png");
    title:setAlign(kAlignTop);
    title:setPos(0,20);
    layout:addChild(title)

--    --光img_light
    local light = new(Image, "Hall/exchange/img_light.png");
    light:setAlign(kAlignCenter);
    light:setPos(0,0);
    v_bg:addChild(light)

    local defaultPath = "Hall/HallMall/coin1.png";
    --奖品
    local award = new(Image, defaultPath);--"Commonx/blank.png");
    award:setFile(data.imgPath or defaultPath);
    award:setSize(160*1.5, 126*1.5);
    award:setAlign(kAlignCenter);
    award:setPos(0,-30);

    --award:setScale(1.5,1.5);
    v_bg:addChild(award)

    --text bg
    local t_bg = new(Image,"Hall/exchange/img_text_bg.png");
    t_bg:setAlign(kAlignBottom);
    t_bg:setPos(0,10);
    v_bg:addChild(t_bg)

    local nameStr = tostring(data.name or "")
    nameStr = stringFormatWithString(nameStr, 12, true);
    --奖品名字
    local name = new(Text, nameStr, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
    name:setAlign(kAlignCenter);
    t_bg:addChild(name);
end

function global_share_create_friend_match(w, data)
    local num_friend_fail_map = require("qnPlist/num_friend_fail")
    local num_friend_win_map = require("qnPlist/num_friend_win")
    local timeStr = nil;
    --消息框里的图片
    local msg = new(Image, "share/img_3.png");
    msg:setAlign(kAlignCenter);
    msg:setPos(0,10);
    w.k_msg_bg:addChild(msg)

    --title
    local title = new(Image, "share/img_4.png");
    title:setAlign(kAlignTop);
    title:setPos(0,20);
    w.k_layout:addChild(title)


    local x_msg , y_msg, blank = 0,430, 45;
    w.k_girl:setPos(0, -100);
    w.k_msg_bg:setPos(x_msg,y_msg);
    w.k_logo:setPos(x_msg+blank,y_msg-90);
    --w.k_qrCodeBg:setPos(x_msg+blank,y_msg-360);

    local v_bg = w.k_v_bg;

    local tmpw,tmph = v_bg:getSize();
    v_bg:setSize(tmpw,tmph+100*System.getLayoutScale());

    local currentTime = os.date("%Y-%m-%d %H:%M:%S");
    --local tmpSTr = tostring(data.time or currentTime or "");
    timeStr = getDateStringFromTime(data.time);

    --时间
    local time = new(Text, timeStr, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
    time:setAlign(kAlignTopLeft);
    time:setPos(25,30);
    time:setText(timeStr);
    v_bg:addChild(time);
    --line
    local line = new(Image, "Commonx/split_hori.png");
    local w_line, h_line = line:getSize();
    line:setAlign(kAlignTop);
    line:setPos(0, 80);
    line:setSize(600, h_line);
    v_bg:addChild(line);

    --玩法
    local t_type = new(Text, timeStr, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0x00)
    t_type:setAlign(kAlignTopLeft);
    t_type:setPos(10,100);
    t_type:setText(tmpSTr);
    v_bg:addChild(t_type);
    tmpSTr = global_get_wanfa_desc(tonumber(data.type or 0))--"血流 换三张";
    t_type:setText(tmpSTr);

    local x_pos , y_pos = 13, 155;
    --总流水
    local t_tmp = new(Text, "总流水:", 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0x00)
    t_tmp:setAlign(kAlignTopLeft);
    t_tmp:setPos(x_pos,y_pos);
    v_bg:addChild(t_tmp);

    --排序
    local tmpData = {};
    for j = 1, 4 do
        for k = j+1,4 do
            if tonumber(data[j].money) < tonumber(data[k].money) then
                local tmp = data[j];
                data[j] = data[k];
                data[k] = tmp;
            end
        end
    end

    local blank_h = 64;
    local allMoney = {};
    for i = 1, 4 do
        local d = data[i] or { name ="", money = ""}
        allMoney[#allMoney+1] = {money = tonumber(d.money) or 0}

        local nameStr = tostring(d.name or "")
        nameStr = stringFormatWithString(nameStr, 12, true);

        local textPlayer = new(Text, nameStr, 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
        textPlayer:setAlign(kAlignTopLeft);
        textPlayer:setPos(x_pos+125, y_pos+ blank_h*(i-1));
        v_bg:addChild(textPlayer);

        local currentScale = 0.5;
        local winFile = "";
        local map = "";
        if tonumber(d.money) and tonumber(d.money) >= 0 then
            map = num_friend_win_map;
            winFile = num_friend_win_map["win.png"];
        else
            map = num_friend_fail_map;
            winFile = num_friend_fail_map["fail.png"];
        end
        local winImg = new(Image, winFile)--"Commonx/blank.png");
        winImg:setAlign(kAlignTopLeft);
        winImg:addPropScaleSolid(0,currentScale, currentScale, kCenterTopLeft);
        --winImg:setScale(currentScale,currentScale);
        winImg:setPos(x_pos+330, y_pos+ blank_h*(i-1) -15);
        v_bg:addChild(winImg);

        local money = tostring(d.money or "")
        money = trunNumberIntoThreeOneFormWithInt(money, true);
        local tmpMap = { --[","] = "point_3.png",
                            --["，"] = "point_2.png",
                            --["."] = "point_1.png",
                            ["万"] = "tenThousand.png",
                            ["亿"] = "hundredMillion.png",
                            ["0"] = "0.png",
                            ["1"] = "1.png",
                            ["2"] = "2.png",
                            ["3"] = "3.png",
                            ["4"] = "4.png",
                            ["5"] = "5.png",
                            ["6"] = "6.png",
                            ["7"] = "7.png",
                            ["8"] = "8.png",
                            ["9"] = "9.png",
                            };
        local cParentW, cParentH = winImg:getSize();
        local cW = 56--*currentScale;
        local blank = 18--*currentScale;
        local charCount = 1;
        for j = 1, string.len(money) do
            local curByte = string.byte(money, j)
            local byteCount = 1;
            if curByte>0 and curByte<=127 then
                byteCount = 1
            elseif curByte>=192 and curByte<223 then
                byteCount = 2
            elseif curByte>=224 and curByte<239 then
                byteCount = 3
            elseif curByte>=240 and curByte<=247 then
                byteCount = 4
            end
            local char = string.sub(money, j, j+byteCount-1)
            j = j + byteCount -1
            if tmpMap[char] and map then
                local img = new(Image, map[tmpMap[char]]);
                img:setAlign(kAlignLeft);
                --img:addPropScaleSolid(0,currentScale, currentScale, kCenterTopLeft);
                --img:setScale(currentScale,currentScale);
                tmpW = blank+cParentW+cW*(charCount-1);
                img:setPos(tmpW, 0);
                winImg:addChild(img);

                charCount = charCount + 1;
            end
        end

        --因为第一个是有奖杯的
        if i == 1 then
            local awardImg = new(Image, "Hall/friend/img_award.png");
            awardImg:setAlign(kAlignTopLeft);
            awardImg:setSize(100,100);
            v_bg:addChild(awardImg);
            local px = winImg:getPos();
            awardImg:setPos(px+blank*currentScale+cParentW*currentScale+cW*currentScale*(charCount)+5,  y_pos-42);
        end
    end
end

-- 向java发起截图请求
function global_screen_shot(shareData)
	if tonumber(shareData.t)==GameConstant.shareConfig.game then
		local iosdata = {};
		iosdata.d = {};
		iosdata.t = shareData.t;
		iosdata.b = shareData.b;
		iosdata.share = shareData.share

		local myself = PlayerManager.getInstance():myself();

		local handBaseDir = {};
		local cardsInfo = {};
		local handcard = {};
		for k, v in pairs(shareData.d.handcard) do
			if not v.value then
					break;
			end
			DebugLog("v:"..tostring(v.value))
			local baseDir, faceDir = getPengGangImageFileBySeat(kSeatMine,v.value,myself:checkVipStatu(myself.VIP_MZZ));
			if #handBaseDir==0 then
				handBaseDir = baseDir;
			end
			cardsInfo[tostring(v.value)] = faceDir;
			handcard[#handcard+1] = v.value;
		end

		local proccessfunction = function (lflist)
			local locallist = {};
			if lflist[1] ~= "0" then
				for i = 2, #lflist do
						local value = lflist[i]
						if not value then
								break;
						end
						local baseDir, faceDir = getPengGangImageFileBySeat(kSeatMine,value,myself:checkVipStatu(myself.VIP_MZZ));
						if #handBaseDir==0 then
							handBaseDir = baseDir;
						end
						cardsInfo[tostring(value)] = faceDir;
						locallist[#locallist+1] = value;
				end
			end
			return locallist;
		end

		local angangList = shareData.d.angang;
		local gangList = shareData.d.gang;
		local pengList = shareData.d.peng;
		local iosdataAngang = proccessfunction(angangList);
		local iosdataGang = proccessfunction(gangList);
		local iosdataPeng = proccessfunction(pengList);

		iosdata.d.handcard = handcard;
		iosdata.d.angang = iosdataAngang;
		iosdata.d.gang = iosdataGang;
		iosdata.d.peng = iosdataPeng;
		iosdata.d.cardsInfo = cardsInfo;
		iosdata.d.handBaseDir = handBaseDir;
		if shareData.d.money then
			iosdata.d.money = shareData.d.money;
		end
		-- DebugLog("iosdata iosdata ....")
		-- DebugLog(iosdata)
		native_to_java("ShareDataInfo", json.encode(iosdata));
	else
		if shareData.d then
    		shareData.d.title = global_get_wanfa_desc(shareData.d.type or 0)
    	end
		native_to_java("ShareDataInfo", json.encode(shareData));
	end
--     native_to_java( kScreenShot , json.encode( data ) );
--     --下面代码是windows下模拟测试
--     --global_show_share_wnd();
-- end
end


--创建分享的图片--好友对战和牌局记录的分享--截图全部由原生写了
function global_show_share_wnd()--(data, t)
    DebugLog("global_show_share_wnd");

--    if not global_share_data then
--        DebugLog("global_share_data is nil");
--        return;
--    end
--    --清理下缓存
--    TextureCache.instance():clean_unused();

--    data = global_share_data.d
--    t = global_share_data.t;

--    DebugLog("global_share_data t:"..tostring(t).." d:"..tostring(data).." qrcode:"..tostring(global_share_data.q));

--    local friendShareWndLayout = require(ViewLuaPath.."friendShareWndLayout");
--    local num_friend_fail_map = require("qnPlist/num_friend_fail")

--    local num_friend_win_map = require("qnPlist/num_friend_win")


--    local w_layout = global_share_data.b and  720 or 1280--*System.getLayoutScale() or 1280*System.getLayoutScale()
--    local h_layout = global_share_data.b and  1280 or 720--*System.getLayoutScale() or 720*System.getLayoutScale()

--    local util_show_sharewnd = function (w)
--        Loading.hideLoadingAnim();
--        --截屏
--        local share_w  = w;
--        share_w:update()
--        -- 创建fbo，传入size，第二个参数可选，可传入现成的贴图。
--        local fbo = FBO.create(Point(w_layout*System.getLayoutScale(),h_layout*System.getLayoutScale()))
--        fbo:render(share_w)
--        -- 将fbo内容保存成rgba格式的png文件（目前只支持png格式）。
--        local shareFileName = "share.png";
--        local storagePath = "images/"..shareFileName
--        local apkStoragePath = System.getStorageImagePath()..shareFileName;
--        fbo:save(apkStoragePath)
--        fbo:save(storagePath)

--        if global_share_data.qrbg then
--            global_share_data.qrbg:removeFromSuper();
--            global_share_data.qrbg = nil;
--        end
--        local shareWindow = new( ShareWindow, shareFileName, global_share_data );
--        --shareWindow.t = global_share_data.t;
--	    shareWindow:addToRoot()
--	    shareWindow:show();
--	    shareWindow:setOnCloseListener( shareWindow, function( shareWindow )
--            --游戏中的奖状界面 分享结束后要显示奖状上的btn
--            if shareWindow.t and  shareWindow.t == GameConstant.shareConfig.certificate then
--                if GameConstant.curGameSceneRef and GameConstant.curGameSceneRef ~= HallScene_instance then
--                    if GameConstant.curGameSceneRef.certificateWnd and GameConstant.curGameSceneRef.certificateWnd.showBtn then
--                        GameConstant.curGameSceneRef.certificateWnd:showBtn();
--                    end
--                end
--            elseif shareWindow.t and  shareWindow.t == GameConstant.shareConfig.game then
--                if GameConstant.curGameSceneRef and GameConstant.curGameSceneRef ~= HallScene_instance then
--                    if GameConstant.curGameSceneRef.resultView and GameConstant.curGameSceneRef.resultView.screenShot then
--                        GameConstant.curGameSceneRef.resultView:screenShot(false);
--                    end
--                end

--            end
--		    delete(shareWindow)
--		    shareWindow = nil;
--	    end);
--    end

--    local layout = new(Node);
--    layout:setSize(w_layout, h_layout);
--    layout:setClip( 0,0,w_layout,h_layout);

--    local imgBg = new(Image, "share/bg.png");
--    imgBg:setAlign(kAlignCenter);
--    imgBg:setVisible(global_share_data.b);
--    layout:addChild(imgBg);

--    layout:setEventTouch(wnd, function ( obj, finger_action, x, y, drawing_id_first, drawing_id_current)
--        if finger_action == kFingerUp then
--			obj:hideWnd();
--		end
--    end);

--    --bg
--    local v_bg = new(Image, "share/img_6.png");
--    v_bg:setAlign(kAlignTop);
--    v_bg:setPos(0, 150);
--    layout:addChild(v_bg);
--    v_bg:setVisible(global_share_data.b);

--    local girl = new(Image, "share/girl.png");
--    girl:setAlign(kAlignBottomLeft)
--    girl:setVisible(global_share_data.b);
--    layout:addChild(girl);

--    local qrCodeBg = new(Image, "share/qr_code_bg.png");
--    local qrW, qrH = qrCodeBg:getSize();
--    local scale = 1;
--    qrCodeBg:setSize(qrW*scale,qrH*scale);
--    qrCodeBg:setAlign(kAlignBottomRight);
--    qrCodeBg:setPos(25,20);


--    if global_share_data.q then
--        local qrCode = new(Image, global_share_data.q);
--        qrCode:setAlign(kAlignCenter);
--        qrCode:setSize(240*scale, 240*scale);
--        qrCode:setPos(0, -10);
--        qrCodeBg:addChild(qrCode);
--    end

--    --box
--    local msg_bg = new(Image, "share/msg_bg.png");
--    msg_bg:setAlign(kAlignBottomRight);
--    layout:addChild(msg_bg);
--    msg_bg:setVisible(global_share_data.b);

--    --logo
--    local logo = new(Image, "share/logo.png");
--    logo:setAlign(kAlignBottomRight);
--    logo:setVisible(global_share_data.b);

--    layout:addChild(logo);



--    local widget = {k_layout = layout, k_qrCodeBg = qrCodeBg, k_v_bg = v_bg, k_girl = girl, k_logo = logo, k_msg_bg = msg_bg};

--    global_share_data.qrbg = nil;
--    if t == GameConstant.shareConfig.exchange then
--        global_share_create_exchange(widget, data);
--        layout:addChild(qrCodeBg);
--    elseif t == GameConstant.shareConfig.game then
--        global_share_create_game(widget, data);
--        layout:addChild(qrCodeBg);
--    elseif t == GameConstant.shareConfig.friendMatch then
--        global_share_create_friend_match(widget, data);
--        layout:addChild(qrCodeBg);
--    elseif t == GameConstant.shareConfig.certificate then
--        qrCodeBg:addToRoot();
--        global_share_data.qrbg = qrCodeBg;
--    elseif t == GameConstant.shareConfig.hongbao then
--        qrCodeBg:addToRoot();
--        global_share_data.qrbg = qrCodeBg;
--    end

--    util_show_sharewnd(global_share_data.b and layout:getWidget() or Window.instance().drawing_root);

end

--转化moneytype  传入参数GameConstant.sc_money_type 转化为对应的商品type或者兑换type 目前moneytype只有两种 兑换的和商品的
function global_transform_money_type(moneytype , is_exchange)

    local m_type = nil
    if moneytype == GameConstant.sc_money_type.coin then
        m_type = is_exchange and GameConstant.exchange_money_type.coin or GameConstant.mall_money_type.coin;
    else
        m_type = is_exchange and GameConstant.exchange_money_type.diamond or GameConstant.mall_money_type.diamond;
    end
    return m_type;
end

--转化moneytypee对应的商品type或者兑换type (目前moneytype只有两种 兑换的和商品的)  传入参数 转化为GameConstant.sc_money_typ
function global_transform_money_type_2(moneytype , is_exchange)

    local m_type = nil
    if is_exchange then
        m_type = moneytype == GameConstant.exchange_money_type.coin and GameConstant.sc_money_type.coin or GameConstant.sc_money_type.diamond
    else
        m_type = moneytype == GameConstant.mall_money_type.coin and GameConstant.sc_money_type.coin or GameConstant.sc_money_type.diamond
    end
    return m_type;
end

function table.maxValue(t)
		if not t or type(t) ~= "table" then
			  return 0
		end
    local count = 0
		for k,v in pairs(t) do
		    count = count + 1
		end
		return count
end

function checkShowPlayerTurn(cards)
	if cards then
		if cards%3 == 2 then
			return true
		end
	end
	return false;
end

---
--入参:filePathName:传入带完整路径的文件名 string类型
-------value    :要替换的内容              string类型
-------toValue  :替换之后的内容            string类型
-------findFlag :标志  如果该标志不为空,必须先找到该标志才替换 否则不进行任何操作  string类型 or nil
---Example:globalModifyFile( 'E:\Resource\xx.plist', '5.3.0', '5.3.1' )
function globalModifyFile( filePathName, value, toValue, findFlag )
    --检查参数合法性
    if not filePathName or not value or not toValue then 
    	return 
    end 
    --读取文件内容
    local readContent = nil
    local outContent  = nil
    local fhander = io.open(filePathName,"rb")
    
    if fhander then 
        readContent = fhander:read('*all')
        fhander:close() 

        if readContent then 
	        if findFlag then 
	        	local b,e = string.find(readContent,findFlag)
	        	if not b or not e then 
	        		return 
	        	end 
	        end 

	        local b,e = string.find(readContent,value)
	        if b and e then 
	            outContent = string.sub(readContent,1,b-1) .. toValue .. string.sub(readContent,e+1)
	            fhander = io.open(filePathName,"wb")
	            if fhander then 
	                fhander:write(outContent)
	                fhander:close() 
	            end 
	        end 
	    end     
    end 
end

--
global_get_current_view_tag = function ()
    return g_current_view_tag;
end

global_set_current_view_tag = function (tag)
    if not tag then
        return;
    end
    g_current_view_tag = tag;
end