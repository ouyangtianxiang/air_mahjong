require("gameBase/gameLayer");
require("MahjongData/GlobalDataManager")
require("MahjongConstant/GlobalFunction")
require('MahjongData/MahjongCacheData')
local VipIcon_map = require("qnPlist/VipIcon")

--VipIcon_map
HallTopLayer = class(GameLayer)

--HallTopLayer.CONTENT_HEIGHT = 150
HallTopLayer.InHallMainView 			= 1  --主界面
HallTopLayer.InLevelChooseView 			= 2  --选场
HallTopLayer.InCompartmentView			= 3  --包厢

HallTopLayer.m_v_config = {
    btn_set = {
        a = {x = 40-30, y = 20},
        b = {x = 150, y = 20} 
    },
    btn_help = {
        a = {x = 126-30, y = 20},
        b = {x = 260, y = 20}
    },
    btn_msg = {
        a = {x = 212-30, y = 20},
        b = {x = 370, y = 20} 
    },
    btn_charge = {
        a = {x = 304-30, y = 3},
        b = {x = 370, y = 3} 
    },
    v_head = {
        a = {x = 20, y = 0},
        b = {x = 20, y = 0}    
    },
};

HallTopLayer.ctor = function(self, viewConfig , delegate)
	DebugLog("HallTopLayer ctor");
--	g_GameMonitor:addTblToUnderMemLeakMonitor("大厅top",self)
	self.delegate = delegate
	self:init()

	if PlatformConfig.platformOPPO == GameConstant.platformType then 
		self:initOppoThings();
	end

	self:onEnter()
end

function HallTopLayer:initOppoThings()
	if GameConstant.m_oppo_toMoney then 
		self.m_tomoney = GameConstant.m_oppo_toMoney;
	end

	self.m_vipExpView = self:getControl(HallTopLayer.s_controls.vipExpView);
	self.m_vipExpBtn = self:getControl( HallTopLayer.s_controls.vipExpBtn);
	self.m_vipExpExtraText = self:getControl(HallTopLayer.s_controls.vipExpExtraText);
	self.m_vipText = self:getControl(HallTopLayer.s_controls.vipExpText);

	self.m_onlineBoxView = self:getControl(HallTopLayer.s_controls.onlineView);
	self.m_onlineBoxBtn	= self:getControl(HallTopLayer.s_controls.onlineBtn);
	self.m_onlineBoxText = self:getControl(HallTopLayer.s_controls.onlineBtnText);

	self.m_vipText:setVisible(true);
	self.m_onlineBoxText:setVisible(true);

	self.m_vipExpBtn:setOnClick(self,self.onClickedVipExpBtn);
	self.m_onlineBoxBtn:setOnClick(self,self.onClickOnlineBoxBtn);

	self.m_onlineBoxBtnEnabled = true;

	if GameConstant.m_onlineTime and GameConstant.m_onlineTime >= -1 then 
		if GameConstant.m_onlineAnim then 
			delete(GameConstant.m_onlineAnim);
			GameConstant.m_onlineAnim = nil;
		end
		if GameConstant.m_onlineTime == -1 then 
			GameConstant.m_onlineTime = 0;
		end
		self:startCalcuOnlineTime(GameConstant.m_onlineTime );
	end

	if GameConstant.m_surplusTime and GameConstant.m_surplusTime > 0 then 
		if GameConstant.m_surplusAnim then 
			delete(GameConstant.m_surplusAnim);
			GameConstant.m_surplusAnim = nil;
		end
		self:resetOnlineAward(GameConstant.m_surplusTime);
	end

	if GameConstant.m_resetFlag then
		GameConstant.m_resetFlag = false;
		self:toRequestOppoOnlineTime(); 
	end
end


function HallTopLayer:deleteOppoThings()

	GameConstant.m_oppo_toMoney = self.m_tomoney or 0;

	if (self.m_calcuOnlineTime and self.m_calcuOnlineTime >= -1) or self.m_calcuOnlineTimeAnim then 
		GameConstant.m_onlineTime = self.m_calcuOnlineTime;
		if GameConstant.m_onlineAnim then 
			delte(GameConstant.m_onlineAnim);
			GameConstant.m_onlineAnim = nil;
		end
		GameConstant.m_onlineAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1);
		GameConstant.m_onlineAnim:setDebugName("GameConstant.m_onlineAnim")
		GameConstant.m_onlineAnim:setEvent(nil,function()
			if GameConstant.m_onlineTime then 
				if GameConstant.m_onlineTime <= 0 then 
					delete(GameConstant.m_onlineAnim);
					GameConstant.m_onlineAnim = nil;
					return;
				end
				GameConstant.m_onlineTime = GameConstant.m_onlineTime - 1;
			end
		end);
	end

	if self.m_surplusTimeAnim then 
		GameConstant.m_surplusTime = self.m_surplus_seconds;
		if GameConstant.m_surplusAnim then 
			delete(GameConstant.m_surplusAnim );
			GameConstant.m_surplusAnim = nil;
		end
		GameConstant.m_surplusAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1);
		GameConstant.m_surplusAnim:setDebugName("GameConstant.m_surplusAnim")
		GameConstant.m_surplusAnim:setEvent(nil,function()
			if GameConstant.m_surplusTime then 
				GameConstant.m_surplusTime = GameConstant.m_surplusTime - 1;
				if GameConstant.m_surplusTime <= 0 then 
					delete(GameConstant.m_surplusAnim);
					GameConstant.m_surplusAnim = nil;
					GameConstant.m_resetFlag = true;
				end
			end
		end);
	end

	self:clearData();
end

function HallTopLayer:clearData()
	self:clearOnlineData();
	self:clearExpData();
	self:clearOnlineSurplusData();
end

function HallTopLayer:clearExpData()
	self:setVipExpView(false);
end

function HallTopLayer:setVipExpView(isVisible)
	if isVisible and GameConstant.m_vipExpTime and GameConstant.m_vipExpTime <= 0 then 
		isVisible = not isVisible;
	end
	if self.m_vipExpView then 
		self.m_vipExpView:setVisible(isVisible);
		self.m_vipExpExtraText:setVisible(isVisible);
	end
end

function HallTopLayer:setOnlineView(isVisible)
	if self.m_onlineBoxView then 
		self.m_onlineBoxView:setVisible(isVisible);
	end
end

--更新oppovip界面
function HallTopLayer:updateTimeLbl( leftTime )
	if leftTime <= 0 then 
		self:setVipExpView(false)
	else
		self:setVipExpView(true)
		self:updateVipExpTime(leftTime)
	end
end

function HallTopLayer:updateVipExpTime(updateTime)
	if not updateTime then 
		return;
	end
	local secondTimes = tonumber(updateTime);
	local days = math.modf(secondTimes / 86400);

	local hours = secondTimes - 86400 * days;
	DebugLog(hours);
	hours = math.modf(hours / 3600 );
	
	local minutes;
	local msg ;
	if days <= 0 then 
		minutes = secondTimes - 86400 * days - 3600 * hours;
		minutes = math.modf(minutes/60);
		if minutes <= 1 then 
			minutes = 1;
		end
		msg = "0小时" .. minutes .. "分";
	else
	  	msg = days .. "天" .. hours .. "小时";
	end
	self.m_vipText:setText(msg);
end

function HallTopLayer:updateOnlineTime(onlineTime)
	if not onlineTime then 
		return ; 
	end

	local secondTimes = tonumber(onlineTime);
	local hours = math.modf(secondTimes / 3600);
	local minutes = secondTimes - hours * 3600;
	minutes = math.modf(minutes / 60);

	local surplusSeconds = secondTimes - hours * 3600 - minutes * 60;
	local msg;
	
	if hours < 10 then 
		msg = "0" .. hours;
	else
		msg = hours;
	end

	msg = msg .. ":";

	if minutes < 10 then 
		msg = msg .. "0" .. minutes;
	else
		msg = msg .. minutes;
	end

	msg = msg .. ":";

	if surplusSeconds < 10 then 
		msg = msg .. "0" ..surplusSeconds;
	else
		msg = msg .. surplusSeconds;
	end

	self.m_onlineBoxText:setText(msg);
	self.m_onlineBoxView:setVisible(true)
	self.m_onlineBoxText:setVisible(true);
	self.m_calcuOnlineTime = self.m_calcuOnlineTime - 1;
	self.m_onlineBoxBtnEnabled = false;

end

function HallTopLayer:onlineCanAwardCallback(isSuccess,data)
	if self.m_showOnlineBox then 
		return;
	end
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

			self.m_tomoney = data.data.reset.tomoney or 0;
			self:execReCalcuAward(reset);
		elseif tonumber(status) == -2 then 
			local msg = data.msg or "";
			Banner.getInstance():showMsg(msg);
			local reset = data.data.reset;
			self.m_tomoney = data.data.reset.tomoney or 0;
			self:execReCalcuAward(reset);
		end
	end
end

function HallTopLayer:execReCalcuAward(reset)
	if not reset then 
		return;
	end
	local status = tonumber(reset.status or 0);
	if status == 1 then 
		local need = tonumber(reset.need or 0);
		self:startCalcuOnlineTime(need);
	elseif status == 2 then 
		self:setOnlineView(true);

	elseif status == 3 then 
		local need = tonumber(reset.need or 0);
		if need >= 0 then 
			self:setOnlineView(false);
			self.m_calcuOnlineTime = - 5;
			self:resetOnlineAward(need);
		end
	end
end

function HallTopLayer:resetOnlineAward(seconds)
	if self.m_surplusTimeAnim then 
		delete(self.m_surplusTimeAnim);
		self.m_surplusTimeAnim = nil;
	end

	self.m_surplus_seconds = seconds;
	self.m_surplusTimeAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1);
	self.m_surplusTimeAnim:setDebugName("HallTopLayer m_surplusTimeAnim")
	self.m_surplusTimeAnim:setEvent(nil,function()
		if self.m_surplus_seconds <= 0 then 
			delete(self.m_surplusTimeAnim)
			self.m_surplusTimeAnim = nil;
			self:toRequestOppoOnlineTime();
			return;
		end
		self.m_surplus_seconds = self.m_surplus_seconds - 1;
	end);
end

function HallTopLayer:toRequestOppoOnlineTime()
	--发php请求
	 SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQUEST_ONLINE_TIME, nil);
end

function HallTopLayer:onlineAwardCallBack(isSuccess,data)
	if self.m_showOnlineBox then 
		return;
	end
	if isSuccess then 
		local status = data.status or 0;
		if tonumber(status) == 1 then 
			local need = tonumber(data.data.need or 0);
			if tonumber(need) >= 0 then 
				self:startCalcuOnlineTime(need);
			end

			self.m_tomoney = tonumber(data.data.tomoney or 0);

		elseif tonumber(status) == 2 then 
			self:startCalcuOnlineTime(0);

		elseif tonumber(status) == 3 then 
			local need = tonumber(data.data.need or 0)
			if need >= 0 then 
				self:setOnlineView(false);
				self.m_calcuOnlineTime = -5;
				self:resetOnlineAward(need);
			end
		end

	end
end

function HallTopLayer:startCalcuOnlineTime(onlineTime)
	self.m_calcuOnlineTime = tonumber(onlineTime or 0);
	if self.m_calcuOnlineTimeAnim then 
		delete(self.m_calcuOnlineTimeAnim)
		self.m_calcuOnlineTimeAnim = nil;
	end
	if self.m_calcuOnlineTime > 0 then
		self.m_onlineBoxBtn:setFile("Login/oppo/HallTopLayer/online_reward_close.png");
		self.m_onlineBoxBtnEnabled = false;
	end

	self.m_calcuOnlineTimeAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1);
	self.m_calcuOnlineTimeAnim:setDebugName("HallTopLayer m_calcuOnlineTimeAnim")
	self.m_calcuOnlineTimeAnim:setEvent(self,function(self)
		if self.m_calcuOnlineTime < 0 then 
		-- 	-- self:clearOnlineData();
			delete(self.m_calcuOnlineTimeAnim)
			self.m_calcuOnlineTimeAnim = nil;
			self.m_onlineBoxBtnEnabled = true;
			self.m_onlineBoxBtn:setFile("Login/oppo/HallTopLayer/online_reward.png");
			return;
		end
		self.m_onlineBoxBtnEnabled = false;
		self:updateOnlineTime(self.m_calcuOnlineTime)

		self:setOnlineView(true);
	end)

end

function HallTopLayer:clearOnlineData()
	if self.m_calcuOnlineTimeAnim then 
		delete(self.m_calcuOnlineTimeAnim);
		self.m_calcuOnlineTimeAnim = nil;
	end
	self:setOnlineView(false);
end

function HallTopLayer:clearOnlineSurplusData()
	if self.m_surplusTimeAnim then 
		delete(self.m_surplusTimeAnim);
		self.m_surplusTimeAnim = nil;
	end
	self.m_surplus_seconds = 0;
end

function HallTopLayer:onClickedVipExpBtn()
	if tonumber(GameConstant.checkType) ~= kCheckStatusClose then 
		return;
	end

	umengStatics_lua(kUmengExpVipBtn);
	require("MahjongHall/HallOppoRewardView");
	if self.m_oppo_vipExpWindow then
		delete(self.m_oppo_vipExpWindow);
		self.m_oppo_vipExpWindow = nil;
	end
	self.m_oppo_vipExpWindow = new(HallOppoRewardView, self.m_mainView);
	self.m_oppo_vipExpWindow:showWnd();
end

function HallTopLayer:onClickOnlineBoxBtn()
	if self.m_onlineBoxBtnEnabled then 
		umengStatics_lua(kUmengOnlineBtn);
		SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQUEST_ONLINE_TIME_AWARD,{});
	else
		umengStatics_lua(kUmengOnlineBtn);
		require("MahjongHall/HallOppoOnlineView");
		if self.m_oppo_onlineBoxView then
			delete(self.m_oppo_onlineBoxView);
			self.m_oppo_onlineBoxView = nil;
		end

		self.m_showOnlineBox = true;
		self.m_oppo_onlineBoxView = new(HallOppoOnlineView, self);
		self.m_oppo_onlineBoxView:showWnd();
	end

end

HallTopLayer.dtor = function(self)
	DebugLog("HallTopLayer dtor");

	self:onExit()

	if PlatformConfig.platformOPPO == GameConstant.platformType then 
		self:deleteOppoThings();
	end
end

--HallTopLayer.getSize = function ( self )
--	return self.m_root:getSize()
--end

HallTopLayer.init = function (self)
	-- body
	self.m_moneyText   		= self:getControl( HallTopLayer.s_controls.moneyText )
    
	self.m_nameText			= self:getControl( HallTopLayer.s_controls.nameText )
	self.m_photoImage		= self:getControl( HallTopLayer.s_controls.photoImage )

	--self.m_vipBtn           = self:getControl( HallTopLayer.s_controls.vipBtn )
	self.m_setBtn           = self:getControl( HallTopLayer.s_controls.setBtn )
	self.m_helpBtn			= self:getControl( HallTopLayer.s_controls.helpBtn )
	self.m_messageBtn		= self:getControl( HallTopLayer.s_controls.messageBtn )
	self.m_firstChargeBtn   = self:getControl( HallTopLayer.s_controls.firstChargeBtn )
	self.m_playerHeadView   = self:getControl( HallTopLayer.s_controls.playerHeadView )
	self.m_headBtn			= self:getControl( HallTopLayer.s_controls.playerInfoBtn )

    self.m_t_diamond   		= self:getControl( HallTopLayer.s_controls.t_diamond ); 

	self.m_headBtn:setType(Button.White_Type)
	self.m_photoImageMask   = nil

	self:updateUserInfo()

end

HallTopLayer.onEnter = function(self)
	DebugLog("HallTopLayer onEnter");
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():register(GlobalDataManager.updateLocalCoinEvent, self, self.updateCoin);
	FriendDataManager.getInstance():addListener(self,self.onCallBackFunc);	
end

HallTopLayer.onExit = function (self)
	DebugLog("HallTopLayer onExit");
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateLocalCoinEvent, self, self.updateCoin);
end


HallTopLayer.initRequests = function ( self )
	-- body
	self:needToRefreshMoney(); --是否需要重新更新金币信息


end

HallTopLayer.onCallBackFunc = function(self,actionType, actionParam)

	if kFriendNewsNumRequestByPHP == actionType then --动态数量
        local btn_tip = publ_getItemFromTree(self.m_messageBtn , {"tip"});
        if btn_tip then
            Clock.instance():schedule_once(function ( dt )
                self:updateTipNum(btn_tip, FriendDataManager.getInstance():getTipsCount()+GlobalDataManager.getInstance():getUnReadSystemMessageNum())
            end, 0.5);    
        end
		
	end

end 
HallTopLayer.displayUpdateTip = function ( self )
	DebugLog("HallTopLayer.displayUpdateTip")
    local bCanGetUpdateRewardOrHasUpdate = false;
    local num = 0
	--是否显示 更新 提示角标 
	if PlatformFactory.curPlatform:needToShowUpdataView() then
		if GlobalDataManager.getInstance():canGetUpdateRewardOrHasUpdate() then
            bCanGetUpdateRewardOrHasUpdate = true; 
			num = 1 
		end 
		DebugLog("num = " .. tostring(num))
		self:updateTipNum( publ_getItemFromTree(self.m_setBtn, {"tip"}), num)
	end
    --未绑定手机号码，设置按钮上需要 添加提示角标
    if not GlobalDataManager.getInstance():getIsCellAcccountBind() then
        num = num + 1;
        self:updateTipNum( publ_getItemFromTree(self.m_setBtn, {"tip"}), num)
    end
end


HallTopLayer.nativeCallEvent = function(self, param, _detailData)
	if kDownloadImageOne == param then
		local player = PlayerManager.getInstance():myself();
		if player.mid > 0 and _detailData == player.localIconDir then
			self:downloadImgSuccess( _detailData );
		end
	elseif param == kFetionUploadHeadicon then
		local player = PlayerManager.getInstance():myself();
		if player.mid > 0 then
			player.localIconDir = player.mid .. ".png";
			self:downloadImgSuccess( _detailData );
		end
	end
end
HallTopLayer.downloadImgSuccess = function(self, name)
	if PlayerManager.getInstance():myself().localIconDir == name and name ~= nil then
		self:setHeadPhoto(name)
		--self.m_photoImage:setFile(name);
	end
end

-- 是否需要刷新金币
function HallTopLayer.needToRefreshMoney( self )
	if GameConstant.needCheckMoney and PlayerManager.getInstance():myself().mid > 0 then
		GameConstant.needCheckMoney = false;
		GlobalDataManager.getInstance():updateScene();
	end
end

-----------------------------------------------------------------------------------------------------------------------------------
--animation
HallTopLayer.playEnterAnim1 = function ( self )
end
HallTopLayer.playEnterAnim2 = function ( self )
end
--大厅
HallTopLayer.preEnterAnim = function ( self )

    self.m_messageBtn:setVisible(true);
    self.m_playerHeadView:setVisible(true);
	self.m_setBtn:setPos(self.m_v_config.btn_set.a.x,self.m_v_config.btn_set.a.y)
	self.m_helpBtn:setPos(self.m_v_config.btn_help.a.x,self.m_v_config.btn_help.a.y)
	self.m_messageBtn:setPos(self.m_v_config.btn_msg.a.x,self.m_v_config.btn_msg.a.y)
	self.m_firstChargeBtn:setPos(self.m_v_config.btn_charge.a.x,self.m_v_config.btn_charge.a.y)

	self.m_playerHeadView:setPos(self.m_v_config.v_head.a.x,self.m_v_config.v_head.a.y)

	if PlatformConfig.platformOPPO == GameConstant.platformType then 
		self.m_vipExpView:setPos(66, 100)
		self.m_onlineBoxView:setPos(430,90);
	end

	self.m_inViewType = HallTopLayer.InHallMainView

	FriendDataManager.getInstance():requestFriendNewsNum()

end
---选场
HallTopLayer.preEnterAnim2 = function ( self,downoff )
	downoff = downoff or 150

	self.m_setBtn:setPos(self.m_v_config.btn_help.a.x,self.m_v_config.btn_help.a.y)
	self.m_helpBtn:setPos(self.m_v_config.btn_msg.a.x,self.m_v_config.btn_msg.a.y)
	self.m_messageBtn:setPos(self.m_v_config.btn_msg.a.x,self.m_v_config.btn_msg.a.y)
	self.m_firstChargeBtn:setPos(self.m_v_config.btn_charge.a.x,self.m_v_config.btn_charge.a.y)

    self.m_messageBtn:setVisible(false);
    self.m_helpBtn:setVisible(true)
    if PlatformConfig.platformOPPO == GameConstant.platformType then 
		self.m_vipExpView:setPos(66, -100)
		self.m_onlineBoxView:setPos(430,90-200);
	end

	self.m_inViewType = HallTopLayer.InLevelChooseView
	FriendDataManager.getInstance():requestFriendNewsNum()
end

HallTopLayer.viewInHallMain = function ( self )
--    self.m_messageBtn:setVisible(true);
--	self.m_setBtn:setPos(self.m_v_config.btn_set.a.x,self.m_v_config.btn_set.a.y)
--	self.m_helpBtn:setPos(self.m_v_config.btn_help.a.x,self.m_v_config.btn_help.a.y)
--	self.m_messageBtn:setPos(self.m_v_config.btn_msg.a.x,self.m_v_config.btn_msg.a.y)
--	self.m_firstChargeBtn:setPos(self.m_v_config.btn_charge.a.x,self.m_v_config.btn_charge.a.y)
--	self.m_playerHeadView:setPos(self.m_v_config.v_head.a.x,self.m_v_config.v_head.a.y)

--	if PlatformConfig.platformOPPO == GameConstant.platformType then 
--		self.m_vipExpView:setPos(66, 100)
--		self.m_onlineBoxView:setPos(430,90);
--	end

	self.m_inViewType = HallTopLayer.InHallMainView

end

--HallTopLayer.viewInLevelChoose = function ( self )
--    self.m_messageBtn:setVisible(true);
--    self.m_firstChargeBtn:setVisible(true);
--    self.m_playerHeadView:setVisible(false);
--    self.m_messageBtn:setVisible(false);
--	self.m_setBtn:setPos(self.m_v_config.btn_set.b.x,self.m_v_config.btn_set.b.y)
--	self.m_helpBtn:setPos(self.m_v_config.btn_help.b.x,self.m_v_config.btn_help.b.y)
--	self.m_messageBtn:setPos(self.m_v_config.btn_msg.b.x,self.m_v_config.btn_msg.b.y)
--	self.m_firstChargeBtn:setPos(self.m_v_config.btn_charge.b.x,self.m_v_config.btn_charge.b.y)
--	self.m_playerHeadView:setPos(self.m_v_config.v_head.a.x,self.m_v_config.v_head.a.y)

--	self.m_inViewType = HallTopLayer.InLevelChooseView

--end
--包厢
HallTopLayer.preEnterAnim3 = function ( self )
	self.m_firstChargeBtn:setPos(880,10-150)
	self.m_playerHeadView:setPos(20,-150)
	
	self.m_inViewType = HallTopLayer.InCompartmentView
end

-----------------------------------------------------------------------------------------------------------------------------------
--params = Player
HallTopLayer.updateUserInfo = function ( self,params)

	local params = PlayerManager.getInstance():myself()

	if (tonumber(params.mid) or 0) <= 0 then
		params.mid = 0;
		--SocketManager.getInstance():syncClose();
		GameConstant.HallViewType = nil;
		params:resetPlayerData();
		
		--self:changeCurShowView(HallScene.MAIN_VIEW_TYPE);
		
		self.m_photoImage:setFile("Commonx/blank.png");
		self.m_nameText:setText("未登录");
		self:setPlayerMoney("")
        self:set_player_diamond("");
		self:setHeadPhoto(nil)
		showOrHide_sprite_lua(0);
		return;
	end 

	if params.nickName and self.m_nameText then 
		self.m_nameText:setText( stringFormatWithString( params.nickName,10,true) )
	end 

	if params.money and self.m_moneyText then 
		self:setPlayerMoney(params.money)
        self:set_player_diamond(params.boyaacoin);
	end 
	
	self:setVipDisplay(params.vipLevel)

	local isExist = false;
	local localDir = nil;

	DebugLog("HallTopLayer.uploadUserInfo")
	DebugLog(params.large_image)
	if GameConstant.uploadHeadIconName and GameConstant.uploadHeadIconName ~= "" then
		DebugLog("GameConstant.uploadHeadIconName")
		DebugLog(GameConstant.uploadHeadIconName)
		isExist = true;
		localDir = GameConstant.uploadHeadIconName;
	else
		isExist , localDir = NativeManager.getInstance():downloadImage(params.large_image);
	end
	if not isExist then
		if tonumber(params.sex) == kSexMan then
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
	self:setHeadPhoto(localDir)
	--self.m_photoImage:setFile(localDir);
end

HallTopLayer.setVipDisplay = function ( self, vipLevel )
	local vipLevel = vipLevel or 0
	--if vipLevel < 1 then 
	--	vipLevel = 1
	if vipLevel > 10 then 
		vipLevel = 10
	end 
	if vipLevel > 0 and self.m_headBtn then 
		local key = "VIP"..vipLevel..".png"
		self.m_headBtn:setFile(VipIcon_map[key])
    else
        self.m_headBtn:setFile("Commonx/headBg.png");
	end 

end

HallTopLayer.setHeadPhoto = function ( self, filepath )
	if self.m_photoImageMask then 
		self.m_photoImageMask:removeFromSuper()
		self.m_photoImageMask = nil 
	end 
	if not filepath then 
		return 
	end 
	local maskPath = "Commonx/headMask.png" 
	local player = PlayerManager.getInstance():myself();
	if player.vipLevel >= 1 then 
		maskPath = "Hall/headMask.png"
	end 

	require("coreex/mask")
	self.m_photoImageMask = new(Mask,filepath,maskPath)
	self.m_photoImage:addChild(self.m_photoImageMask)
	self.m_photoImageMask:setAlign(kAlignCenter)
end

HallTopLayer.updataUIByGlobalEvent = function(self, param)
	if not param or GlobalDataManager.UI_UPDATA_MONEY == param.type then
		-- 更新金币（not param 时也更新，为了兼容老代码）
		self:updateCoin();
	elseif GlobalDataManager.UI_UPDATA_FEEBACK_TIP == param.type then
        -- 更新反馈
        self:updateTipNum( publ_getItemFromTree(self.m_helpBtn, {"tip"}) ,
                           FeeBackData.getInstance():getFeeBackTipNum() )
    end
end


HallTopLayer.updateTipNum = function ( self ,tip_node, num )
	DebugLog("HallTopLayer.updateTipNum num:" .. tostring(num))
	if not tip_node then 
		DebugLog("not tip_node")
		return 
	end 

	local tipText = publ_getItemFromTree(tip_node,{"Text1"})
	if not tipText then 
		DebugLog("not tipText")
		return 
	end 
	local inum = tonumber(num)
	tip_node:setVisible( inum > 0 and true or false)
	if inum > 99 then 
		inum = 99
	end 
	tipText:setText(tostring(inum))
end

HallTopLayer.updateCoin = function(self)
	umengStatics_lua(kUmengHallCoinUpdateBtn);
	local player = PlayerManager.getInstance():myself();
	if player.mid > 0 then
		self:setPlayerMoney(player.money)
        self:set_player_diamond(player.boyaacoin);
		--local money = trunNumberIntoThreeOneFormWithInt(player.money, true) or 0;
		--self.m_moneyText:setText(money);
	else
		DebugLog("刷新金币失败，玩家未登录。。。。。。。");
	end
end

HallTopLayer.setPlayerMoney = function ( self, vaule )
	self.m_moneyText:setText("")
	setMoneyNode( vaule,self.m_moneyText )
end

--设置钻石
HallTopLayer.set_player_diamond = function ( self, vaule )

	self.m_t_diamond:setText("")
	setMoneyNode( vaule,self.m_t_diamond )
end
-----------------------------------------------------------------------------------------------------------------------------------
HallTopLayer.checkForResDownload = function ( self )
	-- 资源未下载，且是wifi环境则自动下载资源
	if GameConstant.platformType == GameConstant.platformTrunkPre then 
		if "wifi" == GameConstant.net then
			if 1 ~= GameConstant.faceIsCanUse or 1 ~= GameConstant.soundDownload then
				GlobalDataManager.getInstance():getDownloadResInfo( false );
			end
		else
			if 1 ~= GameConstant.faceIsCanUse or 1 ~= GameConstant.soundDownload then
				local view = PopuFrame.showNormalDialog( "下载", "    是否下载表情/声音资源？", GameConstant.curGameSceneRef, nil, nil, false );
				view:setConfirmCallback(self, function ( self )
					view:hide();
					GlobalDataManager.isActivityDownload = true;
					GlobalDataManager.getInstance():getDownloadResInfo( false );
				end);
				view:setCallback(view, function ( view, isShow )
					if not isShow then
						
					end
				end);
				view:setHideCloseBtn(false);
			end
		end
	else
		if (1 ~= GameConstant.soundDownload or 1 ~= GameConstant.faceIsCanUse) and "wifi" == GameConstant.net then
			-- GlobalDataManager.isActivityDownload = true;
			GlobalDataManager.getInstance():getDownloadResInfo( false );
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
--net request
HallTopLayer.requestData = function ( self )
	-- body
	self:requestFeeBackTipNum()
end
--反馈 提示角标
HallTopLayer.requestFeeBackTipNum = function(self)
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_FEE_BACK_TIP_NUM, param);
end


HallTopLayer.requestFeeBackTipNumCallback = function(self,isSuccess,data)

	if not isSuccess or not data or not data.data then
		return ;
	end

	if data.status == 1 then 
		if data.data.num and data.data.num then
			FeeBackData.getInstance():setFeeBackTipNum(tonumber(data.data.num or 0));
        	self:updateTipNum( publ_getItemFromTree(self.m_helpBtn, {"tip"}) ,
                           	   FeeBackData.getInstance():getFeeBackTipNum() )
		end
	end
end

--反馈清0
HallTopLayer.requestFlushFeeBackTipNum = function(self)
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.api = GameConstant.api
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_FLUSH_FEE_BACK_TIP_NUM, param);
end


HallTopLayer.requestFlushFeeBackTipNumCallback = function(self,isSuccess,data)

	if not isSuccess or not data or not data.data then
		return ;
	end

	if data.status == 1 then
		FeeBackData.getInstance():setFeeBackTipNum(0);
		self:updateTipNum( publ_getItemFromTree(self.m_helpBtn, {"tip"}) ,
                           FeeBackData.getInstance():getFeeBackTipNum() )
	end
end

--net event
HallTopLayer.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end 
-----------------------------------------------------------------------------------------------------------------------------------

HallTopLayer.onClickedSetBtn = function ( self )


	umengStatics_lua(Umeng_HallSettingBtn);
	require("MahjongHall/Setting/SettingWindow");
	if not self.settingWindow then
		self.settingWindow = new(SettingWindow, self);

		self.settingWindow:setOnWindowHideListener(self, function( self )
				self.delegate.m_mainView:removeChild(self.settingWindow); --beshow
				self.settingWindow = nil;
			end);
		
		self.delegate.m_mainView:addChild(self.settingWindow);
	end

	if 0 == GameConstant.needShowTip then
		GameConstant.needShowTip = 1;
		g_DiskDataMgr:setAppData('acountTip',GameConstant.needShowTip)
	end
	
	
	self.settingWindow:show();

end



-- 显示帮助窗口
HallTopLayer.showHelpWindow = function( self )

		if self.m_inViewType == HallTopLayer.InLevelChooseView then 
			self.delegate.m_levelChooseLayer:playExitAnim(self,function ( self )
				self.helpWindow = new(HelpWindow , self.delegate);
				self.helpWindow:set_callback_exit( self , function( self, bs )
					self.helpWindow = nil;
				end)
			end)
		elseif self.m_inViewType == HallTopLayer.InHallMainView then  
			self.delegate:playExitHallWithMoveBgAnim(1,self,function(self )
				self.helpWindow = new(HelpWindow , self.delegate);
				self.helpWindow:set_callback_exit( self , function( self, bs )
					self.helpWindow = nil;
				end)
			end)
		end 

end



HallTopLayer.onClickedHelpBtn = function ( self )
	DebugLog('Profile clicked help start:'..os.clock(),LTMap.Profile)
	-- if not self.delegate:canEnterView() then 
	-- 	return
	-- end 
	
	if self.delegate and self.delegate.myBroadcast then 
		self.delegate.myBroadcast:setVisible(false)
	end

	require("MahjongHall/Help/HelpWindow");
	umengStatics_lua(Umeng_HallHelpBtn);
	self:showHelpWindow();
	self:requestFlushFeeBackTipNum();
end

HallTopLayer.onClickedMessageBtn = function ( self )
	DebugLog('Profile clicked mail start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end

	if self.delegate and self.delegate.myBroadcast then 
		self.delegate.myBroadcast:setVisible(false)
	end

	require("MahjongHall/Friend/MailWindow");

		if self.m_inViewType == HallTopLayer.InLevelChooseView then 
			self.delegate.m_levelChooseLayer:playExitAnim(self,function ( self )
				self.mailWindow = new(MailWindow , self.delegate);
				self.mailWindow:set_callback_exit(self, function(self, bs)
					self.mailWindow = nil;
				end );
			end)
		elseif self.m_inViewType == HallTopLayer.InHallMainView then  
			self.delegate:playExitHallWithMoveBgAnim(1,self,function(self )
				self.mailWindow = new(MailWindow , self.delegate);
				self.mailWindow:set_callback_exit(self, function(self, bs)
					self.mailWindow = nil;
				end );
			end)
		end 

end

HallTopLayer.onClickedFirstChargeBtn = function ( self )
	if not self.delegate:canEnterView() then
		return;
	end
	umengStatics_lua(Umeng_HallRechargeBtn);

    local param_t = {t = RechargeTip.enum.default, 
                isShow = false,
                probability_giftpack = 1,
                is_check_bankruptcy = false, 
                is_check_giftpack = true,};
    if GameConstant.platformType == PlatformConfig.platformChubao then 
   		param_t.isShow = true 
   	end
    RechargeTip.create(param_t)
end

HallTopLayer.showFirstChargeView = function(self)
	require("MahjongCommon/FirstChargeView");
	if 1 == FirstChargeView.getInstance().isOpenFirstChargeView then
		FirstChargeView.getInstance():show();
	end
	return 1 == FirstChargeView.getInstance().isOpenFirstChargeView;
		
end


HallTopLayer.showQuickChargeView = function( self, params )

end


HallTopLayer.onClickedPlayerInfoBtn = function ( self )
	DebugLog('Profile clicked userinfo start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then 
		return
	end 

	local exitHandle = nil 
	local exitFunc   = nil 
	if self.m_inViewType == HallTopLayer.InLevelChooseView then 
		exitHandle = self.delegate.m_levelChooseLayer
		exitFunc   = self.delegate.m_levelChooseLayer.playExitAnim
	elseif self.m_inViewType == HallTopLayer.InHallMainView then 
		exitHandle = self.delegate
		exitFunc   = self.delegate.playExitHallAnim
	end 

	exitFunc(exitHandle,self,function ( self )
		umengStatics_lua(Umeng_HallHeadIconBtn);
		require("MahjongHall/UserInfo/UserInfoWindow");
		--请求自己的VIP信息
		GlobalDataManager.getInstance():getMyVipInfo();
		self.userInfoWindow = new(UserInfoWindow , self.delegate);
		self.userInfoWindow:set_callback_exit(self, function(self, beShow)
			if not beShow then
				self:updateUserInfo(PlayerManager.getInstance():myself());
				self.userInfoWindow = nil;
			end
		end);
	end)


	 	
end

HallTopLayer.onClickedVipBtn = function ( self )
	if not self.delegate:canEnterView() then 
		return
	end 
	local exitHandle = nil 
	if self.m_inViewType == HallTopLayer.InCompartmentView then 
		exitHandle = self.delegate.privateBox
	else 
		exitHandle = self.delegate
	end	

		exitHandle:playExitAnim(self,function(self )
			umengStatics_lua(Umeng_HallHeadIconBtn);
			require("MahjongHall/UserInfo/UserInfoWindow");
			--请求自己的VIP信息
			GlobalDataManager.getInstance():getMyVipInfo();
			self.userInfoWindow = new(UserInfoWindow , self.delegate, State_VIPInfo);
			
			self.userInfoWindow:set_callback_exit(self, function(self, beShow)
				if not beShow then
					self:updateUserInfo(PlayerManager.getInstance():myself());
					self.userInfoWindow = nil;
				end
			end);
		end)	
end

-------------------------------------------------------------------------------------------------------------------------------------
--setting window delegate
-- 切换正式测试自定义
HallTopLayer.clickChangeSocketType = function(self, socketType)
	clearBufferDict();
	local myself = PlayerManager.getInstance():myself();
	if myself.mid > 0 then
		local loginType = PlatformFactory.curPlatform:changeLoginMethod(GameConstant.lastLoginType);
		loginType:logout();
		self:updateUserInfo(PlayerManager.getInstance():myself());
	end

	DebugLog("socketType : " .. socketType);
	SocketManager.getInstance():changeSocketType(socketType)
	if kCustomPersonalServer == socketType then
		-- 自定义
		local selcetDomain = new(SelectDomainView, self);
		self.delegate.m_mainView:addChild(selcetDomain);
	end

end

-- 切换帐号
HallTopLayer.clickChangeLoginMethod = function(self)
	DebugLog("HallTopLayer.clickChangeLoginMethod")


	if self.settingWindow then
		self.settingWindow:hide();
		if self.settingWindow then
			delete(self.settingWindow);
			self.settingWindow = nil;
		end
	end

	self.delegate:addLoginView()
	
	local player = PlayerManager.getInstance():myself();
	if player then
		player:resetPlayerData();
	end	

	if self.delegate.m_socialLayer then 
		self.delegate.m_socialLayer:clearViews()
	end		
end
-- 清除缓存
HallTopLayer.clickClearBuffer = function(self)
	clearBufferDict();
	-- dict_delete("map2");
	-- dict_delete(kMap);
	-- dict_save(kMap);
 -- 	dict_save("map2");
 -- 	dict_delete("VipData")
 -- 	dict_save("VipData")
 	NetCacheDataManager.getInstance():stopRefreshTimestamp();
 	NetCacheDataManager.getInstance():clearCache();
	self.settingWindow:hide();
	delete(self.settingWindow);
	self.settingWindow = nil;
	-- 登出
	PlatformFactory.curPlatform:logout();
	-- 界面返回到主选择界面
--!!	self:changeCurShowView(HallScene.MAIN_VIEW_TYPE);!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- 断开socket链接
	SocketManager.getInstance():syncClose();
	self:updateUserInfo(PlayerManager.getInstance():myself());
	-- 清除本地数据
	if tonumber(GameConstant.isSdCard) == 0 then
		return;
	end

	local data = {}
	data.debug = DEBUGMODE
	native_to_get_value(kCleanData, json.encode(data))

	if not isPlatform_Win32() then
		local size = dict_get_string(kCleanData, kCleanData .. kResultPostfix) or "0";
		local sizeNum = tonumber(size);
		if sizeNum > 1024 then
			local sizeInt = math.floor(sizeNum / 1024);
			local sizeDec = math.floor((sizeNum - sizeInt * 1024) / 100);
			Banner.getInstance():showMsg("共清除缓存大小：" .. sizeInt .. "." .. sizeDec .. "MB");
		else
			Banner.getInstance():showMsg("共清除缓存大小：" .. sizeNum .. "KB");
		end
	end

	if self.m_socialLayer then 
		self.m_socialLayer:clearViews()
	end		
end

-- 点击新手教程
HallTopLayer.clickTeachHelp = function(self)
	StateMachine.getInstance():changeState(States.Loading,nil,States.TeachRoom);
end


-- 点击反馈帮助页面
HallTopLayer.clickFeedBackAndHelp = function(self)
	require("MahjongHall/Help/HelpWindow");
	DebugLog( "show help window" );
	self:onClickedHelpBtn()
end
-- 用户条款
HallTopLayer.clickUsersTerms = function(self)
	if self.settingWindow then
		delete(self.settingWindow);
		self.settingWindow = nil;
	end
	showOrHide_sprite_lua(0);


	local exitHandle = nil 
	local exitFunc   = nil 
	if self.m_inViewType == HallTopLayer.InLevelChooseView then 
		exitHandle = self.delegate.m_levelChooseLayer
		exitFunc   = self.delegate.m_levelChooseLayer.playExitAnim
	elseif self.m_inViewType == HallTopLayer.InHallMainView then 
		exitHandle = self.delegate
		exitFunc   = self.delegate.playExitHallAnim
	end 

	if exitHandle and exitFunc then 
		exitFunc(exitHandle, self, function ( self )
			require("MahjongHall/Setting/ServiceRuleWindow");
			self.serviceWindow = new(ServiceRuleWindow , self.delegate,1);
			self.serviceWindow:set_callback_exit(self, function(self, isShow)
                    self.serviceWindow = nil;
			end );
		end)
	end  

end

-- 服务条款
HallTopLayer.clickServiceTerms = function(self)
	if self.settingWindow then
		delete(self.settingWindow);
		self.settingWindow = nil;
	end	

	showOrHide_sprite_lua(0);
 

	local exitHandle = nil 
	local exitFunc   = nil 
	if self.m_inViewType == HallTopLayer.InLevelChooseView then 
		exitHandle = self.delegate.m_levelChooseLayer
		exitFunc   = self.delegate.m_levelChooseLayer.playExitAnim
	elseif self.m_inViewType == HallTopLayer.InHallMainView then 
		exitHandle = self.delegate
		exitFunc   = self.delegate.playExitHallAnim
	end 

	if exitHandle and exitFunc then 
		exitFunc(exitHandle, self, function ( self )
			require("MahjongHall/Setting/ServiceRuleWindow");
			self.serviceWindow = new(ServiceRuleWindow , self.delegate,2);
			self.serviceWindow:set_callback_exit(self, function(self, isShow)
                    self.serviceWindow  = nil;
			end );
		end)

	end  

end

-- 资源下载
HallTopLayer.clickDownloadResoures = function(self)
	-- self.settingWindow:hide();
	if GameConstant.isUpdating then
		local str = "温馨提示", "正在更新中，请稍候";
		local view = PopuFrame.showNormalDialogForCenter(str, GameConstant.curGameSceneRef, nil, nil, true);
		view:setHideCloseBtn(true);
		if view then
			view:setCallback(view, function(view, isShow)
				if not isShow then
					
				end
			end );
		end
	else
		GlobalDataManager.getInstance():showDownloadPopuFrame();
	end
end


-- 请求更新
HallTopLayer.OnUpdateClick = function(self)
	if not self.delegate:canEnterView() then
		return;
	end
	GlobalDataManager.getInstance():requestUpdateVersionInfo( 1 ); -- 更新
end


HallTopLayer.isOpenLoginView = function ( self )
	local disWin = self.delegate.m_mainView
	if disWin then 

	end 
end
-------------------------------------------------------------------------------------------------------------------------------------

-- 定义可操作控件的标识
HallTopLayer.s_controls =
{
	setBtn 			= 1,
	helpBtn 		= 2,
	messageBtn		= 3,

	firstChargeBtn  = 4,
	playerInfoBtn   = 5,
	vipBtn			= 6,

	nameText        = 7,
	moneyText       = 8,

	photoImage      = 9,
	playerHeadView  = 10,

	vipExpView 		= 11,
	vipExpBtn 		= 12,
	vipExpText 		= 13,

	onlineBtn 		= 14,
	onlineBtnText	= 15,
	onlineView 		= 16,

	vipExpExtraText = 17,

    t_diamond = 18,--钻石
}

-- 可操作控件在布局文件中的位置
HallTopLayer.s_controlConfig =
{
	[HallTopLayer.s_controls.setBtn] 			= { "top_view", "set_btn" },
	[HallTopLayer.s_controls.helpBtn] 			= { "top_view", "help_btn" },
	[HallTopLayer.s_controls.messageBtn]		= { "top_view", "message_btn" },

	[HallTopLayer.s_controls.firstChargeBtn] 	= { "top_view", "first_charge_btn" },
	[HallTopLayer.s_controls.playerInfoBtn] 	= { "top_view", "player_head_view", "head_btn"},
	--[HallTopLayer.s_controls.vipBtn] 			= { "top_view", "player_head_view", "vip_btn" },

	[HallTopLayer.s_controls.nameText] 			= { "top_view", "player_head_view","name_bg", "name_text" },
	[HallTopLayer.s_controls.moneyText]		 	= { "top_view", "player_head_view","coin_bg","money_text" },

	[HallTopLayer.s_controls.photoImage] 		= { "top_view", "player_head_view","head_btn", "head_icon" },
	[HallTopLayer.s_controls.playerHeadView] 	= { "top_view", "player_head_view"},

	[HallTopLayer.s_controls.vipExpView] 		= { "top_view", "player_head_view", "vip_exp_view"},
	[HallTopLayer.s_controls.vipExpBtn] 		= { "top_view", "player_head_view", "vip_exp_view", "vip_btn"},
	[HallTopLayer.s_controls.vipExpExtraText] 	= { "top_view", "player_head_view", "vip_exp_view", "vip_img_time","Text2"},
	[HallTopLayer.s_controls.vipExpText] 		= { "top_view", "player_head_view", "vip_exp_view", "vip_img_time","Text3"},

	[HallTopLayer.s_controls.onlineView] 		= { "top_view","online_view"},
	[HallTopLayer.s_controls.onlineBtn] 		= { "top_view","online_view","online_reward_btn"},
	[HallTopLayer.s_controls.onlineBtnText] 	= { "top_view","online_view","online_time_view","online_time_bg","online_time"},
    [HallTopLayer.s_controls.t_diamond] = {"top_view","player_head_view","diamond_bg","t"},
}

-- 可操作控件的响应函数
HallTopLayer.s_controlFuncMap =
{
	[HallTopLayer.s_controls.setBtn] 			= HallTopLayer.onClickedSetBtn,
	[HallTopLayer.s_controls.helpBtn] 			= HallTopLayer.onClickedHelpBtn,
	[HallTopLayer.s_controls.messageBtn]		= HallTopLayer.onClickedMessageBtn,

	[HallTopLayer.s_controls.firstChargeBtn] 	= HallTopLayer.onClickedFirstChargeBtn,
	[HallTopLayer.s_controls.playerInfoBtn] 	= HallTopLayer.onClickedPlayerInfoBtn,
	--[HallTopLayer.s_controls.vipBtn] 			= HallTopLayer.onClickedVipBtn,

}

-- 可接受的更新界面命令
HallTopLayer.s_cmds =
{
	--updataUserInfo = 1,

};

-- 命令响应函数
HallTopLayer.s_cmdConfig =
{
	--[HallTopLayer.s_cmds.updataUserInfo] = HallTopLayer.updataUserInfo,

};

HallTopLayer.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_FLUSH_FEE_BACK_TIP_NUM] 				= HallTopLayer.requestFlushFeeBackTipNumCallback,
	[PHP_CMD_REQUEST_FEE_BACK_TIP_NUM] 						= HallTopLayer.requestFeeBackTipNumCallback,

	[PHP_CMD_OPPO_REQUEST_ONLINE_TIME] 						= HallTopLayer.onlineAwardCallBack,
	[PHP_CMD_OPPO_REQUEST_ONLINE_TIME_AWARD] 				= HallTopLayer.onlineCanAwardCallback,
};