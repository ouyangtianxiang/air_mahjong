local friendScoreItemLayout = require(ViewLuaPath.."friendScoreItemLayout");


FriendPlayRecordItem = class(Node);

--好友 元素
FriendPlayRecordItem.ctor = function ( self, data)
	DebugLog("FriendPlayRecordItem.ctor")
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
    self:init(data);
end

FriendPlayRecordItem.dtor = function ( self )
	DebugLog("FriendPlayRecordItem.dtor")
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
end

FriendPlayRecordItem.init = function (self,data)
    DebugLog("FriendPlayRecordItem.init")
    self.m_data = data;

    local d = data
    local item = SceneLoader.load(friendScoreItemLayout);
    local itemW, itemH = item:getSize();
    --item:setPos(0, (itemH+ tmpH)*(i-1));
        
    self:addChild(item);

    --时间
    local t_time = publ_getItemFromTree(item, {"bg", "time"});
    --游戏玩法
    local t_type = publ_getItemFromTree(item, {"bg", "game_type"});

    --分享按钮
    local btnShare = publ_getItemFromTree(item, {"bg", "share"});
    btnShare.dataIndex = i;
    --local obj = {o = self, btn = btnShare};
    btnShare:setOnClick(self, self.eventShare);

    if not PlatformFactory.curPlatform:needToShareWindow() then 
        btnShare:setVisible(false);
    end

    --时间
    local tmpSTr = tostring(d.time or "");
    tmpSTr = getDateStringFromTime(tmpSTr);
    t_time:setText(tmpSTr);

    --玩法
    tmpSTr = global_get_wanfa_desc(tonumber(d.type));
    t_type:setText(tmpSTr);

    for j = 1, #d.play do
        local dd = d.play[j]
        if dd then
            --玩家1
            local nameStr = tostring(dd.name or "")
            nameStr = stringFormatWithString(nameStr, 6, false)..":";
            local money = tostring(dd.money or "")
            local tmp = "";
            if tonumber(money) and tonumber(money) >=0 then
                tmp = "+";
            end
            money = trunNumberIntoThreeOneFormWithInt(money, true);
            nameStr = nameStr..tmp..money;
            nameStr = stringFormatWithString(nameStr, 14, false);
            local t_p = publ_getItemFromTree(item, {"bg", "t_"..j});
            if t_p then
                t_p:setText(nameStr);
            end
        end
    end
    self:setPos(0,0);
    self:setSize(item:getSize());

    self.m_shareCallback = { obj = nil, func = nil};
end


--
FriendPlayRecordItem.setOnClickShare = function ( self, obj, func)
	-- body
    self.m_shareCallback.obj = obj;
    self.m_shareCallback.func= func;
end


FriendPlayRecordItem.eventShare = function (self)
    DebugLog("FriendPlayRecordItem.eventShare");

    if not self.m_data then
        return;
    end
    local touchData = self.m_data;
    local data = {};
    data.time = touchData.time or "";
    data.type = touchData.type or "";
   
    for i = 1, #(touchData.play or {}) do
        local tmp = {};
        tmp.name = touchData.play[i].name or "";
        tmp.money = touchData.play[i].money or "";
        table.insert(data, tmp);
    end
    --dataIndex
    --创建牌局总结算界面
--    local data = {
--    time = "1984555543",
--    type = "血战.换三张",
--    [1] = {name = "hyq_1", money = "12"},
--    [2] = {name = "hyq_2", money = "-100"},
--    [3] = {name = "hyq_3", money = "15"},
--    [4] = {name = "hyq_4", money = "-900"},
--    };
    --分享数据
    math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
	local rand = math.random();
	local index = math.modf( rand*1000%6 );
	local player = PlayerManager.getInstance():myself();

	local dd = {};
	dd.title = PlatformFactory.curPlatform:getApplicationShareName();
	dd.content = kShareTextContent[ index or 1 ];
	dd.username = player.nickName or "川麻小王子";
	dd.url = GameConstant.shareMessage.url or ""

    local shareData = {d = data, share = dd , t = GameConstant.shareConfig.friendMatch, b = true};
    global_screen_shot(shareData);
end

--截图
FriendPlayRecordItem.screenShot = function (self)
--    if not self.m_data.isScreenShot then
--        self.m_data.isScreenShot = true;
--        DebugLog("FriendPlayRecordItem.screenShot 发送截图请求");
--        math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
--	    local rand = math.random();
--	    local index = math.modf( rand*1000%6 );
--	    local player = PlayerManager.getInstance():myself();

--	    local data = {};
--	    data.title = PlatformFactory.curPlatform:getApplicationShareName();
--	    data.content = kShareTextContent[ index or 1 ];
--	    data.username = player.nickName or "川麻小王子";
--	    data.url = GameConstant.shareMessage.url or ""
--        native_to_java( kScreenShot , json.encode( data ) );-- 向java发起截图请求
--    end
end

FriendPlayRecordItem.callEvent = function(self, param, data)
    DebugLog("FriendPlayRecordItem.callEvent-----:param:"..param or "-1`");
    DebugLog("FriendPlayRecordItem.callEvent-----:data:"..(data and tostring(data) or "-1`"));
    if not data then
        return;
    end
--    if kScreenShot == param then -- 显示分享窗口
--	end
end