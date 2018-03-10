-- UserInfoWindow.lua
-- Author: YifanHe
-- Date: 2013-10-31
-- Last modification : 2013-10-31
-- Description: 个人信息界面，可以查看个人信息和个人番型以及VIP特权
-- local subViewLayout = require(ViewLuaPath.."subViewLayout");
local userInfoCommon = require(ViewLuaPath.."userInfoCommon");
local cardRecordView = require(ViewLuaPath.."cardRecordView");
local hall_vip_iconPin_map = require("qnPlist/hall_vip_iconPin");
--local userInfoLayout = require(ViewLuaPath.."userInfoLayout");
--local gameDetailsLayout = require(ViewLuaPath.."gameDetailsLayout");
require("MahjongCommon/RechargeTip");
require("MahjongData/PlayerManager");
require("MahjongHall/UserInfo/PropsListItem");
require("MahjongSocket/NetConfig")
--local userVipPin_map = require("qnPlist/userVipPin")

local hall_user_infoPin_map = require("qnPlist/hall_user_infoPin")

require("MahjongConstant/MahjongImageFunction");
require("MahjongHall/UserInfo/ChangeNicknameWnd");
require("MahjongHall/HongBao/HongBaoModel")

require("MahjongHall/hall_2_interface_base")

UserInfoWindow = class(hall_2_interface_base);

State_UserInfo  = 1;
State_VIPInfo   = 2;
State_gameInfo  = 3;
State_propInfo  = 4;
State_Begin    = 10;

UserInfoWindow.ctor = function ( self , delegate , state )
	DebugLog("UserInfoWindow.ctor")
	self.m_delegate = delegate;
--	g_GameMonitor:addTblToUnderMemLeakMonitor("UserInfo",self)
    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.userinfo);
    self:set_tab_title({"个人信息", "VIP特权", "牌局信息", "我的道具"});
    self:set_tab_count(4);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();

end

UserInfoWindow.on_enter = function (self)
    --当前的vip显示
    self.m_current_vip_idx = 1;

	self.state = State_Begin;
	--事件机制
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():register(GlobalDataManager.myItemListUpdated, self, self.updateMyItemList);
	EventDispatcher.getInstance():register(GlobalDataManager.updateVipSceneEvent, self, self.updateMyVipInfo);
	EventDispatcher.getInstance():register(GlobalDataManager.exchangeCNNSEvent, self, self.changeNicknameCallback);
    EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.hongbaoNumChange);

	self.gender = 0;
	self:addContentView();

    self:set_tab_callback(self,self.tab_click);
	---------------
	state = state or State_UserInfo
	if state ==  State_propInfo then 
		self:onClickPropTag()
	elseif state == State_gameInfo then 
		self:onClickDetailsBtn()
	elseif state == State_VIPInfo then
		self:onClickVipTag()
	else 
		self:onClickUserInfoTag()
	end

	DebugLog('Profile clicked userinfo stop:'..os.clock(),LTMap.Profile)

end

UserInfoWindow.on_exit = function (self)
    umengStatics_lua(Umeng_UserBack);
end

UserInfoWindow.on_before_exit = function (self)
    return self:checkAndUploadUserInfo();
end

UserInfoWindow.tab_click = function (self, index)
    --1:个人信息，2:vip特权，3:牌局信息 4:我的道具
    
    if index == 1 then
        self:onClickUserInfoTag();
    elseif index == 2 then
        self:onClickVipTag();
    elseif index == 3 then
        self:onClickDetailsBtn();
    elseif index == 4 then
        self:onClickPropTag();
    end
end

UserInfoWindow.addContentView = function( self )
	DebugLog("UserInfoWindow.addContentView")

	self:getAllControls()
    --
    self.m_btn_left:setOnClick(self, function (self)
        self.m_current_vip_idx = self.m_current_vip_idx - 1;
        if self.m_current_vip_idx < 1 then
            self.m_current_vip_idx = 1
        end
        --self:refresh_vip_str();
        local str_t = dict_get_string("vip_show_str", "vip_info_t_"..self.m_current_vip_idx);
        if not str_t then
             self:send_get_vip(self.m_current_vip_idx, 0);
        else
            self:refresh_vip_str();
        end
        
    end);
    self.m_btn_right:setOnClick(self, function (self)
        self.m_current_vip_idx = self.m_current_vip_idx + 1;
        if self.m_current_vip_idx > 10 then
            self.m_current_vip_idx = 10
        end
        --self:refresh_vip_str();
        local str_t = dict_get_string("vip_show_str", "vip_info_t_"..self.m_current_vip_idx);
        if not str_t then
             self:send_get_vip(self.m_current_vip_idx, 0);
        else
            self:refresh_vip_str();
        end
    end);

    
end


function UserInfoWindow.hongbaoNumChange( self, status )
	if status == HongBaoModel.UsedHongBaoEvent and self.state == State_propInfo then 
		--消耗了红包
		if GameConstant.changeNickTimes.rednum <= 0 then 
            local propsList = publ_getItemFromTree(self.content, {  "propInfo","propInfoScrollView"});
            propsList:removeAllChildren(); 
            GlobalDataManager.getInstance():onRequestMyItemList();   
			return
		end 
	end 
end


UserInfoWindow.dtor = function ( self )
	DebugLog("UserInfoWindow.dtor")
    
    self.super.dtor(self);

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.myItemListUpdated, self, self.updateMyItemList);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateVipSceneEvent, self, self.updateMyVipInfo);
    EventDispatcher.getInstance():unregister(GlobalDataManager.exchangeCNNSEvent, self, self.changeNicknameCallback);
    EventDispatcher.getInstance():unregister(HongBaoModel.HongBaoMsgs, self, self.hongbaoNumChange);
	self:removeAllChildren();
end

UserInfoWindow.updataUIByGlobalEvent = function ( self, param )
	if not param or GlobalDataManager.UI_UPDATA_MONEY == param.type then -- 更新金币（not param 时也更新，为了兼容老代码）
		if self.coinText then
			local myMoney = trunNumberIntoThreeOneFormWithInt(PlayerManager.getInstance():myself().money) or 0;
			self.coinText:setText(myMoney.."");
		end
	end
end

UserInfoWindow.createUserInfoTag = function( self )
	--绑定性别选择按钮事件

	self.femaleCheckBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UserSexFemale);
		self.maleCheck:setVisible(false);
		self.femaleCheck:setVisible(true);
		if not publ_isFileExsit_lua( self.myUserInfo.localIconDir ) then 
			if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    self:setHeadPhoto("Login/yx/Commonx/default_woman.png");
			else
				self:setHeadPhoto("Commonx/default_woman.png")
			end
			--self.headImg:setFile("Commonx/default_woman.png");
		end
		self.gender = 1;
	end);
	self.maleCheckBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UserSexMale);
		self.maleCheck:setVisible(true);
		self.femaleCheck:setVisible(false);
		if not publ_isFileExsit_lua( self.myUserInfo.localIconDir ) then 
			if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    self:setHeadPhoto("Login/yx/Commonx/default_man.png");
			else
				self:setHeadPhoto("Commonx/default_man.png")
			end
			--self.headImg:setFile("Commonx/default_man.png");
		end
		self.gender = 0;
	end);
	self:updateUserInfo();  --更新数据
end

UserInfoWindow.changeNicknameCallback = function( self )
	self:realShowChangeNick();
end


UserInfoWindow.getAllControls = function ( self )
	-- body	self.content 	= 
	--加载layout文件
	self.content = SceneLoader.load(userInfoCommon)
	self.m_bg:addChild(self.content)

	--加载标签
	self.userInfoTag 	= self.m_btn_tab[1];
	self.userInfoTagImg = self.m_btn_tab[1].img;
	self.userInfoText 	= self.m_btn_tab[1].t;


	self.vipTag 		= self.m_btn_tab[2];
	self.vipTagImg  	= self.m_btn_tab[2].img;
	self.vipText 		= self.m_btn_tab[2].t;

	self.detailsTag 	= self.m_btn_tab[3];
	self.detailsTagImg  = self.m_btn_tab[3].img;
	self.detailsText    = self.m_btn_tab[3].t;

	self.propTag 		= self.m_btn_tab[4];
	self.propTagImg 	= self.m_btn_tab[4].img;
	self.propText 		= self.m_btn_tab[4].t;

	--加载子页面
	self.userInfoView 	= publ_getItemFromTree(self.content, {   "userInfo"});
	self.vipInfoView 	= publ_getItemFromTree(self.content, {   "vipInfo"});
	self.detailsView 	= publ_getItemFromTree(self.content, {   "gameInfo"});
	self.propInfoView 	= publ_getItemFromTree(self.content, {   "propInfo"});
	
	local sc = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView"});
	sc:setSize(sc:getSize());  --修复引擎bug

	------个人信息
	self.maleCheckBtn   	= publ_getItemFromTree(self.content, {   "userInfo", "row2","man_btn"});
	self.femaleCheckBtn 	= publ_getItemFromTree(self.content, {   "userInfo", "row2","woman_btn"});

	self.headImg 			= publ_getItemFromTree(self.content, {   "userInfo", "head_btn","head_img"})
	self.idText 			= publ_getItemFromTree(self.content, {   "userInfo", "userID"});
	self.nickNameText 		= publ_getItemFromTree(self.content, {   "userInfo", "row1","text_nickname"});
	self.btnChangeNickname  = publ_getItemFromTree(self.content, {   "userInfo", "row1","changeNickBtn"});

	self.maleCheck 			= publ_getItemFromTree(self.content, {   "userInfo", "row2", "man_selected_img"});
	self.femaleCheck 		= publ_getItemFromTree(self.content, {   "userInfo", "row2", "woman_selected_img"});

	self.levelText 			= publ_getItemFromTree(self.content, {   "userInfo", "row3", "level"});
	self.coinText 			= publ_getItemFromTree(self.content, {   "userInfo", "row4", "coin"});
	self.payBtn 			= publ_getItemFromTree(self.content, {   "userInfo", "row4", "chargeBtn"});
	self.gameInfoText 		= publ_getItemFromTree(self.content, {   "userInfo", "row5", "gameInfo"});
    self.btnRecord 		= publ_getItemFromTree(self.content, {   "userInfo", "row5", "btnRecord"});

	self.vipLevelImg 		= publ_getItemFromTree(self.content, {   "userInfo", "row6", "vipLevelImg"});
	self.vipBtn 			= publ_getItemFromTree(self.content, {   "userInfo", "row6", "vipBtn"});
	self.vipBtnText 		= publ_getItemFromTree(self.content, {   "userInfo", "row6", "vipBtn", "vipBtnText"});
	self.vipTipText			= publ_getItemFromTree(self.content, {   "userInfo", "row6", "vipText"});
	self.notVipText         = publ_getItemFromTree(self.content, {   "userInfo", "row6", "notVipText"})

	self.headBtn 			= publ_getItemFromTree(self.content, {   "userInfo", "head_btn"});
	self.realNameBtn 		= publ_getItemFromTree(self.content, {   "userInfo", "realNameBtn"});
	self.realNameImage 		= publ_getItemFromTree(self.content, {   "userInfo", "real_name_bg"});

	self.headBtn:setType(Button.Gray_Type)
	--牌局信息
	self.tianhuText			= publ_getItemFromTree(sc, {"detailsInfoView", "tianhu"});
	self.qinglongqiduiText	= publ_getItemFromTree(sc, {"detailsInfoView", "qinglongqidui"});
	self.qingqiduiText		= publ_getItemFromTree(sc, {"detailsInfoView", "qingqidui"});
	self.jiangduiText		= publ_getItemFromTree(sc, {"detailsInfoView", "jiangdui"});
	self.qingyiseText		= publ_getItemFromTree(sc, {"detailsInfoView", "qingyise"});
	self.qiduiText			= publ_getItemFromTree(sc, {"detailsInfoView", "qidui"});
	self.dihuText			= publ_getItemFromTree(sc, {"detailsInfoView", "dihu"});
	self.longqiduiText		= publ_getItemFromTree(sc, {"detailsInfoView", "longqidui"});
	self.qingyaojiuText		= publ_getItemFromTree(sc, {"detailsInfoView", "qingyaojiu"});
	self.qingduiText		= publ_getItemFromTree(sc, {"detailsInfoView", "qingdui"});
	self.daiyaojiuText		= publ_getItemFromTree(sc, {"detailsInfoView", "daiyaojiu"});
	self.duiduihuText		= publ_getItemFromTree(sc, {"detailsInfoView", "duiduihu"});

    self.m_btn_left = publ_getItemFromTree(self.content, {  "vipInfo", "btn_left"});
    self.m_btn_right = publ_getItemFromTree(self.content, {  "vipInfo", "btn_right"});

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","progressBg","progress"}):setFile("Login/wdj/Hall/userinfo/progress.png");
		publ_getItemFromTree(self.content, {  "userInfo","row1","nick_name_bg"}):setFile("Login/wdj/Hall/userinfo/user_name_bg.png");
		self.userInfoTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.vipTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.detailsTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.propTagImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		
	end
	--self.vipInfoWnd         = publ_getItemFromTree(self.content, { "vipInfo"} )
end


--创建牌局记录
UserInfoWindow.createViewRecord = function (self, data)
    DebugLog("UserInfoWindow.createViewRecord");
    if not data then
        DebugLog("UserInfoWindow.createViewRecord data is nil");
    end

--     [timestamp] => 1463135778
--          [record] => Array
--              (
--                  [0] => stdClass Object
--                      (
--                          [time] => 1463135446
--                          [type] => 0
--                          [dz] => 300
--                          [lf] => 0
--                          [hs] => 0
--                          [tmoney] => -3600
--                      )
    if self.recordWindow then
        self.recordWindow:removeFromSuper();
        self.recordWindow = nil;
    end
    local window = new(SCWindow);
    
    
    window:addToRoot();
    window:setCoverEnable(false)
    self.recordWindow = window;
    

    window.m_layout = SceneLoader.load(cardRecordView);
    window:addChild(window.m_layout);
    window:setWindowNode(window.m_layout);
    window:showWnd();

    publ_getItemFromTree(window.m_layout, {"bg",  "closeBtn"}):setOnClick(self, function (self)
        self.recordWindow:removeFromSuper();
        self.recordWindow = nil;
    end);

    local scrollview = publ_getItemFromTree(window.m_layout, {"bg",  "ScrollView1"});
    

    
     
    --保存时间撮
    GlobalDataManager.getInstance().m_Record.Timestamp = data.timestamp or 0;

    for i = 1, #data.record do
        if #GlobalDataManager.getInstance().m_Record.list > 50 then
            table.remove(GlobalDataManager.getInstance().m_Record.list, 1)
        end
        GlobalDataManager.getInstance().m_Record.list[#GlobalDataManager.getInstance().m_Record.list+1] = data.record[i];
    end
    --排序
    function timeSort(s1 , s2)
	    return (tonumber(s1.time) or 0) > (tonumber(s2.time) or 0)
    end
    if #GlobalDataManager.getInstance().m_Record.list > 1 then
        table.sort(GlobalDataManager.getInstance().m_Record.list, timeSort);
    end
--    local time = data.time;
    local itemW, itemH = 775, 60;
    local fontSize = 28;
    for i = 1, #GlobalDataManager.getInstance().m_Record.list do--0x4B2B1C 
        local d = GlobalDataManager.getInstance().m_Record.list[i];
        local item = new(Node);
        item:setSize(itemW, itemH);
        item:setAlign(kAlignTopLeft);
        item:setPos(0,itemH*(i-1));
        scrollview:addChild(item);
        local tmpSTr = tostring(d.time);
        tmpSTr = getDateStringFromTime(tmpSTr);
        tmpSTr = stringFormatWithString(tmpSTr, 14, true);
        local time = new(Text, tmpSTr, 0, 0, kAlignLeft, "", fontSize, 0x4b, 0x2b, 0x1c)
        time:setAlign(kAlignLeft);
        time:setPos(0, 0);
        item:addChild(time);

        if tonumber(d.lf) and tonumber(d.lf) == 1  then
            tmpSTr = "两房牌:";
        else
            if tonumber(d.type) and tonumber(d.type) == 1  then
                tmpSTr = "血流成河:";
            else
                tmpSTr = "血战到底:";
            end
        end
        tmpSTr = tmpSTr..tostring(d.dz).."底";
        tmpSTr = stringFormatWithString(tmpSTr, 18, true);
        local tType = new(Text, tmpSTr, 0, 0, kAlignLeft, "", fontSize, 0x4b, 0x2b, 0x1c)
        tType:setAlign(kAlignLeft);
        tType:setPos(250, 0);
        item:addChild(tType);

--        tmpSTr = "血战--------------";
--        tmpSTr = stringFormatWithString(tmpSTr, 10, true);
--        local baseCoin = new(Text, tmpSTr, 0, 0, kAlignLeft, "", 24, 0x4b, 0x2b, 0x1c)
--        baseCoin:setAlign(kAlignLeft);
--        baseCoin:setPos(300, 0);
--        item:addChild(baseCoin);
        local strMoney = tostring(d.tmoney);
        if tonumber(d.tmoney) and tonumber(d.tmoney) < 0  then
            tmpSTr = "输:";
            
            if string.len(strMoney) >= 2 then
                strMoney = string.sub(strMoney, 2);
            end
        else
            tmpSTr = "赢:";
        end
        
        tmpSTr = tmpSTr..strMoney.."金币";
        tmpSTr = stringFormatWithString(tmpSTr, 14, true);
        local winText = new(Text, tmpSTr, 0, 0, kAlignLeft, "", fontSize, 0x4b, 0x2b, 0x1c)
        winText:setAlign(kAlignLeft);
        winText:setPos(550, 0);
        item:addChild(winText);

        local line = new(Image, "Commonx/split_hori.png")
        line:setAlign(kAlignBottom);
        local lineW, lineH = line:getSize();
        line:setSize(itemW,lineH);
        item:addChild(line);
    end

end

--发送消息牌局记录
UserInfoWindow.sendPhpGetRecord = function (self)
    DebugLog("UserInfoWindow.sendPhpGetRecord");

    local param = {};
    param.timestamp = GlobalDataManager.getInstance().m_Record.Timestamp or 0;
    if GlobalDataManager.getInstance().m_Record.Timestamp == 0 then
        GlobalDataManager.getInstance().m_Record.list = {};
    end
    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_GET_RECORD, param)
    --self:createViewRecord();
end

UserInfoWindow.updateUserInfo = function( self )
	if not self.content then
		return;
	end
	self.myUserInfo = PlayerManager.getInstance():myself();
	--ID
	self.idText:setText("ID:"..self.myUserInfo.mid);
	--昵称
	if self.myUserInfo and self.myUserInfo.nickName then
		self.nickNameText:setText( self.myUserInfo.nickName );
	end

	self.btnChangeNickname:setOnClick( self, function( self )
		self:showChangeNicknameWnd();
	end);

    --牌局记录
    self.btnRecord:setOnClick( self, function( self )
		self:sendPhpGetRecord();
	end);

	--性别
	self.gender = tonumber(self.myUserInfo.sex);

	self.maleCheck:setVisible(false);
	self.femaleCheck:setVisible(false);

	local dir = "";
	if self.gender == 1 or self.gender == 2 then  --如果是女性
		self.maleCheck:setVisible(false);
		self.femaleCheck:setVisible(true);
		dir = "Commonx/default_woman.png";
		if PlatformConfig.platformYiXin == GameConstant.platformType then 
		    dir = "Login/yx/Commonx/default_woman.png";
		end
	else
		self.maleCheck:setVisible(true);
		self.femaleCheck:setVisible(false);
		dir = "Commonx/default_man.png";
		if PlatformConfig.platformYiXin == GameConstant.platformType then 
		    dir = "Login/yx/Commonx/default_man.png";
		end
	end

	if GameConstant.uploadHeadIconName and GameConstant.uploadHeadIconName ~= "" then
		dir = GameConstant.uploadHeadIconName;
	elseif publ_isFileExsit_lua( self.myUserInfo.localIconDir ) then -- 已经下载了头像
		dir = self.myUserInfo.localIconDir;
	end

	self:setHeadPhoto(dir)
	--self.headImg:setFile(dir);
	
      --如果为起凡，头像和昵称不能进行修改
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        --self.nickEdit:setPickable(false);
        --publ_getItemFromTree(self.content, {"userInfo", "row1","nick_name_bg"}):setVisible(false);
        
        self.btnChangeNickname:setVisible(false)
    end

	--等级
	self.levelText:setText("Lv."..(self.myUserInfo.level or 0));
	
	--金币
	self.coinText:setText(trunNumberIntoThreeOneFormWithInt(self.myUserInfo.money));
	
	--支付按钮 
	self.payBtn:setOnClick(self, function ( self )
		umengStatics_lua(Umeng_UserRecharge);
		local otherScene = {};
        local param_t = {t = RechargeTip.enum.user_wnd ,probability_giftpack = 1,isShow = true, is_check_bankruptcy = false, is_check_giftpack = true,}
        RechargeTip.create(param_t)
	end);

	--战绩
	local gameStr = self.myUserInfo.wintimes .."胜/" ..
					 self.myUserInfo.losetimes .."负/" .. 
					 self.myUserInfo.drawtimes .."平";
	if self.myUserInfo.wintimes ~= 0 then
		local rate = self.myUserInfo.wintimes/(self.myUserInfo.losetimes + self.myUserInfo.drawtimes + self.myUserInfo.wintimes)*100;
		local rateInteger = math.floor(rate);  --战绩整数部分
		local rateDecimal = math.floor(rate*100) - (rateInteger*100);  --战绩两位小数
		rateDecimal = tostring(rateDecimal);
		if #rateDecimal == 1 then
			rateDecimal = "0"..rateDecimal;
		end
		gameStr = gameStr .."(" .. rateInteger.."."..rateDecimal.."%" .. ")";
	else
		gameStr = gameStr .."(0%)";
	end
	self.gameInfoText:setText(gameStr);
	--vip
	local myVipLevel = self.myUserInfo.vipLevel or 0;
	if myVipLevel <= 0 then
		self.notVipText:setVisible(true)
		self.vipLevelImg:setVisible(false);
		self.vipBtnText:setText("成为VIP");
		--self.vipTipText:setVisible(false)
	else
		self.notVipText:setVisible(false)
		if myVipLevel >= 10 then 
			self.vipLevelImg:setFile(hall_user_infoPin_map["VIP10.png"]);
		else 
			self.vipLevelImg:setFile(hall_user_infoPin_map["VIP"..myVipLevel..".png"]); --userVipLevelPin_map
		end 
		self.vipLevelImg:setVisible(true)
		--self.vipTipText:setVisible(true)
		self.vipBtnText:setText("提升VIP");
		DebugLog("myVipLevel:"..myVipLevel)

	end

	if myVipLevel >= 10 then 
		self.vipBtnText:setVisible(false)
		self.vipBtn:setVisible(false)
	end 

	self.vipBtn:setOnClick(self, function()
		local vipTextStr = self.vipBtnText:getText();

		if vipTextStr == "成为VIP" then
			umengStatics_lua(Umeng_UserBeVIP);
		else
			umengStatics_lua(Umeng_UserLevelVIP);
		end
		if GameConstant.checkType == kCheckStatusClose then 
			if FirstChargeView.getInstance():show() then
				return;
			end 
		end
        if vipTextStr == "成为VIP" then
		    local product = ProductManager.getInstance():getProductByPamount(6);
		    if not product then 
		    	return; 
		    end
		    --如果当前为审核状态，就需要二次弹框
			if tonumber(GameConstant.checkType) ~= kCheckStatusClose then
				local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";
						
				local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"购买","取消");
				view:setConfirmCallback(self, function ( self )
					PlatformFactory.curPlatform:pay(product);
				end);
				view:setCallback(view, function ( view, isShow )
					if not isShow then
						
					end
				end);
			else
				PlatformFactory.curPlatform:pay(product);
			end
        else
            local product = ProductManager.getInstance():getBankruptAndNotEventProduct();
            if not product then 
		    	return; 
		    end
		     --如果当前为审核状态，就需要二次弹框
			if tonumber(GameConstant.checkType) ~= kCheckStatusClose then
				local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";
						
				local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"购买","取消");
				view:setConfirmCallback(self, function ( self )
					PlatformFactory.curPlatform:pay(product);
				end);
				view:setCallback(view, function ( view, isShow )
					if not isShow then
						
					end
				end);
			else
				 PlatformFactory.curPlatform:pay(product);
			end

        end
	end);

	if PlatformConfig.platformContest == GameConstant.platformType then 
		self.vipBtn:setVisible(false);
		self.vipLevelImg:setVisible(false);
		self.payBtn:setVisible(false);
		self.vipTipText:setVisible(false);
	end

	----添加事件响应----
	--头像、实名认证、详细番型
	--如果是起凡，就不支持上传头像
	if GameConstant.platformType ~= PlatformConfig.platformDingkai then
		self.headBtn:setOnClick(self, UserInfoWindow.onClickHeadBtn);
	else
		self.headBtn:setPickable(false);
	end	
	self.realNameBtn:setOnClick(self, UserInfoWindow.onClickRealNameBtn);
	local isAdultVerify =  g_DiskDataMgr:getAppData(kIsAdultVerify, kNumMinusTwo)
	DebugLog(isAdultVerify);
	if 0 == isAdultVerify or 1== isAdultVerify then 
		self.realNameImage:setVisible(true);
		self.realNameBtn:setVisible(false);
	end
end

UserInfoWindow.setHeadPhoto = function ( self, filepath )
	if self.m_photoImageMask then 
		self.m_photoImageMask:removeFromSuper()
		self.m_photoImageMask = nil 
	end
	local texture = nil 
    if filepath then
        texture = TextureCache.instance():get(filepath)
        if texture then 
        	texture:reload()
    	end 
    end
    
	require("coreex/mask")
	self.m_photoImageMask = new(Mask,filepath,"Hall/userinfo/head_mask.png")
	self.headImg:addChild(self.m_photoImageMask)
	self.m_photoImageMask:setAlign(kAlignCenter)
end

UserInfoWindow.showChangeNicknameWnd = function( self )

	if self.myUserInfo.vipLevel >= 6 then
		self:realShowChangeNick();
		return;
	end

	if GameConstant.changeNickTimes.vipTimes == 0 and GameConstant.changeNickTimes.cardsNum == 0 then
		require("MahjongCommon/ExchangePopu");
		self.exchangePopu = new(ExchangePopu, ItemManager.CHANGE_NICK_CID, self );
		self.exchangePopu:setOnWindowHideListener( self, function( self )
			self.exchangePopu = nil;
		end);
		self.exchangePopu:showWnd();
	else
		self:realShowChangeNick();
	end
end

UserInfoWindow.realShowChangeNick = function( self )
	local tmpWnd = new( ChangeNicknameWnd, self, self.myUserInfo.sex, GameConstant.changeNickTimes.vipTimes, GameConstant.changeNickTimes.cardsNum, self.myUserInfo.vipLevel );
	tmpWnd:setOnOkClickListener( self, function( self, nickname )
		if self.nickNameText and self.nickNameText.m_res then 
			self.nickNameText:setText( nickname );
		end 
		self.myUserInfo.nickName = nickname;
		--tmpWnd:hideWnd();
	end);
	tmpWnd:showWnd();
end

UserInfoWindow.onTextChange = function ( self )
	self.nickEdit = publ_getItemFromTree(self.userInfoNode, {"userInfo", "nickEdit"});
	if getStringLen(self.nickEdit:getText()) > 20 then
		self.nickEdit:setText(PlayerManager.getInstance():myself().nickName);
		publ_getItemFromTree(self.userInfoNode, { "userInfo", "nickTip"}):setVisible(true);
	else
		publ_getItemFromTree(self.userInfoNode, {"userInfo", "nickTip"}):setVisible(false);
	end
end

UserInfoWindow.setCardHistoryNum = function ( self, textNode , num )
	-- body
	DebugLog(tostring(textNode) .. tostring(num))
	if textNode == nil  or num == 0 then 
		return 
	end 
	
	textNode:setText("达成"..num.."次");
	textNode:setColor(255,200,0)
end

UserInfoWindow.updateDetailsInfo = function( self )
	-- 设置金币数据
	publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","coinRecordView","mostCoin"}):setText(self.topMoneyNum);
	publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","coinRecordView","totalWin"}):setText(self.winMoneyNum);
	publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","coinRecordView","mostWin"}):setText(self.winOnceMoneyNum);
	
	--设置战绩数据
	self:setCardHistoryNum( self.tianhuText,self.tianhuNum)
	self:setCardHistoryNum( self.qinglongqiduiText, self.qinglongqiduiNum)
	self:setCardHistoryNum( self.qingqiduiText,self.qinglongqiduiNum)
	self:setCardHistoryNum( self.jiangduiText, self.jiangduiNum)
	self:setCardHistoryNum( self.qingyiseText, self.qingyiseNum)
	self:setCardHistoryNum( self.qiduiText, self.qiduiNum)
	self:setCardHistoryNum( self.dihuText, self.dihuNum)
	self:setCardHistoryNum( self.longqiduiText,self.longqiduiNum)
	self:setCardHistoryNum( self.qingyaojiuText,self.qingyaojiuNum)
	self:setCardHistoryNum( self.qingduiText,self.qingduiNum)
	self:setCardHistoryNum( self.daiyaojiuText,self.daiyaojiuNum)
	self:setCardHistoryNum( self.duiduihuText,self.duiduihuNum)


	local sc = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView"});
	sc:setSize(sc:getSize());  --修复引擎bug
end

UserInfoWindow.checkAndUploadUserInfo = function ( self )
    --播放退出动画前会调用这个方法，
    --因为进入和退出动画可以是并行的，
    --所以有可能控件还没加载出来的时候就播放退出动画，这个时候可以返回true
    if not self.content then
        return true;
    end

	self.myUserInfo = PlayerManager.getInstance():myself();
	local nick = self.myUserInfo.nickName;
	local gender = self.myUserInfo.sex;
	self.newNick = self.nickNameText:getText();
	self.newNick = publ_trim(self.newNick);
	if nick == self.newNick and gender == self.gender then
		return true;  --没有需要更新的数据
	end
	if getStringLen(self.newNick) > 20 or self.newNick == "" then
		-- local msg = "您输入的昵称太长或没有输入昵称";
		-- Banner.getInstance():showMsg(msg);
		return true;
	end
	if not self.myUserInfo or self.myUserInfo.mid <= 0 then 
		CustomNode.hide( self );
		self:dtor();
		return true;
	end
	if nick ~= self.newNick then
		umengStatics_lua(Umeng_UserUpdateName);
	end
	local msg = "正在同步服务器，请稍候";
	Banner.getInstance():showMsg(msg);
	local param_data = {};
	param_data.mid = self.myUserInfo.mid;
	param_data.sitemid = SystemGetSitemid();
	param_data.mnick = self.newNick;
	param_data.msex = self.gender;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUSET_UPLOAD_USER_INFO, param_data);
	return false;
end

-----------  按钮事件响应  -----------
UserInfoWindow.onClickHeadBtn = function ( self )
	umengStatics_lua(Umeng_UserUploadHead);
	local api = {};
	local player = PlayerManager.getInstance():myself();
	api.mid = player.mid;
	api.username = "user_"..player.mid;
	api.time = os.time();
	api.api = tonumber(PlatformFactory.curPlatform.api);
	api.langtype = 1;
	api.version = GameConstant.Version;
	api.mtkey = player.mtkey;
	api.sid = tonumber(PlatformFactory.curPlatform.sid);
	api.method = "IconAndroid.upload";
	local signature = Joins(api, "");
	api.sig = md5_string(signature);

	local post_data = {};
	post_data.ImageName = PlayerManager.getInstance():myself().mid;  --用自己的mid当头像图片名称
	post_data.Url = GameConstant.CommonUrl.."?m=android&p=upicon";
	post_data.Api = api;
	post_data.type = 2;
	local dataStr = json.encode(post_data);
	native_to_java(kUpLoadImage, dataStr);
end

UserInfoWindow.onClickRealNameBtn = function ( self )
	umengStatics_lua(Umeng_UserRealName);
	require("MahjongHall/UserInfo/AvoidWallowWindow");
	self.m_avoidWallowWindow = new(AvoidWallowWindow,self);
	self:addChild(self.m_avoidWallowWindow);
end


UserInfoWindow.onClickUserInfoTag = function ( self )
	if not self:isTagChanged(State_UserInfo) then
		return;
	end
	umengStatics_lua(Umeng_UserUserInfo);
	self:createUserInfoTag();  --创建页面
	self:changeTagState(State_UserInfo);
end

UserInfoWindow.onClickVipTag = function ( self )
	if not self:isTagChanged(State_VIPInfo) then
		return;
	end
	umengStatics_lua(Umeng_UserVIPTag);
	local param_data = {};
	local vipCount      = g_DiskDataMgr:getFileKeyValue('VipData','vipCount',0)
	param_data.lastTime = g_DiskDataMgr:getFileKeyValue('VipData', "VipTimestamp", 0);
	if vipCount <= 0 then
		param_data.lastTime = 0;
	end
	self:createVipIconsByLocalData()	
	SocketManager.getInstance():sendPack( PHP_CMD_GET_VIP_DATA, param_data);
	SocketManager.getInstance():sendPack( PHP_CMD_GET_USER_VIP_INFO, {});

    --local p = {} 
    local viplevel = PlayerManager.getInstance():myself().vipLevel or 1;
    self.m_current_vip_idx = viplevel;



    local str_t = dict_get_string("vip_show_str", "vip_info_t_"..self.m_current_vip_idx);
    if not str_t then
        self:send_get_vip(viplevel, 0);
    end



	self:changeTagState(State_VIPInfo);
end

UserInfoWindow.onClickDetailsBtn = function ( self )
	if not self:isTagChanged(State_gameInfo) then
		return;
	end
	umengStatics_lua(Umeng_UserPaiJuTag);
	--开始获取最佳番型数据
	if not self.bestGameInfoFlag then
		SocketManager.getInstance():sendPack( PHP_CMD_REQUSET_BEST_GAME_INFO, param_data);
	end

	self:changeTagState(State_gameInfo);
end

UserInfoWindow.onClickPropTag = function ( self )
	if not self:isTagChanged(State_propInfo) then
		return;
	end
	umengStatics_lua(Umeng_UserMyItemTag);

	-- if not self.getMyPacketFlag then
	-- 	GlobalDataManager.getInstance():onRequestMyItemList();
	-- else
	-- 	self:updateMyItemList();
	-- end
	GlobalDataManager.getInstance():onRequestMyItemList();
	self:changeTagState(State_propInfo);
end

UserInfoWindow.isTagChanged = function( self, tag )
	-- 没有切换到其他标签的情况
	if self.state ~= tag then
		return true;
	end
end

UserInfoWindow.changeTagState = function( self, tag )
	--清除状态
	self.userInfoView:setVisible(false);
	self.vipInfoView:setVisible(false);

	self.detailsView:setVisible(false);
	self.propInfoView:setVisible(false);
	self.userInfoTagImg:setVisible(false);
	self.vipTagImg:setVisible(false);
	self.detailsTagImg:setVisible(false);
	self.propTagImg:setVisible(false);
	if self.rightExplainBg then
		self.rightExplainBg:setVisible(false);
	end

	if State_UserInfo == tag then
		umengStatics_lua(Umeng_UserUserInfo);
		self.userInfoView:setVisible(true);
		self.userInfoTagImg:setVisible(true);
		self.vipTag:setFile("Commonx/tab_right.png")
		self.detailsTag:setFile("Commonx/tab_right.png")
		self.propTag:setFile("Commonx/tab_right.png")
	elseif State_VIPInfo == tag then
		--self:createVipInfoView();
		umengStatics_lua(Umeng_UserVIPTag);
		self.vipInfoView:setVisible(true);
		self.vipTagImg:setVisible(true);
		self.userInfoTag:setFile("Commonx/tab_left.png")
		self.detailsTag:setFile("Commonx/tab_right.png")
		self.propTag:setFile("Commonx/tab_right.png")
	elseif State_gameInfo == tag then
		umengStatics_lua(Umeng_UserPaiJuTag);
		self.detailsView:setVisible(true);
		self.detailsTagImg:setVisible(true);
		self.userInfoTag:setFile("Commonx/tab_left.png")
		self.vipTag:setFile("Commonx/tab_left.png")
		self.propTag:setFile("Commonx/tab_right.png")
	elseif State_propInfo == tag then
		umengStatics_lua(Umeng_UserMyItemTag);
		self.propInfoView:setVisible(true);
		self.propTagImg:setVisible(true);
		self.userInfoTag:setFile("Commonx/tab_left.png")
		self.detailsTag:setFile("Commonx/tab_left.png")
		self.vipTag:setFile("Commonx/tab_left.png")
	end
	self.state = tag;
end

UserInfoWindow.onClickBackBtn = function ( self )
	self.getMyPacketFlag = false;
	umengStatics_lua(Umeng_UserBack);
	self:hide();
end

--创建VIP信息
--[[
UserInfoWindow.createVipInfoView = function ( self )
	
	if not self.vipViewWnd then
		local userVipInfoLayout = require(ViewLuaPath.."userVipInfoLayout");
		self.vipViewWnd = SceneLoader.load(userVipInfoLayout);
		self.vipInfoView:addChild(self.vipViewWnd);
	end
end
]]--

UserInfoWindow.updateMyItemList = function( self )
	self.getMyPacketFlag = true;
	local propsList = publ_getItemFromTree(self.content, {  "propInfo","propInfoScrollView"});
	local propsInfoList = ItemManager.getInstance().myItemList;
	if propsInfoList and #propsInfoList > 0 then
		--propsList:removeAllChildren()
		local hori_dis = 8
		local itemw,itemh = 276,216
		for i=1,#propsInfoList do
			local item = new(PropsListItem,propsInfoList[i])
			if item then
                item.exit_node = self;
				item:setPos(25 + (i-1)%4 * (itemw + hori_dis), getIntPart((i-1)/4) * itemh)
				propsList:addChild(item) 
			end 
		end
		propsList:setSize(propsList:getSize());
		--local adapter = new(CacheAdapter, PropsListItem, propsInfoList);
		--propsList:setAdapter(adapter);
		--propsList:setScrollBarWidth(2);
		--propsList:setMaxClickOffset(5);
	elseif #propsInfoList == 0 then
		local noPropsStr = "您暂时没有物品，请到兑换页兑换";
		local toExchangeBtn = UICreator.createBtn("Commonx/blank.png" , 320 , 280);
		propText = new(Text,noPropsStr,nil,nil,nil,kFontTextUnderLine,34,255, 255, 255);
        toExchangeBtn:setSize(propText.m_width + 5 , propText.m_height + 3);
        toExchangeBtn:addChild(propText);
        --toExchangeBtn:setType(Button.Gray_Type)
        toExchangeBtn:setOnClick(self , function(self)
            self:removeFromSuper();
            self.m_delegate.m_bottomLayer:onClickedMallBtn(State_ExchangeProp);
        end);	
		propsList:addChild(toExchangeBtn);
	end
end

UserInfoWindow.updateVipData = function ( self )
	local myUserInfo = PlayerManager.getInstance():myself();
	local vipLevel = myUserInfo.vipLevel or 0;  --等级
	local vipScore = myUserInfo.vipScore or 0;  --积分
	local vipTTL = myUserInfo.vipTTL or 0;  --过期时间
	local vipExpNeed = 0;


	local vipCount = g_DiskDataMgr:getFileKeyValue('VipData','vipCount',0)
	DebugLog("vipCount : "..vipCount);

	local vipIcon = publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","vipIcon"});
	vipIcon:setVisible(true);

	if vipLevel < 1 then
		vipIcon:setIsGray(true);
		vipIcon:setFile(hall_vip_iconPin_map["VIP1.png"]);
	elseif vipLevel > vipCount then
		vipIcon:setIsGray(false);
		vipIcon:setFile(hall_vip_iconPin_map["VIP10.png"]);
	else
		vipIcon:setIsGray(false);
		vipIcon:setFile(hall_vip_iconPin_map["VIP"..vipLevel..".png"]);
	end

	if vipLevel < vipCount then
		local needLevel = vipLevel;
		-- 如果不是体验VIP
		if vipTTL <= 0 then
			needLevel = needLevel + 1;
		end
		--下一等级需要积分值
		vipExpNeed = g_DiskDataMgr:getFileKeyValue('VipData','VIPjf'..needLevel,0)
	else
		-- 需要积分值
		vipExpNeed = g_DiskDataMgr:getFileKeyValue('VipData','VIPjf'..tostring(vipCount),0)
	end

	--VIP等级说明文字
	local vipNameStr = "";
	--VIP经验说明文字
	local vipExplainStr = "";

	if vipLevel == 0 then
		vipNameStr = "您还不是VIP,充值即获积分!";
	else
		if vipTTL > 0 then
			local endtimeTab = os.date("*t", vipTTL);
			local endtimeStr = endtimeTab.year .. "年" ..
							   endtimeTab.month .. "月" ..
							   endtimeTab.day .. "日" ..
							   endtimeTab.hour .. "时" ..
							   endtimeTab.min .. "分";
			vipExplainStr = "(到期时间:" .. endtimeStr .. ")"
			vipNameStr = "恭喜您成为体验VIP"
		else
			local level = vipLevel
			if level > vipCount then 
				level = vipCount
			end 
			local vipNmae = g_DiskDataMgr:getFileKeyValue("VipData" , "zsch"..level , "");
			vipNameStr = "恭喜您成为"..vipNmae.."VIP"..level;
		end
	end

	self.vipNameText = publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","vipContentText1"});
	self.vipNameText:setText(vipNameStr);

	if vipLevel >= vipCount then
		vipExplainStr = "(土豪，我们做朋友吧!)";
	else
		local needAmount = vipExpNeed - vipScore;
		if needAmount < 0 then
			needAmount = 0;
		end
		if vipTTL <= 0 then
			vipExplainStr = "(充值再获得"..needAmount.."积分，即可成为";
			local vipNmae = g_DiskDataMgr:getFileKeyValue("VipData" , "zsch"..(vipLevel+1) , "");
			vipExplainStr = vipExplainStr.."VIP"..(vipLevel+1) .. "!)";
			--vipExplainStr = vipExplainStr .. "！）";
		end
	end

	self.vipExplainText = publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","vipContentText2"});
	self.vipExplainText:setText(vipExplainStr);

	local x, y = self.vipNameText:getPos(); 
	self.vipExplainText:setPos(x + self.vipNameText.m_width, y + 3);

	--绘制进度条
	local needX = 0;
	if vipExpNeed and vipExpNeed ~= 0 then
		needX = 302 * (vipScore / vipExpNeed);
	end

	publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","progressBg","progress"}):setClip(2, 0, needX, 25);

	local showVipScore = vipScore;
	local totalScore = g_DiskDataMgr:getFileKeyValue("VipData", "VIPjf"..vipCount, 0);
	if vipScore > vipExpNeed then
		showVipScore = vipExpNeed;
	end
	publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","progressBg"}):setVisible(true);
	publ_getItemFromTree(self.content, {  "vipInfo","bottom_pre_img","progressBg","progressText"}):setText(showVipScore.."/"..vipExpNeed);

	local wantVipBtn = publ_getItemFromTree(self.content , {  "vipInfo","bottom_pre_img","wantVipBtn"});
	local wantVipText = publ_getItemFromTree(self.content , {  "vipInfo","bottom_pre_img","wantVipBtn","wantVipBtnText"});

	wantVipBtn:setVisible(true);
	wantVipText:setVisible(true)
	if vipLevel <= 0 then
		wantVipText:setText("成为VIP");
		wantVipBtn:setOnClick(self , function(self)
			
			if tonumber(GameConstant.checkType) == kCheckStatusClose then
            	if FirstChargeView.getInstance():show() then
				    return;
			    end
			end
			local product = ProductManager.getInstance():getProductByPamount(6);
		    if not product then 
		    	return; 
		    end

		    --如果当前是审核状态，就需要二次弹框
			if tonumber(GameConstant.checkType) ~= kCheckStatusClose then
				local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";
						
				local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"购买","取消");
				view:setConfirmCallback(self, function ( self )
					PlatformFactory.curPlatform:pay(product);
				end);
				view:setCallback(view, function ( view, isShow )
					if not isShow then
						
					end
				end);
			else
				PlatformFactory.curPlatform:pay(product);
			end

		end);
	else 
		wantVipText:setText("提升VIP");
		wantVipBtn:setOnClick(self , function(self)

            if tonumber(GameConstant.checkType) == kCheckStatusClose then
            	if FirstChargeView.getInstance():show() then
				    return;
			    end
			end
			local product = ProductManager.getInstance():getBankruptAndNotEventProduct();
			if not product then 
		    	return; 
		    end
		     --如果当前是审核状态，就需要二次弹框
			if tonumber(GameConstant.checkType) ~= kCheckStatusClose then
				 local text = "购买超值金币，畅想精彩游戏！你将购买"..product.pname .. "，资费" .. product.pamount .. "元！你确定要购买吗？\n客服电话:400-663-1888或0755-86166169";
						
				local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"购买","取消");
				view:setConfirmCallback(self, function ( self )
					PlatformFactory.curPlatform:pay(product);
				end);
				view:setCallback(view, function ( view, isShow )
					if not isShow then
						
					end
				end);
			else
				PlatformFactory.curPlatform:pay(product);
			end

		end);
	end
	DebugLog(vipLevel .. "@@@" .. vipCount)
	if vipLevel >= vipCount then 
		wantVipText:setVisible(false)
		wantVipBtn:setVisible(false)
	end 

	--创建特权说明弹框
	if not self.rightExplainBg then
		self.rightExplainBg = UICreator.createImg("newHall/userInfo/rightExplainBg.png", 0, 160, 10 , 230, 31 , 31);
		self.rightExplainBg:setSize(267, 122);
	------------------------------------
		self.vipInfoView:addChild(self.rightExplainBg);
		self.rightExplainText = new(TextView, "", 0, 160, kAlignLeft, nil, 24, 255, 255, 255);
		self.rightExplainText:setSize(250, 100);
		self.rightExplainText:setPos(8, 5);
		self.rightExplainBg:addChild(self.rightExplainText);
		self.rightExplainBg:setVisible(false);
		self.rightExplainBg:setLevel(1000);
		self.vipInfoView:setEventTouch(self, function(self, finger_action)
			if finger_action ==  kFingerUp then
				self.rightExplainBg:setVisible(false);
			end
		end);

		self.rightExplainText:setEventTouch(self, function(self, finger_action)
			if finger_action ==  kFingerUp then
				self.rightExplainBg:setVisible(false);
			end
		end);
	end
end

UserInfoWindow.createOrUpdateVipIcons = function( self, vipLevel )
	self.vipIconsView = publ_getItemFromTree(self.content, {   "vipInfo","iconScrollView"});
--	if self.vipIconsView then
--		self.vipIconsView:removeAllChildren();
--	end

	if self.rightExplainBg then
		self.rightExplainBg:setVisible(false);
	end
    local myself = PlayerManager.getInstance():myself();
    local my_vip = myself.vipLevel or 0;  --等级
    self.m_current_vip_idx = my_vip == 0 and 1 or my_vip;

    self:refresh_vip_str();
--	for i = 1, math.ceil(#self.vipRightsTab / 6) do
--		local iconsBg = new(Node);
--		iconsBg:setPos(20, ((i - 1) * 160) );
--		iconsBg:setSize(1100, 160);
--		-- 关闭说明弹窗的事件
--		iconsBg:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
--			if finger_action ==  kFingerUp then
--				if self.rightExplainBg then 
--					self.rightExplainBg:setVisible(false);
--				end 
--			end
--		end);
----UICreator.createImg = function ( imgDIr, x, y ,leftWidth, rightWidth, topWidth, bottomWidth)
--		local splitImg = UICreator.createImg("Commonx/split_hori.png",40,i * 160 - 10 )
--		splitImg:setSize(1100,2)		
--		for k, v in pairs(self.vipRightsTab) do
--			if math.floor(((k - 1) / 6) + 1) == i then
--				DebugLog("---------------------------".. tostring(i))

--				local vipValue = dict_get_string("VipData", v..vipLevel); -- TODO
--				local iconX  = 0;
--				if k % 6 == 0 then
--					iconX = 5 * 190 + 45;
--				else
--					iconX = (( k % 6 ) - 1) * 190 + 45;
--				end
--				if vipValue and vipValue ~= "" and vipValue ~= "0" then
--					DebugLog(v)
--					local icon = UICreator.createBtn(hall_vip_iconPin_map[v ..".png"], iconX, 3);
--					icon:setType(Button.Gray_Type)
--					iconsBg:addChild(icon);
--					--点击特权说明文字弹窗(有使用权)
--					icon:setOnClick(self, function( self )
--						self.rightExplainBg:setVisible(true);
--						local ix , iy = icon:getAbsolutePos();

--						local vx , vy = self.vipInfoView:getAbsolutePos();
--						local x, y = 16 + iconX , (iy - vy);
--						self.rightExplainBg:setPos(x - 35, y - 80);

--						self.rightExplainText:setText(string.format(self.vipRightsExplainTab[k], vipValue));
--					end);
--				else
--					local icon = UICreator.createGrayscaleBtn(hall_vip_iconPin_map[v ..".png"], iconX, 3);
--					icon:setType(Button.Gray_Type)
--					icon:setIsGray(true);
--					iconsBg:addChild(icon);
--					--点击出现特权说明文字弹窗(无使用权)
--					icon:setOnClick(self, function( self )
--						self.rightExplainBg:setVisible(true);
--						local ix , iy = icon:getAbsolutePos();
--						-- local vx , vy = self.VIPView:getAbsolutePos();
--						local vx , vy = self.vipInfoView:getAbsolutePos();
--						local x, y = 16 + iconX , (iy - vy);
--						self.rightExplainBg:setPos(x - 35, y - 80);
--						local limitLevel = self:findLimitLevel(v);
--						local vipNmae = MahjongCacheData_getDictKey_StringValue("VipData" , "zsch"..limitLevel , "");
--						if vipNmae ~= "" then
--							vipNmae = vipNmae.."VIP"..limitLevel;
--						else
--							vipNmae = "VIP";
--						end
--						self.rightExplainText:setText("成为"..vipNmae.."开启该项特权。");
--					end);
--				end
--				local iconName = UICreator.createText(self.vipRightsNameTab[k], iconX - 40, 102, 180, 30, kAlignCenter, 26, 255, 255, 255);
--				iconsBg:addChild(iconName);
--			end	
--		end	
--		self.vipIconsView:addChild(iconsBg);
--		self.vipIconsView:addChild(splitImg);
--		self.vipIconsView:setSize(self.vipIconsView:getSize());
--	end
end

UserInfoWindow.findLimitLevel = function( self, vip )
	local vipCount = g_DiskDataMgr:getFileKeyValue("VipData" , "vipCount" , 0);
	for i = 1, vipCount do
		local vipValue = g_DiskDataMgr:getFileKeyValue('VipData',vip..i,'0')
		if vipValue and vipValue ~= "" and vipValue ~= "0" then
			return i;
		end
	end
	return 0;
end



UserInfoWindow.hideWithNotAnim = function ( self, func, obj )
	--------------------
	self:setVisible(false);
	CustomNode.hide(self);
	self:removeFromSuper();
	--self.m_delegate:preEnterHallState();
	--self.m_delegate:playEnterHallAnim();	
	if func then 
		func(obj)
	end 
end


UserInfoWindow.exitWithAnim = function ( self )

	self:playExitAnim()
	return true 
end


--HTTP回调
UserInfoWindow.requsetBestGameInfoCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		self.bestGameInfoFlag = true;
		--番数列表
		self.tianhuNum = GetNumFromJsonTable(data, "tianhu", 0);
		self.dihuNum = GetNumFromJsonTable(data, "dihu", 0);
		self.qinglongqiduiNum = GetNumFromJsonTable(data, "qinglongqidui", 0);
		self.longqiduiNum = GetNumFromJsonTable(data, "longqidui", 0);
		self.qingqiduiNum = GetNumFromJsonTable(data, "qingqidui", 0);
		self.qingyaojiuNum = GetNumFromJsonTable(data, "qingyaojiu", 0);
		self.qingduiNum = GetNumFromJsonTable(data, "qingdui", 0);
		self.jiangduiNum = GetNumFromJsonTable(data, "jiangdui", 0);
		self.qingyiseNum = GetNumFromJsonTable(data, "qingyise", 0);
		self.daiyaojiuNum = GetNumFromJsonTable(data, "daiyaojiu", 0);
		self.qiduiNum = GetNumFromJsonTable(data, "qidui", 0);
		self.duiduihuNum = GetNumFromJsonTable(data, "duiduihu", 0);
		--金币数据
		self.topMoneyNum = trunNumberIntoThreeOneFormWithInt(GetNumFromJsonTable(data, "topMoney", 0));
		self.winMoneyNum = trunNumberIntoThreeOneFormWithInt(GetNumFromJsonTable(data, "winMoney", 0));
		self.loseMoneyNum = trunNumberIntoThreeOneFormWithInt(GetNumFromJsonTable(data, "loseMoney", 0));
		self.winOnceMoneyNum = trunNumberIntoThreeOneFormWithInt(GetNumFromJsonTable(data, "winOnceMoney", 0));
		self.loseOnceMoneyNum = trunNumberIntoThreeOneFormWithInt(GetNumFromJsonTable(data, "loseOnceMoney", 0));

		--最佳番型文字
		local paiType = GetNumFromJsonTable(data, "paiType", 0);  --胡牌型
		local geng = GetNumFromJsonTable(data, "geng", 0);  --根
		local gsh = GetNumFromJsonTable(data, "gsh", 0);  --杠上花
		local gsp = GetNumFromJsonTable(data, "gsp", 0);  --杠上炮
		local qgh = GetNumFromJsonTable(data, "qgh", 0);  --抢杠胡
		local zj = GetNumFromJsonTable(data, "zj", 0);  --绝张
		local hdly = GetNumFromJsonTable(data, "hdly", 0);  --海底捞月
		local jgd = GetNumFromJsonTable(data, "jgd", 0);  --金钩钓
		local turnMoney = GetNumFromJsonTable(data, "turnMoney", 0);
		local angangList = publ_luaStringSplit(GetStrFromJsonTable(data, "angang", ""), ",");
		local gangList = publ_luaStringSplit(GetStrFromJsonTable(data, "minggang", ""), ",");
		local pengList = publ_luaStringSplit(GetStrFromJsonTable(data, "peng", ""), ",");
		
		local handStr = GetStrFromJsonTable(data, "paiInfo", "");
		local handList = publ_luaStringSplit(handStr, ",");

		if handStr and handStr ~= "" then
			local bestStr = "";
			if paiType > 0 then
				bestStr = bestStr .. GameConstant.paixingfanshu[paiType];
			end
			if angangList[1] and gangList[1] and angangList[1] ~= "" and gangList[1] ~= "" then
				if tonumber(angangList[1]) ~= 0 or tonumber(gangList[1]) ~= 0 then
					bestStr = bestStr .. "  " .. tonumber(angangList[1]) + tonumber(gangList[1]) .. "杠";
				end
			end
			if geng ~= 0 then
				bestStr = bestStr .. "  " .. geng .. "根";
			end
			if gsh ~= 0 then
				bestStr = bestStr .. "  杠上花";
			end
			if gsp ~= 0 then
				bestStr = bestStr .. "  杠上炮";
			end
			if qgh ~= 0 then
				bestStr = bestStr .. "  抢杠胡";
			end
			if zj ~= 0 then
				bestStr = bestStr .. "  绝张";
			end
			if hdly ~= 0 then
				bestStr = bestStr .. "  海底捞月";
			end
			if jgd ~= 0 then
				bestStr = bestStr .. "  金钩钓";
			end
			self.bestGameText = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","bestGameView","bestGame"});
			self.bestGameText:setText(bestStr);
			
			self.bestGameImgs = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","bestGameView","cardNode"});
			self:createHandCard(self.bestGameImgs, angangList, gangList, pengList, handList);
            self:updateDetailsInfo();
		else
			local bestGameText = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","bestGameView","bestGame"});
			bestGameText:setVisible(false);
			local bestGameView = publ_getItemFromTree(self.content, {  "gameInfo","gameInfoScrollView","bestGameView"});
			local textStr = "赢一局，马上有";
			local scale = System.getLayoutScale();
			local wantToGameText = new(Text,textStr,nil,nil,kAlignTopLeft,kFontTextUnderLine,30,255, 255, 255);
			local wantToGameBtn = UICreator.createBtn("Commonx/blank.png");
			wantToGameBtn:setSize(wantToGameText.m_width , wantToGameText.m_height);
			wantToGameBtn:setPos(bestGameText.m_x / scale + 20, bestGameText.m_y / scale);
			wantToGameBtn:addChild(wantToGameText);
			bestGameView:addChild(wantToGameBtn);
			wantToGameBtn:setOnClick(self , function( self )
				DebugLog("wantToGameBtn setOnClick");
				self:removeFromSuper();
				self.m_delegate:onClickedQuickStartBtn();
			end);
		end
	end
end

UserInfoWindow.requsetUploadUserInfoCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
		self:exitWithAnim();
        return;
    end
	if isSuccess then
		local flag = GetBooleanFromJsonTable(data, "flag", false);
		local msg = GetStrFromJsonTable(data, "msg");
		if flag then
			msg = msg or "修改数据成功";
			Banner.getInstance():showMsg(msg);
			PlayerManager.getInstance():myself().sex = self.gender;
			PlayerManager.getInstance():myself().nickName = self.newNick;
			self:hide();
		else
			Banner.getInstance():showMsg(msg);
			self:exitWithAnim()
		end
	end
end

UserInfoWindow.createHandCard = function( self, root, angangList, gangList, pengList, handList )	
	self.currentX = 0;
	local cardW = 88;
	local cardH = 128;
    local ajustX = -6;

	--创建暗杠牌
	if angangList and angangList ~= {} then
		if angangList[1] ~= "0" then
			for i = 2, #angangList do
				local a,b = math.modf(angangList[i] / 10);
				angangList[i] = a * 16 + b * 10;
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getAnGangImageFileBySeat(kSeatMine, PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, self.currentX, 0);
					root:addChild(card);
					self.currentX = self.currentX + cardW - 1 + ajustX;
					if k == 2 then
						local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,angangList[i],PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
						local card = UICreator.createImg(baseDir, self.currentX - cardW + 1 - ajustX, -30);
						local cardF = UICreator.createImg(faceDir);
						card:addChild(cardF);
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
				local a,b = math.modf(gangList[i] / 10);
				gangList[i] = a * 16 + b * 10;
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,gangList[i],PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, self.currentX, 0);
					local cardF = UICreator.createImg(faceDir);
					card:addChild(cardF);
					root:addChild(card);
					self.currentX = self.currentX + cardW + 1 + ajustX;
					if k == 2 then
						local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,gangList[i],PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
						local card = UICreator.createImg(baseDir, self.currentX - cardW - 1 - ajustX, -30);
						local cardF = UICreator.createImg(faceDir);
						card:addChild(cardF);
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
				local a,b = math.modf(pengList[i] / 10);
				pengList[i] = a * 16 + b * 10;
				for k = 1, 3 do
					local baseDir, faceDir, offsetX, offsetY = getPengGangImageFileBySeat(kSeatMine,pengList[i],PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
					local card = UICreator.createImg(baseDir, self.currentX, 0);
					local cardF = UICreator.createImg(faceDir);
					card:addChild(cardF);
					root:addChild(card);
					self.currentX = self.currentX + cardW + 1 + ajustX;
				end
			end 
		end
	end

	--创建手牌
	for k, v in pairs(handList) do
		if v ~= "0" then
			local a,b = math.modf(v / 10);
			v = a * 16 + b * 10;
			local baseDir, faceDir, offsetX, offsetY =  getPengGangImageFileBySeat(kSeatMine,v,PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ));
			local card = UICreator.createImg(baseDir, self.currentX, 0);
			local cardF = UICreator.createImg(faceDir);
			card:addChild(cardF);
			root:addChild(card);
			self.currentX = self.currentX + cardW + 1 + ajustX;
		end
	end

	root:addPropScaleSolid(0, 0.85, 0.85, kCenterTopLeft);

end

--刷新vip 字符串显示
UserInfoWindow.refresh_vip_str =  function( self )
    DebugLog("[UserInfoWindow]:refresh_vip_str");

    if self.state ~= State_VIPInfo then
        return;
    end

    self.m_btn_left:setPickable(self.m_current_vip_idx > 1);
    self.m_btn_left:setIsGray(self.m_current_vip_idx <= 1);
    
    self.m_btn_right:setPickable(self.m_current_vip_idx < 10);
    self.m_btn_right:setIsGray(self.m_current_vip_idx >= 10);

    local str_t = dict_get_string("vip_show_str", "vip_info_t_"..self.m_current_vip_idx);
    local str_d = dict_get_string("vip_show_str", "vip_info_d_"..self.m_current_vip_idx);
    if  not str_t or not str_d then
        --self:send_get_vip(self.m_current_vip_idx, 0);
        return;
    end
    local str = str_t.. str_d;
    self.vipIconsView:removeAllChildren();

    local rich_t = new(RichText, str, 800, 0, kAlignLeft, nil, 28, 0x68, 0x3a, 0x23, true);
    rich_t:setAlign(kAlignTop);
	rich_t:setPos(0,0)
	self.vipIconsView:addChild(rich_t)  
 
end

--php 返回的 vip显示的字符串
UserInfoWindow.get_vip_show_str_callback = function( self, isSuccess, data )
    DebugLog("[UserInfoWindow]:get_vip_show_str_callback");
    Loading.hideLoadingAnim();
    if isSuccess and data then
        local viplevel = data.vip ;
        if viplevel then
           dict_set_int(kMap, "vip_str_timestamp"..viplevel,(tonumber(data.time) or 0));
           self.m_current_vip_idx = viplevel;   
        end
        
		dict_save(kMap);
        local info  = data.info;
        if info and viplevel then
--            for k,v in pairs(info) do
--                dict_set_string("vip_show_str", "vip_info_d_"..k, tostring(v and v.desc or ""));
--                dict_set_string("vip_show_str", "vip_info_t_"..k, tostring(v and v.title or ""));
--            end
              
            dict_set_string("vip_show_str", "vip_info_d_"..viplevel, tostring(info.desc or ""));
            dict_set_string("vip_show_str", "vip_info_t_"..viplevel, tostring(info.title or ""));

            dict_save("vip_show_str");
            
        end
        self:refresh_vip_str(); 
    end

end

UserInfoWindow.getVipDataCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
        return;
    end

	if isSuccess and data then
		DebugLog("【VIP】已经获取到VIP展示数据");
		dict_set_int(kMap, "VipTimestamp", tonumber(data.time));   --更新时间戳
		dict_save(kMap);
		local status = data.status
		-- 需要更新数据的情况
		if status == 1 then  
			--注：数据内-1为无限期使用,0为无法使用,其他数值为使用期限或者具体参数
			local vipCount = 0;
			for k, v in pairs(data.info) do
				g_DiskDataMgr:setFileKeyValue("VipData", "VIPbs"..k, tostring(v.VIPbs) or "" );  --vip标示
				g_DiskDataMgr:setFileKeyValue("VipData", "czfl"..k , tostring(v.czfl) or "" );  --充值返利
				g_DiskDataMgr:setFileKeyValue("VipData", "qdjb"..k , tostring(v.qdjb) or "" );  --签到金币
				g_DiskDataMgr:setFileKeyValue("VipData", "pcbz"..k , tostring(v.pcbz) or "" );  --破产补助
				g_DiskDataMgr:setFileKeyValue("VipData", "trgn"..k , tostring(v.trgn) or "" );  --踢人功能
				g_DiskDataMgr:setFileKeyValue("VipData", "sykbx"..k, tostring(v.sykbx) or "" );  --随意开包厢
				g_DiskDataMgr:setFileKeyValue("VipData", "kxtxk"..k, tostring(v.kxtxk) or "" );  --酷炫头像框
				g_DiskDataMgr:setFileKeyValue("VipData", "VIPzshd"..k, tostring(v.VIPzshd) or "" );  --vip专属活动
				g_DiskDataMgr:setFileKeyValue("VipData", "VIPkf"..k, tostring(v.VIPkf) or "" );  --VIP客服
				g_DiskDataMgr:setFileKeyValue("VipData", "bjfc"..k , tostring(v.bjfc) or "" );  --不计负场
				g_DiskDataMgr:setFileKeyValue("VipData", "zdycyy"..k, tostring(v.zdycyy) or "" );  --自定义常用语
				g_DiskDataMgr:setFileKeyValue("VipData", "ffdbjb"..k, tostring(v.ffdbjb) or "" );  --丰富的表情包
				g_DiskDataMgr:setFileKeyValue("VipData", "hhmjz"..k , tostring(v.hhmjz) or "" );  --豪华麻将子
				g_DiskDataMgr:setFileKeyValue("VipData", "mjzblp"..k, tostring(v.mjzblp) or "" );  --麻将周边礼品
				g_DiskDataMgr:setFileKeyValue("VipData", "zsch"..k  , tostring(v.zsch) or "" );  --专属称号
				g_DiskDataMgr:setFileKeyValue("VipData", "xgnc"..k  , tostring(v.xgnc) or "" );  --修改昵称
				g_DiskDataMgr:setFileKeyValue("VipData", "zfbjtd"..k, tostring(v.zfbjtd) or "" );  --支付便捷通道
				g_DiskDataMgr:setFileKeyValue("VipData", "hysx"..k  , tostring(v.hysx) or "" );  --好友上限
				g_DiskDataMgr:setFileKeyValue("VipData", "VIPjf"..k , tonumber(v.VIPjf) or 0 );  --达到等级需要的积分
				g_DiskDataMgr:setFileKeyValue("VipData","vipHuIcon"..k, tostring(v.hptsh) or "" )
				if tonumber(k) > vipCount then
					vipCount = tonumber(k);
				end
			end
			g_DiskDataMgr:setFileKeyValue("VipData", "vipCount", vipCount);  --达到等级需要的积分
		end
		self.hasGotVipData = true;
		--self:updateVipIcons();
	end
end

UserInfoWindow.getUserVipCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		PlayerManager.getInstance():myself():initVipInfo(data);
		
		if self.state == State_VIPInfo then
			self.hasGotVipInfo = true;
			self:updateVipData();  --刷新VIP数据
			self:updateVipIcons();
		end
	end
end

UserInfoWindow.updateVipIcons = function( self )
	if self.hasGotVipInfo and self.hasGotVipData then
		self:createVipIconsByLocalData()
	end
end

UserInfoWindow.createVipIconsByLocalData = function ( self )
	local myUserInfo = PlayerManager.getInstance():myself();
	local vipLevel = myUserInfo.vipLevel or 0;  --等级
	self:createOrUpdateVipIcons(vipLevel);
end

UserInfoWindow.send_get_vip = function (self, viplevel, timestamp)
    local p = {} 
    p.vip = viplevel
    p.lastTime = timestamp 
    SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_VIP_SHOW_STR, p);
end

function UserInfoWindow.updateMyVipInfo( self )
	DebugLog("请求updateMyVipInfo #############");
	SocketManager.getInstance():sendPack( PHP_CMD_GET_USER_VIP_INFO, {});
end

function UserInfoWindow:onChangeMyProplistItem( isSuccess, data, jsonData )
	Loading.hideLoadingAnim();
	if isSuccess and data then
		if data.status and tonumber( data.status ) == 1 then
			local msg = data.msg
			log( msg );
			if msg then
				Banner.getInstance():showMsg( msg );
			end
		end
	end
end

--获取牌局记录
function UserInfoWindow:onGetRecord( isSuccess, data, jsonData )
    DebugLog("UserInfoWindow:onGetRecord");
    if isSuccess and data then
        self:createViewRecord(data.data);
    end
end

UserInfoWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

--回调函数映射表
UserInfoWindow.phpMsgResponseCallBackFuncMap =
{
	[PHP_CMD_GET_VIP_DATA] 					= UserInfoWindow.getVipDataCallBack,
	[PHP_CMD_REQUSET_BEST_GAME_INFO] 		= UserInfoWindow.requsetBestGameInfoCallBack,
	[PHP_CMD_REQUSET_UPLOAD_USER_INFO]   	= UserInfoWindow.requsetUploadUserInfoCallBack,
	[PHP_CMD_GET_USER_VIP_INFO] 			= UserInfoWindow.getUserVipCallBack,
	[PHP_CMD_CHANGE_PAIZHI] 			    = UserInfoWindow.onChangeMyProplistItem,
	[PHP_CMD_REQUEST_CHANGE_ICON] 			= UserInfoWindow.onChangeMyProplistItem,
    [PHP_CMD_REQUEST_GET_RECORD]            = UserInfoWindow.onGetRecord,
    [PHP_CMD_REQUEST_VIP_SHOW_STR]          = UserInfoWindow.get_vip_show_str_callback,
};

UserInfoWindow.callEvent = function(self, param, json_data)
	if param == kUpLoadImage then
		if not param then
			return;
		end
		if not json_data or json_data.result == 0 then  		              
			local msg = "上传头像失败";       --上传失败
			Banner.getInstance():showMsg(msg);
		else   
			local player = PlayerManager.getInstance():myself();
			GameConstant.uploadHeadIconName = player.mid..".png";

			local socketType = NetConfig.getInstance():getCurSocketType()
			local photoKey = "uploadHeadIconName" .. tostring(PlatformFactory.curPlatform:getCurrentLoginType())..tostring(socketType)
			g_DiskDataMgr:setAppData(photoKey, GameConstant.uploadHeadIconName);
			player.localIconDir = GameConstant.uploadHeadIconName;
			--self.headImg:setFile( GameConstant.uploadHeadIconName );
			self:setHeadPhoto(GameConstant.uploadHeadIconName)
			local msg = "上传头像成功";    --上传成功	
			Banner.getInstance():showMsg(msg);
		end
	end
end

UserInfoWindow.vipRightsTab = {
	[1] = "VIPbs",  --vip标示
	[2] = "czfl",  --充值返利
	[3] = "qdjb",  --签到金币
	[4] = "pcbz",  --破产补助
	[5] = "trgn",  --踢人功能
	-- [6] = "sykbx",  --随意开包厢
	[6] = "kxtxk",  --酷炫头像框
	[7] = "VIPzshd",  --vip专属活动
	[8] = "VIPkf",  --VIP客服
	[9] = "bjfc",  --不计负场
	[10] = "zdycyy",  --自定义常用语
	[11] = "ffdbjb",  --丰富的表情包
	[12] = "hhmjz",  --豪华麻将子
	---[13] = "mjzblp",  --麻将周边礼品
	[13] = "zsch",  --专属称号
	[14] = "xgnc",  --修改昵称
	[15] = "zfbjtd",  --支付便捷通道
	[16] = "hysx",  --好友上限
	[17] = "vipHuIcon" --胡牌提示 hptsh vipHuIcon
}

UserInfoWindow.vipRightsNameTab = {
	[1] = "vip标示",
	[2] = "充值返利",
	[3] = "签到金币",
	[4] = "破产补助",
	[5] = "踢人功能",
	-- [6] = "包厢特权",
	[6] = "酷炫头像框",
	[7] = "VIP专属活动",
	[8] = "VIP客服",
	[9]  = "不计负场",
	[10] = "自定义常用语",
	[11] = "丰富的表情包",
	[12] = "豪华麻将子",
	--[13] = "麻将周边礼品",
	[13] = "专属称号",
	[14] = "修改昵称",
	[15] = "支付便捷通道",
	[16] = "好友上限",
	[17] = "智能胡牌提示"
}

UserInfoWindow.vipRightsExplainTab = {
	[1] = "特殊VIP标识：尊贵身份的体现。",
	[2] = "充金币返利：购买任意金币额外获赠%s。",
	[3] = "签到金币：签到时奖励增加为%s金币。",
	[4] = "破产补助：在游戏中破产，系统补助增加为%s金币。",
	[5] = "踢人功能：可以随意踢出其他VIP等级较低的玩家。",
	-- [6] = "包厢特权：不使用道具可以开%s场包厢。",
	[6] = "酷炫头像框：看名字，你就懂了！超级酷炫！",
	[7] = "VIP专属活动：针对VIP的专属活动，具体请留意相关活动。",
	[8] = "VIP客服：更快捷的客服答复，更尊贵的VIP服务！",
	[9]  = "不计负场：输牌时有%s的概率不计算负场次。",
	[10] = "自定义常用语：可以自行设定常用语。",
	[11] = "丰富的表情包：各种VIP的表情包，和您的尊贵身份相匹配！",
	[12] = "豪华麻将子：土豪就是要用土豪金版的麻将子，有木有？",
	--[13] = "麻将周边礼品：官方会不定期的赠送一些麻将周边礼品，请关注！",
	[13] = "专属称号：您就是%sVIP会员，您就是尊贵的象征！",
	[14] = "修改昵称：昵称不是你想改，想改就能改！拥有%s修改次数。",
	[15] = "支付便捷通道：专属的充值便捷渠道，尊贵地位的象征！",
	[16] = "好友上限：朋友多才热闹！好友上限增加至%s人！",
	[17] = "智能胡牌提示，怎么胡最科学？有它，一目了然！"
}

