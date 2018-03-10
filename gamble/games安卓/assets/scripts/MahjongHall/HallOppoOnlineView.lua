local oppo_online_award = require(ViewLuaPath.."oppo_online_award");

HallOppoOnlineView = class(SCWindow);

function HallOppoOnlineView:ctor(parent)
	DebugLog("HallOppoOnlineView ctor"); 
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.m_onlineCanAward = false; -- 是否可以领奖

	self.m_signVisible = false; -- 是否可以闪烁

	self:initView();
	self.m_onlineTime = tonumber(parent.m_calcuOnlineTime or 0); -- 剩余在线时长 seconds

	if parent and parent.m_mainView then
		parent.m_mainView:addChild( self );
	else
		self:addToRoot();
	end

	self.m_parent = parent;

	self.m_online_award_text:setText((self.m_parent.m_tomoney or 0) .. "金币");

	self:setBtnOperation();

	self:startCalculateOnline();


	-- SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQUEST_VIP_SHOW,nil);
end

function HallOppoOnlineView:onPhpMsgResponse (param, cmd, isSuccess )
	if self.httpSocketRequestsCallBackFuncMap[cmd] then 
		self.httpSocketRequestsCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

function HallOppoOnlineView:initView()
	self.layout = SceneLoader.load(oppo_online_award);

	self.window = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode(self.window);
	self:addChild( self.layout );

	self.m_online_award_text = publ_getItemFromTree(self.layout,{"bg","coin_bg","coin_text"});

	self.m_mTen_text = publ_getItemFromTree(self.layout, {"bg","time_view","m_ten_bg","Image1"});
	self.m_mGewei_text = publ_getItemFromTree(self.layout, {"bg","time_view","m_gewei_bg","Image1"});
	self.m_sTen_text = publ_getItemFromTree(self.layout, {"bg","time_view","s_ten_bg","Image1"});
	self.m_sGewei_text = publ_getItemFromTree(self.layout, {"bg","time_view","s_gewei_bg","Image1"});

	self.m_goToPlay_btn = publ_getItemFromTree(self.layout,{"bg","go_to_play"});
	self.m_goToPlay_text = publ_getItemFromTree(self.layout,{"bg","go_to_play","Text2"});

	self.m_point = publ_getItemFromTree(self.layout, {"bg","time_view","br_point2"});

	publ_getItemFromTree(self.layout,{"bg","closeBtn"}):setOnClick(self, function ( self )
		self:hideWnd();
	end);	

	self.m_goToPlay_btn:setOnClick(self, function ( self )
		self:onClickGoToBtn();
	end);
end

function HallOppoOnlineView:setBtnOperation()
	if self.m_onlineTime <= 1 then 
		self.m_goToPlay_text:setText("去领奖");
		self.m_onlineCanAward = true;
	else
		self.m_goToPlay_text:setText("去玩牌");
		self.m_onlineCanAward = false;
	end
end

function HallOppoOnlineView:onClickGoToBtn()

	-- 去玩牌
	if not self.m_onlineCanAward then 
		self:hideWnd();
		umengStatics_lua(kUmengOnlineViewGoToPlay)
		if self.m_parent and self.m_parent.delegate then 
			self.m_parent.delegate:requestQuickStartGame();
		end

	-- 去领奖
	else
		umengStatics_lua(kUmengOnlineViewGoToAward);
		SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQUEST_ONLINE_TIME_AWARD,{});

	end
end

function HallOppoOnlineView:startCalculateOnline()
	self.m_onlineAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1);
	self:updateOnlineTime();

	self.m_onlineAnim:setEvent(self,function(self)
		if self.m_onlineTime <= 1 then 
			delete(self.m_onlineAnim);
			self.m_onlineAnim = nil;
			self:setBtnOperation();
			self:updateOnlineTime();
			return;
		end
		self.m_onlineTime = self.m_onlineTime - 1;
		
		self:updateOnlineTime();
	end);
end

function HallOppoOnlineView:clearData()
	if self.m_onlineAnim then 
		delete(self.m_onlineAnim);
		self.m_onlineAnim = nil;
	end
end

function HallOppoOnlineView:updateOnlineTime()
	if self.m_onlineTime <= 0 then 
		self.m_onlineTime = 0;
	end

	-- 只显示 小时:分钟
	local hours = math.modf(self.m_onlineTime / 3600);
	local minutes = self.m_onlineTime - hours * 3600;
	minutes = math.modf(minutes / 60);

	local surplusSeconds = self.m_onlineTime - hours * 3600 - minutes * 60;

	-- > 1小时
	if hours >= 1 then 
		if hours < 10 then 
			self.m_mTen_text:setFile("bankraptcy/br_0.png");
			self.m_mGewei_text:setFile("bankraptcy/br_" .. hours .. ".png");
		else
			local ten_text = math.modf(hours / 10);
			local gewei_text = hours - 10*ten_text;
			self.m_mTen_text:setFile("bankraptcy/br_" ..ten_text .. ".png");
			self.m_mGewei_text:setFile("bankraptcy/br_" .. gewei_text .. ".png")
		end

		if minutes < 10 then 
			self.m_sTen_text:setFile("bankraptcy/br_0.png");
			self.m_sGewei_text:setFile("bankraptcy/br_" .. minutes .. ".png");
		else
			local ten_text = math.modf(minutes / 10);
			local gewei_text = minutes - 10*ten_text;
			self.m_sTen_text:setFile("bankraptcy/br_" ..ten_text .. ".png");
			self.m_sGewei_text:setFile("bankraptcy/br_" .. gewei_text .. ".png")
		end

	else
		-- 只显示 分钟:秒
		if minutes < 10 then 
			self.m_mTen_text:setFile("bankraptcy/br_0.png");
			self.m_mGewei_text:setFile("bankraptcy/br_" .. minutes .. ".png");
		else
			local ten_text = math.modf(minutes / 10);
			local gewei_text = minutes - 10*ten_text;
			self.m_mTen_text:setFile("bankraptcy/br_" ..ten_text .. ".png");
			self.m_mGewei_text:setFile("bankraptcy/br_" .. gewei_text .. ".png")
		end

		if surplusSeconds < 10 then 
			self.m_sTen_text:setFile("bankraptcy/br_0.png");
			self.m_sGewei_text:setFile("bankraptcy/br_" .. surplusSeconds .. ".png");
		else
			local ten_text = math.modf(surplusSeconds / 10);
			local gewei_text = surplusSeconds - 10*ten_text;
			self.m_sTen_text:setFile("bankraptcy/br_" ..ten_text .. ".png");
			self.m_sGewei_text:setFile("bankraptcy/br_" .. gewei_text .. ".png")
		end

		self:setMiddleSignView(not self.m_signVisible);
	end
end

function HallOppoOnlineView:setMiddleSignView(isVisible)
	self.m_point:setVisible(isVisible);
	self.m_signVisible = isVisible;
end

function HallOppoOnlineView:dtor()
	self:hide();
	self:clearData();
	self:removeAllChildren();

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);


end

function HallOppoOnlineView:onlineCanAwardCallback(isSuccess,data)
	if isSuccess then 
		local status = data.status or 0 ;
		if tonumber(status) == 1 then 
			local rewardMoney = data.data.money or 0;
			if tonumber(rewardMoney) ~= 0 then 
				local msg = data.msg or "";
				AnimationAwardTips.play(msg);
				showGoldDropAnimation();
				GlobalDataManager.getInstance():updateScene();

			end
			local reset = data.data.reset;
			if reset then 
				local tomoney = data.data.reset.tomoney or 0;
				self.m_parent.m_tomoney = tomoney;
				self.m_online_award_text:setText((self.m_parent.m_tomoney or 0) .. "金币");
			end

			self:execReCalcuAward(reset);
		elseif tonumber(status) == -2 then 
			local msg = data.msg or "";
			Banner.getInstance():showMsg(msg);
			local reset = data.data.reset;
			if reset then 
				local tomoney = data.data.reset.tomoney or 0;
				self.m_parent.m_tomoney = tomoney;
				self.m_online_award_text:setText((self.m_parent.m_tomoney or 0) .. "金币");
			end
			self:execReCalcuAward(reset);
		end
	end
end

function HallOppoOnlineView:execReCalcuAward(reset)
	if not reset then 
		return;
	end
	self.m_parent:execReCalcuAward(reset);

	local status = tonumber(reset.status or 0);
	if status == 1 then 
		local need = tonumber(reset.need or 0);
		self.m_onlineTime = need;
		self:startCalculateOnline();
		self:setBtnOperation();
	elseif status == 2 then 

	elseif status == 3 then 
		local need = tonumber(reset.need or 0);
		if need >= 0 then 
			self:hideWnd();
		end
	end
end

function HallOppoOnlineView:hideWnd()	
	self.m_parent.m_showOnlineBox = false;
	self.super.hideWnd( self );
end

function HallOppoOnlineView:onWindowHide()
	self.super.onWindowHide( self );
end

--回调函数映射表
HallOppoOnlineView.httpSocketRequestsCallBackFuncMap =
{
	[PHP_CMD_OPPO_REQUEST_ONLINE_TIME_AWARD] 		= HallOppoOnlineView.onlineCanAwardCallback,
};
