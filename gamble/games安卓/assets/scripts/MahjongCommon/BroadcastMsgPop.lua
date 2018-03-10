local broadcastPopWin = require(ViewLuaPath.."new_braodcast_wnd_layout");--require(ViewLuaPath.."broadcastPopWin");
require("MahjongCommon/BroadcastMsgItem");

local l_const_str = {
hint = "输入聊天内容",
};

BroadcastMsgPop = class(SCWindow);

BroadcastMsgPop.ctor = function(self)
	self.m_BroadcastMsgManager = BroadcastMsgManager.getInstance();
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():register(GlobalDataManager.myItemListUpdated,self,self.event_item_change);
	self:setCoverTransparent()
	self:setAutoRemove(false)
	self:load();
end

BroadcastMsgPop.load = function ( self )
    self:setLevel(1000);
	self.layout = SceneLoader.load(broadcastPopWin);
	self:addChild(self.layout);

	self.bg   = publ_getItemFromTree(self.layout, { "img" });


	self:setWindowNode( self.bg );

	self.innerBg = self.bg
	self.closeBtn = publ_getItemFromTree(self.bg, { "btn_close"});

    self.m_v_extra = publ_getItemFromTree(self.bg, {"v_extra"});

	self.scrollBtnList = publ_getItemFromTree(self.bg, {"v_extra", "extra","scrollview"}); 
    self.scrollBtnList:setDirection(kVertical);
	self:initSelectButtons()

    --喇叭数量 GameConstant.changeNickTimes.propnum
    self.m_t_laba = publ_getItemFromTree(self.bg, {"text_img", "img_braodcast", "t"});

	self.cover:setEventTouch(self, function(self)
		self:hideWnd()
		--popWindowUp(self, self.hideHandler, self.bg);
	end);

	self.bg:setEventTouch(self, function(self)
	end);

	self.closeBtn:setOnClick(self, function(self)
		self:hideWnd()
		--popWindowUp(self, self.hideHandler, self.bg);
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType
	then
		self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.bg:setFile("Login/wdj/Hall/Commonx/chat_window_bg.png");
	end

    --edittext
    self.m_edittext = publ_getItemFromTree(self.bg, {"text_img", "edittext"});
    self.m_edittext:setLevel(2);
    self.m_edittext:setMaxLength(13);

    self.m_edittext:setHintText(l_const_str.hint);
    self.m_edittext:setOnTextChange(self, self.edittext_on_change);


    local _y , _w, _h = 30, 830, 390
	self.scrollNode = new(ScrollView, 0, _y , _w, _h, false);
    self.scrollNode.coing ={ y = _y, w = _w, h = _h };
    self.scrollNode:setAlign(kAlignTop);
	self.scrollNode:setScrollBarWidth(5);
	self.innerBg:addChild(self.scrollNode);
	self.scrollNode:setSize(self.scrollNode:getSize());
	self:createMsgItem();

    --send btn
    local btn_send = publ_getItemFromTree(self.bg, {"btn_send"});
    btn_send:setOnClick(self, function (self)

        if GameConstant.changeNickTimes.propnum < 1 then
		    Banner.getInstance():showMsg("您缺少喇叭，请购买");
		    require("MahjongCommon/ExchangePopu");
		    --self:hideWnd(true)
		    self:showExchangePopu();
		    return false
	    end
        local str = self:get_edittext_str();
        if self:check_msg(str) then--字符检查
            local myself = PlayerManager.getInstance():myself();

            self:useBroadcastTrumpet(str, myself.mid);
        end
        if self.m_edittext then
            self.m_edittext:setText("");
            self.m_edittext:setHintText(l_const_str.hint);
        end
    end);

    --
    self.m_v_extra:setEventTouch(self, function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp then
             if drawing_id_first ~= drawing_id_current then
                return;
            end
            self.m_v_extra:setVisible(false);
        end
    end);

    --常用选项按钮
    local t = publ_getItemFromTree(self.bg, {"text_img", "t"});
    t:setLevel(3);
    t:setEventTouch(self, function (self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp then
					if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
						self.m_v_extra:setVisible(false);
						return ;
					end
             if drawing_id_first ~= drawing_id_current then
                return;
            end
            self.m_v_extra:setVisible(true);
        end
    end);
    self.closeBtn:setLevel(100);
    self.m_v_extra:setLevel(90);
end

--更新喇叭
BroadcastMsgPop.update_laba = function (self)
    if self.m_t_laba then
        self.m_t_laba:setText(tostring(GameConstant.changeNickTimes.propnum));
    end
end

--初始化视图
BroadcastMsgPop.init_view = function (self)

    if self.m_v_extra then
        self.m_v_extra:setVisible(false);
    end
    if self.m_edittext then
        self.m_edittext:setText("");
        self.m_edittext:setHintText(l_const_str.hint);
    end

    self:update_laba();

end

BroadcastMsgPop.hideWnd = function (self)

    if self.m_v_extra then
        self.m_v_extra:setVisible(false);
    end
    self.super.hideWnd(self);
end
--获取输入框中的text
BroadcastMsgPop.get_edittext_str = function (self)
    local str = self.m_edittext:getText();-- publ_trim(self.m_edittext:getText());
    return str;
end

--输入字符 改变
BroadcastMsgPop.edittext_on_change = function ( self )

	local str = publ_trim(self.m_edittext:getText());
	local len = string.len(str);
    if len < 1 then
        self.m_edittext:setText("");
        self.m_edittext:setHintText(l_const_str.searchHint);
    else
    end
    --检测只能输入数字
end

BroadcastMsgPop.check_msg = function (self, str)

    if not str or string.len(publ_trim(str)) < 1 then
        DebugLog("输入错误，请输入正确的字符。");
        return false;
    end
    --缺少喇叭
    return true;

end

function BroadcastMsgPop.initSelectButtons( self )
	--self.scrollBtnList
	local createBtnFunc = function ( self, imgName, x, y, textStr, obj, func)
		local btn = UICreator.createBtn(imgName,x or 0,y or 0,obj, func)
		self.scrollBtnList:addChild(btn)
		if textStr then
			local btntext = UICreator.createText(textStr, 0, -4, 0, 0, kAlignCenter, 28, 0xff, 0xff, 0xdc);
			btntext:setAlign(kAlignCenter)
			btn:addChild(btntext)
		end
		return btn
	end

	local msgInfo = GlobalDataManager.getInstance().trumpetMessageList
	if not msgInfo then
		return
	end

	--830 - 4*192 - 3*10 = 32
	local startX = 36
	local offX   = 10
	local startY = -105--10--20
	local offY   = 10--5--10
	local endY = 0;
	for i=1,#msgInfo do
		local int = math.modf((i-1)/3);
		endY = startY+(62+offY)*int--startY+(62+offY)*int
		local btn = createBtnFunc(self,"Commonx/red_small_wide_btn.png",startX+(192+offX)*((i-1)%3),endY,""..msgInfo[i].desc)--self,"Commonx/red_small_wide_btn.png",startX+(192+offX)*((i-1)),endY,""..msgInfo[i].desc)--self,"Commonx/red_small_wide_btn.png",startX+(192+offX)*((i-1)%4),endY,""..msgInfo[i].desc)
        btn:setAlign(kAlignLeft);
		btn:setOnClick(self,function (self)
			self:clickMsgButtons(i)
		end)

	end

	--endY = endY + startY + 62
	--self.scrollBtnList:setSize(830,140)
end

function BroadcastMsgPop.clickMsgButtons( self , index)
	DebugLog("BroadcastMsgPop.clickMsgButtons index:" .. index)
	--------------------get msg
	if not self:checkSendConditionIsValid(index) then
		return
	end
	self:sendMsgByIndex(index)
    if self.m_v_extra then
        self.m_v_extra:setVisible(false);
    end
end


function BroadcastMsgPop.sendMsgByIndex( self, index )
	local str,id = self:getSendMsgByIndex(index)
	self:useBroadcastTrumpet(str,id);
end

--[[
	self.nativeBtn:setOnClick(self, function(self)
		self.commonUseBg:setVisible(false);
		self.editText:setText("有没有" .. (PlayerManager.getInstance():myself().location or "火星") .. "的人儿呀？加个好友一起打牌呗~");
		self.cleanBtn:setVisible(true);
	end);

	self.moneyBtn:setOnClick(self, function(self)
		self.editText:setText("各望各路英雄送点金币！加个好友，金币互有！")
		self.commonUseBg:setVisible(false);
		self.cleanBtn:setVisible(true);
	end);

	self.lackBtn:setOnClick(self, function(self)
		local str = "";
		if RoomScene_instance then
				str = self:getRoomInfo() .. "，三缺一！高手在哪儿？";
		else
			str = "哪里三缺一？速速露个面，我们过几招！";
		end
		self.editText:setText(str);
		self.commonUseBg:setVisible(false);
		self.cleanBtn:setVisible(true);
	end);
]]

function BroadcastMsgPop.getSendMsgByIndex( self, index )
	local msgInfo = GlobalDataManager.getInstance().trumpetMessageList
	if not msgInfo or not index or index < 1 or index > #msgInfo then
		return "",nil
	end

	local str = ""
	local mytype = tonumber(msgInfo[index].type)

	if mytype == 3 then --三缺一
		if RoomScene_instance then
			str = self:getRoomInfo() .. "，三缺一！高手在哪儿？";
		else
			str = "哪里三缺一？速速露个面，我们过几招！";
		end
	elseif mytype == 1 then --找同乡
		str = "有没有" .. (PlayerManager.getInstance():myself().location or "火星") .. "的人儿呀？加个好友一起打牌呗~"
	elseif mytype == 2 then --送金币
		str = "各望各路英雄送点金币！加个好友，金币互有！"
	end

	return str,msgInfo[index].id
end

function BroadcastMsgPop.checkSendConditionIsValid( self,index )
	if  GameConstant.changeNickTimes.propnum < 1 then
		Banner.getInstance():showMsg("您缺少喇叭，请购买");
		require("MahjongCommon/ExchangePopu");
		--self:hideWnd(true)
		self:showExchangePopu(index);
		return false
	end
--[[
	if not msg or msg == "" then
		DebugLog("发送聊天信息失败，字符不合法。");
		Banner.getInstance():showMsg("您发送的信息为空。");
		return  false
	end
]]
	return true
end

-- 请求使用喇叭进行广播
BroadcastMsgPop.useBroadcastTrumpet = function ( self, str,id )
	-- 友盟上报喇叭使用次数
	DebugLog("id:"..tostring(id) .. ",str:"..tostring(str))
	umengStatics_lua(kUmengRoomChatSpeaker);

	local msg = str

	local param = {};
	param.msg  = str or ""
	param.id   = id or ""
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_USE_BROADCAST_TRUMPET, param);

end




BroadcastMsgPop.addTopNews = function( self )
	if self.topNewsView then
		self.topNewsView:removeAllChildren();
		self.topNewsView = nil;
	end

	local maxWidth = 830;
	self.topNewsView = new( Node );
	self.topNewsView:setPos( 0, 20 );
	self.topNewsView:setSize( maxWidth, 0 );
	self.innerBg:addChild( self.topNewsView );

	local topNews = BroadcastMsgManager.getInstance():getTopNews();
	local height = 0;
	require("MahjongCommon/BroadcastTopNewsItem");
	for k,data in pairs(topNews) do
		if data.start_time/1000 < os.time() then
			DebugLog( "create top news item" );
			local item = new(BroadcastTopNewsItem, data, maxWidth );
			local _, itemHeight = item:getContentSize();
			self.topNewsView:addChild( item );
			item:setPos( 0, height );
			item:setOnLinkClick( self, function( self )
				self:hideWnd()
			end);
			height = height + itemHeight;
		end
	end
	self.topNewsView:setSize(0,height);

	self.scrollNode:setPos( 0, height + self.scrollNode.coing.y );
	self.scrollNode:setSize( maxWidth, self.scrollNode.coing.h - height );
end

BroadcastMsgPop.flushMesItem = function ( self )
	self.scrollNode:removeAllChildren(true);
	local broacastMsgNum = #self.m_BroadcastMsgManager.m_queueForWin;
	local x,y = 0,0;
	for i=1, broacastMsgNum do
		local broadcastMsgItem = new(BroadcastMsgItem, self.m_BroadcastMsgManager.m_queueForWin[i], self);
		broadcastMsgItem:setPos(x,y);
		local h = broadcastMsgItem:getTotalLength();
		y = y + h;
		self.scrollNode:addChild(broadcastMsgItem);
	end
end


BroadcastMsgPop.createMsgItem = function ( self )
	self.scrollNode:removeAllChildren(true);


	local broacastMsgNum = #self.m_BroadcastMsgManager.m_queueForWin;
	local x,y = 0,0;
	for i=1, broacastMsgNum do
		local broadcastMsgItem = new(BroadcastMsgItem, self.m_BroadcastMsgManager.m_queueForWin[i], self);
		broadcastMsgItem:setPos(x,y);
		local h = broadcastMsgItem:getTotalLength();
		y = y + h;
		self.scrollNode:addChild(broadcastMsgItem);
	end


	self:addTopNews()
    self:init_view();

	self:showWnd()
end

BroadcastMsgPop.showExchangePopu = function ( self,index )

	--local str,id = self:getSendMsgByIndex(index)
	--self:useBroadcastTrumpet(str,id);

	require("MahjongCommon/ExchangePopu");
	self.exchangePopu = new(ExchangePopu, ItemManager.LABA_CID, HallScene_instance or RoomScene_instance,index);
	self.exchangePopu:setOnWindowHideListener( self, function( self )
		self.exchangePopu = nil;
	end);
end


BroadcastMsgPop.searchFriendById = function(self, search_mid_table)
	DebugLog("BroadcastMsgPop.searchFriendById")
	FriendDataManager.getInstance():QueryUserInfo( PHP_CMD_QUERY_USER_INFO_POP_BROADCAST, search_mid_table )

end



BroadcastMsgPop.searchFriendByIdCallBack = function(self, isSuccess, data)
	local result = nil;
	if isSuccess and data then
		local status = data.status
		--成功
		if status == 1 then
			result = {};
			local detailInforArray = data.data and data.data or {};

			if detailInforArray then
				for k, v in pairs(detailInforArray) do
					result.mid 			= v.mid
					result.charms 		= tonumber(v.charms);
					result.charms_level	= tonumber(v.charms_level);
					result.charms_title	= tonumber(v.charms_title);
					result.like_status 	= tonumber(v.like_status);
					result.likes 		= tonumber(v.likes);
					result.level 		= tonumber(v.level);
					result.alias 		= v.alias
					result.drawtimes 	= v.drawtimes
					result.losetimes 	= v.losetimes
					result.wintimes 	= v.wintimes
					result.money 		= v.money
					result.gift_status	= tonumber(v.gift_status)
					result.sex 			= tonumber(v.sex)
					result.small_image 	= v.small_image
					result.large_image 	= v.large_image
					result.mnick 		= v.mnick
					result.vip_level    = tonumber(v.vip_level) or 0
				end

				--弹出详细信息界面
				require("MahjongHall/Rank/RankUserInfo");
				local userInfoWindow = new(RankUserInfo, result, self, nil, result, 1);
			end
		end
	end
end



BroadcastMsgPop.requestUseBroadcastTrumpetCallBack = function ( self, isSuccess, data )

	if isSuccess and data then
		local status = data.status
		if status == 1 then
			GameConstant.changeNickTimes.propnum = tonumber(data.data.num)
			ItemManager.getInstance():removeCard(ItemManager.LABA_CID, 1);
            self:update_laba();
		else
			Banner.getInstance():showMsg(data.msg)
		end
	end
end

-- 血流血战比赛两房牌按各自进入路径设置
-- 包厢： 血战到底 -包厢-xx底
-- 两房牌：两房牌-xx底

BroadcastMsgPop.getRoomInfo = function ( self )
	local str = "";
	if GameConstant.curRoomLevel and GameConstant.curRoomLevel == GlobalDataManager.getInstance().fmRoomConfig.level then
		--好友对战
		local roundnum,fid,wanfa  = FriendMatchRoomScene_instance:getInviteRequestData()

		if bit.band(wanfa, 0x10) ~= 0 then
			str   = "两房牌"
		else
			if bit.band(wanfa, 0x02) ~= 0 then
				str = "血流成河"
			else
				str = "血战到底"
			end
		end

		str = "好友对战，房间号"..tostring(fid).."，"..str.."，" ..tostring(roundnum).."局"
		return str
	end

	local data, wanfa = HallConfigDataManager.getInstance():returnDataByLevel(GameConstant.curRoomLevel);

	if data and wanfa then
		if "xz" == wanfa then
			local curname  = HallConfigDataManager.getInstance():returnTypeNameForLevel(GameConstant.curRoomLevel)
			if curname then
				str = "【血战到底】" .. "-【" .. curname .. "】-【" .. data.di .. "底】";
			else
				str = "游戏场"
			end
		elseif "xl" == wanfa then
			local curname  = HallConfigDataManager.getInstance():returnTypeNameForLevel(GameConstant.curRoomLevel)
			if curname then
				str = "【血流成河】" .. "-【" .. curname .. "】-【" .. data.di .. "底】";
			else
				str = "游戏场"
			end
		elseif "match" == wanfa then
			str = "【比赛场】" .. "-【" .. data.name .. "】-【" .. data.value .. "底】";
		elseif "lfp" == wanfa then
			str = "【两房牌】" .. "-【" .. data.value .. "底】";
		else
			str = "游戏场";
		end
	end

	if 50 == GameConstant.curRoomLevel then
		local roomData = RoomData.getInstance().privateData;
		local str1 = ""
		if 1 == roomData.isXlch then
			str1 = "-【血流成河】-";
		else
			str1 = "-【血战到底】-";
		end

		str =  "【包厢】" .. str1 .."【" .. roomData.curDi .. "底】";
	end
	return str;
end


BroadcastMsgPop.event_item_change = function (self)
    DebugLog("[BroadcastMsgPop]event_item_change");
    self:update_laba();
end

BroadcastMsgPop.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

BroadcastMsgPop.phpMsgResponseCallBackFuncMap = {


	[PHP_CMD_REQUEST_USE_BROADCAST_TRUMPET]		  = BroadcastMsgPop.requestUseBroadcastTrumpetCallBack,
};




BroadcastMsgPop.dtor = function(self)
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(GlobalDataManager.item_change_event,self,self.myItemListUpdated);
    EventDispatcher.getInstance():unregister(GlobalDataManager.myItemListUpdated,self,self.event_item_change);
end
