local layout_match_rank_item = require(ViewLuaPath.."layout_match_rank_item")

--缓存每次头像相关信息的http请求
--未写入文件的缓存，每次重新进入游戏会重新缓存
local l_match_rank_data_cache = {};

local l_func_check_had_item = function (mid)
    if not mid then
        return;
    end
    mid = tostring(mid)
    return l_match_rank_data_cache[mid];
end  

local l_func_add_item_to_cache = function (mid, mnick, small_image, sex)
    if not mid or not mnick or not small_image or not sex then
        return;
    end

    local item = {
                name = mnick, 
                head_url = small_image,
                sex =  sex}; 
    l_match_rank_data_cache[tostring(mid)] = item; 
end    


MatchRankItem = class(Node);

--好友 元素
MatchRankItem.ctor = function ( self, data)
	DebugLog("[MatchRankItem]:ctor")
    if not data then
        DebugLog("data is nil");
        return;
    end
    self.m_data = data;
    self:init();
end

MatchRankItem.dtor = function ( self )
	DebugLog("MatchRankItem.dtor")
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    self.m_name = nil;
    self.m_head = nil;
end

MatchRankItem.init = function (self,data)
	self.m_layout = SceneLoader.load(layout_match_rank_item);
    self:setSize(self.m_layout:getSize());
    self:addChild(self.m_layout);
   
    --原生回调事件
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    --Php回调事件
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

    --名次
    self.m_rank = publ_getItemFromTree(self.m_layout, {"v", "t_rank"});
    --头像
    self.m_head = publ_getItemFromTree(self.m_layout, {"v", "head"});
    --名字
    self.m_name = publ_getItemFromTree(self.m_layout, {"v", "t_name"});    
    --积分
    self.m_score = publ_getItemFromTree(self.m_layout, {"v", "t_score"});

    local tmp_str = "";

    --名次
    tmp_str = tostring(self.m_data.rank or "")--最多3个字符
    tmp_str = stringFormatWithString(tmp_str, 3, false)
    self.m_rank:setText(tmp_str);

--    --名字
--    tmp_str = tostring(self.m_data.name or "") --最多六个字
--    tmp_str = stringFormatWithString(tmp_str, 12, false)
--    self.m_name:setText(tmp_str);

    --积分 --超过1w的显示万
    tmp_str = tostring(trunNumberIntoThreeOneFormWithInt(self.m_data.score or 0,false, true)).."分"
    tmp_str = stringFormatWithString(tmp_str, 8, false)
    self.m_score:setText(tmp_str);
    local item = l_func_check_had_item(self.m_data.mid);
    if item then
        self:set_name(item.name);
        self:set_head(item.head_url, item.sex);
    else
        --头像
        self:send_php_get_userinfo(self.m_data.mid);
    end

end


MatchRankItem.set_name = function (self , name)
    if not name or not self.m_name then
        return;
    end
    local tmp_str = tostring(name or "") --最多六个字
    tmp_str = stringFormatWithString(tmp_str, 12, false)
    self.m_name:setText(tmp_str);

end


MatchRankItem.set_head =  function ( self, url, sex)
    DebugLog("[MatchRankItem]:set_head url:"..tostring(url).." sex:"..tostring(sex));
    if not url then
        DebugLog("url is nil");
        return;
    end
    if not self.m_head then
        DebugLog("self.m_head is nil");
        return;
    end

    local isExist, localDir = NativeManager.getInstance():downloadImage(url);
	self.m_head_dir = localDir;
    if not isExist then -- 图片已下载
    	if tonumber(sex) == kSexMan then
            localDir = "Commonx/default_man.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
				localDir = "Login/yx/Commonx/default_man.png";
			end
	    else
            localDir = "Commonx/default_woman.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
				localDir = "Login/yx/Commonx/default_woman.png";
			end
    	end
    end
    setMaskImg(self.m_head,"match_rank/head_mask.png",localDir)

end

--发送php 获取个人信息
MatchRankItem.send_php_get_userinfo = function (self, mid)
    DebugLog("[MatchRankItem]:send_php_get_userinfo mid:"..tostring(mid));
    if not mid then
        DebugLog("mid is nil");
        return;
    end

    local param = {}
	param.mid   = PlayerManager:getInstance():myself().mid
            
	param.fmids = {}
    table.insert(param.fmids, mid);
	param.fields= {"mnick"	, "sex","large_image", "small_image",};

	SocketManager.getInstance():sendPack(PHP_CMD_QUERY_USER_INFO,param);
end

--个人信息回调
MatchRankItem.php_callback_get_userinfo = function (self, isSuccess, data, jsonData)
    DebugLog("[MatchRankItem]:php_callback_get_userinfo");
    if isSuccess and data then
        if data.data and data.data[1] and self.m_data.mid and data.data[1].mid then

            if tonumber(data.data[1].mid) == tonumber(self.m_data.mid) then
                l_func_add_item_to_cache(data.data[1].mid, data.data[1].mnick, data.data[1].small_image, data.data[1].sex);             
                self:set_name(data.data[1].mnick);
                self:set_head(data.data[1].small_image, data.data[1].sex);
            end
        end    
    end

end





MatchRankItem.nativeCallEvent = function(self, _param, _detailData)
    DebugLog("[MatchRankItem]:nativeCallEvent");
    if _param == kDownloadImageOne then
        DebugLog("_param:"..tostring(_param).." _detailData:"..tostring(_detailData).." self.m_head_dir:"..tostring(self.m_head_dir));
        if _detailData == self.m_head_dir and self.m_head then
        	setMaskImg(self.m_head,"match_rank/head_mask.png",self.m_head_dir)
        end
    end
end

--php 回调
MatchRankItem.phpMsgResponseCallBackFuncMap = 
{
    [PHP_CMD_QUERY_USER_INFO] = MatchRankItem.php_callback_get_userinfo,
};
--php 回调
MatchRankItem.onPhpMsgResponse = function( self, param, cmd, isSuccess)
    if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end





