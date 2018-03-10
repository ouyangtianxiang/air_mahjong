--[[
	className    	     :  HelpWindow.lua
	Description  	     :  帮助界面.
	last-modified-date   :  Dec.18 2013
	create-time 	   	 :  Oct.28 2013
	last-modified-author :  ClarkWu
	create-author        :　YifanHe
]]

--local helpTabsLayout = require(ViewLuaPath.."helpTabsLayout");
local helpSubview1 = require(ViewLuaPath.."helpSubview1");
local helpSubview2 = require(ViewLuaPath.."helpSubview2");



require("ui/listView");
require("ui/editTextView");
require("ui/node");
require("MahjongPlatform/PlatformFactory");
require("MahjongData/PlayerManager");
require("MahjongHall/Help/FeedBackItem");
require("MahjongHall/Help/FanCalculateItem");
require("MahjongCommon/RechargeTip");
require("MahjongHall/hall_2_interface_base")

HelpWindow = class(hall_2_interface_base);

State_FeedBack = kNumOne;--反馈界面
State_CommonQuestion = kNumTwo; --常见问题
State_PlayMethod = kNUmThree;--基本玩法
State_FanCalculate = kNumFour; --番型计算
State_Moving = kNumTen;

--[[
	function name	   : HelpWindow.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.31 2013
]]
HelpWindow.ctor = function (self, delegate)
--	g_GameMonitor:addTblToUnderMemLeakMonitor("Help",self)
	self.m_delegate = delegate
    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.help);
    self:set_tab_title({"我要反馈", "常见问题", "基本玩法", "番型计算"});
    self:set_tab_count(4);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();
end


--[[
	function name	   : HelpWindow.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.dtor = function (self)
	self.super.dtor(self);
	delete(self.showViewAnim);
	self.showViewAnim = nil;
	EventDispatcher.getInstance():unregister(self.m_event, self, self.onHttpRequestsListenster);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	self:removeAllChildren();
end

HelpWindow.on_enter = function (self)
    --ios
	if GameConstant.iosDeviceType > 0 then
		kHelpViewParam.appid = PlatformFactory.curPlatform:feedbackGameAppID();
		kHelpViewPHPSendingView.appid = PlatformFactory.curPlatform:feedbackGameAppID();
		kHelpToJavaImg.appid = PlatformFactory.curPlatform:feedbackGameAppID();
		kHelpViewPHPSendingView.ftitle = GameString.convert2UTF8(PlatformFactory.curPlatform:returnIsLianyunName());
	end

    --杂项配置
    self.other_config_data = GlobalDataManager.getInstance():get_other_config_data();
	self.state 			= State_FeedBack;  --默认选择页数
	self.clickTag 		= State_FeedBack;  --最后一次有效选择的标签页
	self.feedbackNum 	= kNumZero;

	self.openDebugData = {elapseTime = 0.2, nowClickNum = 0, needClickNum = 7, lastClickTime = 0}

	--历史提问信息
	self.serviceInfo = {};

	-- 注册网络事件
	self.m_event = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(self.m_event, self, self.onHttpRequestsListenster);
	-- 图片回调
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);

	self.tabView   = self.m_v;

	--我要反馈
	self.wantToKnow = self.m_btn_tab[1]
	self.wantToKnowText = self.m_btn_tab[1].t
	self.wantToKnowImg  = self.m_btn_tab[1].img


	--常见问题
	self.commonQuestion = self.m_btn_tab[2]
	self.commonQuestionText = self.m_btn_tab[2].t
	self.commonQuestionImg  = self.m_btn_tab[2].img


	--基本玩法
	self.playMethod = self.m_btn_tab[3]
	self.playMethodText = self.m_btn_tab[3].t
	self.playMethodImg  = self.m_btn_tab[3].img


	--番型计算
	self.fanCalculate = self.m_btn_tab[4]
	self.fanCalculateText = self.m_btn_tab[4].t
	self.fanCalculateImg  = self.m_btn_tab[4].img



	self.animTime = 0;

	DebugLog('Profile clicked help stop:'..os.clock(),LTMap.Profile)

    self:set_tab_callback(self,self.tab_click);

    self:onClickwantToKnow();
end

HelpWindow.on_exit = function (self)

end

HelpWindow.tab_click = function (self, index)
    --1:我要反馈，2:常见问题，3:基本玩法，3:番型计算

    if index == 1 then
        self:onClickwantToKnow();
    elseif index == 2 then
        self:onClickCommonQuestion();
    elseif index == 3 then
        self:onClickPlayMethod();
    elseif index == 4 then
        self:onClickfanCalculate();
    end
end

--[[
	function name	   : HelpWindow.createWantToKnowView
	description  	   : 创建我要提问界面.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.createWantToKnowView = function (self)
	if self.helpSubview1 then
		return;
	end

	self.helpSubview1 = SceneLoader.load(helpSubview1);
	self.tabView:addChild(self.helpSubview1);

	self.editview = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "img_et_bg", "et_feeback"});
	self.editview:setHintText("请填写您的宝贵意见，我们会在1~3日内进行答复。", 0x47, 0x30, 0x30);

	--设置遮罩
	self.uploadMaskImg = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "btn_upload","img_mask"});
	self.uploadMaskImg:setVisible(true);
	self.uploadImg = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "btn_upload","img_upload_image"});
	--self.uploadImg:setClipRes(self.uploadMaskImg.m_res);

	--设置提交事件
	publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "btn_post"}):setOnClick(self,self.onClickfeedbackBtn);
	publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "btn_upload"}):setOnClick(self,self.onClickuploadImgBtn);

	local btn_phone1 = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2","view_phone", "btn_phone1" });
	local text_phone1 = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone", "btn_phone1", "text_phone1" });
	local btn_phone2 = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone", "btn_phone2" });
	local text_phone2 = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone", "btn_phone2", "text_phone2" });

	local btn_addQQGroup = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2","view_phone", "btn_qqgroup"});
	local text_qqgroup = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone","btn_qqgroup","text_group"});

    if self.other_config_data.qqgroupnum then
        text_qqgroup:setText(self.other_config_data.qqgroupnum);
    end

    if self.other_config_data.phonenum1 then
        text_phone1:setText(publ_trim(self.other_config_data.phonenum1));
    end
    if self.other_config_data.phonenum2 then
        text_phone2:setText(self.other_config_data.phonenum2);
    end




    --在线客服
    local btn_online_help = publ_getItemFromTree(self.helpSubview1, {"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "btn_online"});

	---------------------------------------------------------------------------
	local btnW,btnH = btn_addQQGroup:getSize()
	local qqTextW,qqTextH = text_qqgroup:getSize()
	btn_addQQGroup:setSize(qqTextW,btnH)

	local qqGroupTextPre = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2","view_phone", "Text4"});
	local qqGroupTextSuf = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2","view_phone", "Text5"});

	--self:autoSuitResetPos(qqGroupTextPre,btn_addQQGroup,qqGroupTextSuf)
	if GameConstant.platformType == PlatformConfig.platformOPPO
		or GameConstant.checkType == kCheckStatusOpen then --oppo去掉qq群信息,一键审核去掉
		qqGroupTextPre:setVisible(false)
		qqGroupTextSuf:setText("客服电话 ：")
		btn_addQQGroup:setVisible(false)
	end

	---------------------------------------------------------------------------
    --在线客服
    btn_online_help:setOnClick(self,function(self)
        local loginType = GameConstant.lastLoginType
        local loginCls = PlatformFactory.curPlatform:getLoginUtl(loginType)
        local userType = "游客"
        if loginCls then
            userType = loginCls:getLoginUserName();
        end
        local myself = PlayerManager.getInstance():myself();
        local data = {}
        data.gameId = 11   --四川gameId
        data.siteId = GameConstant.api
        data.stationId = myself.mid
        data.role = myself.vipLevel >= 1 and 3 or 2
        data.vipLevel = myself.vipLevel
        data.nickName = myself.nickName
        data.accountType = userType
        data.client = PlatformFactory.curPlatform:returnIsLianyunName() or "主版本"
        if myself.localIconDir ~= "" then
	        data.avatarUri = System.getStorageImagePath() .. myself.localIconDir
	    else
	    	local imageName = ""
	    	if myself.sex == kSexMan then
	    		imageName = CreatingViewUsingData.commonData.boyPicLocate
	    	else
	    		imageName = CreatingViewUsingData.commonData.girlPicLocate
	    	end
	    	data.avatarUri = System.getStorageAppRoot() .. "images\/" .. imageName
	    end

        native_to_java(kOnlineService, json.encode(data))

    end);
		if GameConstant.iosDeviceType > 0 then
			btn_online_help:setVisible(false);
		end
	btn_addQQGroup:setOnClick(self,function(self)
		local qqText = self.other_config_data.qqgroupkey or "";
        if GameConstant.iosDeviceType > 0 then
           qqText = self.other_config_data.qqgroupnum or "";
        end
		callAddGroup(qqText);
	end);

	btn_phone1:setOnClick( self, function( self )
		local phone = text_phone1:getText();
		callPhone( phone );
	end);

	btn_phone2:setOnClick( self, function( self )
		local phone = text_phone2:getText();
		callPhone( phone );
	end);

     --如果为起凡，将联系方式改为QQ
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        btn_phone1:setVisible(false);
        btn_phone2:setVisible(false);
        publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone", "Text33" }):setVisible(false);
        self.QQ = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part2", "view_phone", "View1", "Text21" });
        self.QQ:setText("联系QQ群: 2897738207");
    end

    if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
    	publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "btn_upload"}):setFile("Login/wdj/Hall/help/help_img_bg.png");
    	publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sub_view_inner_part1", "img_et_bg"}):setFile("Login/wdj/Hall/help/help_text_bg.png");
    	self.wantToKnowImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    	self.commonQuestionImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    	self.playMethodImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    	self.fanCalculateImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    end

	--开始获取历史提问
	self.loading = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sv_feedback", "img_loading" });
	self.loading:addPropRotate(1, kAnimRepeat, 3000, -1, -360, 0, kCenterDrawing);
	HttpModule.getInstance():execute(HttpModule.s_cmds.requsetFeedbackList, kHelpViewParam, self.m_event,kFeedbackURL);
end

HelpWindow.autoSuitResetPos = function ( self,node1,node2,node3 )
	local x1,y1 = node1:getPos()
	local off = 10
	local x2,y2 = node2:getPos()
	local w1,h1 = node1:getSize()
	local w2,h2 = node2:getSize()
	--local w3,h3 = node3:getSize()
	node2:setPos(x1 + w1 + off, y2)
	--node3:setPos(x1 + w1 + w2 + off*2, y1)
end
--[[
	function name	   : HelpWindow.createWantToKnowView
	description  	   : 创建常见问题界面.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]

HelpWindow.updateFeedbackList = function ( self )
	-- body
	local listFeedback = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sv_feedback"});
	--设置滚动条
	listFeedback:setScrollBarWidth(0);
	listFeedback:removeAllChildren();
	listFeedback:setSize(1120,System.getScreenScaleHeight() - 40 - 460)
	local listViewInfoW, listViewInfoH = listFeedback:getSize();


	local x = 0;
	local y = 0;

	for i = #self.serviceInfo, 1, -1 do

		local service = self.serviceInfo[i];

		if PlatformFactory.curPlatform and service.question then
			local strName = PlatformFactory.curPlatform:returnIsLianyunName();
			local _,askNum = string.find(service.question,strName);
			if askNum then
				history = string.sub(service.question,askNum + 1);
			end

			if string.len(service.question) > 0 then
				local n = new(FeedBackItem, listViewInfoW, srcollViewInfoH, service, self, self.updateFeedbackScrollView, self, self.sendFeedbackSolve, self, self.sendFeedbackVote);
				n:setPos(x, y);
				listFeedback:addChild(n);
				local w, h = n:getSize();
				y = y + h-- + 10;
			end
		end
	end
end

HelpWindow.updateFeedbackScrollView = function ( self )
	-- body
	local listFeedback = publ_getItemFromTree(self.helpSubview1,{"sub_part","sub_view","sub_view_inner", "sv_feedback"});
	listFeedback:setSize(1120,System.getScreenScaleHeight() - 40 - 460)
	local child = listFeedback:getChildren();
	listFeedback.m_nodeH = 0;

	local curx  = 0;
	local cury 	= 0;

	for i = 1, #child do
		child[i]:setPos(curx, cury);
		local x, y = child[i]:getUnalignPos();
		local w, h = child[i]:getSize();

		listFeedback.m_nodeH = (listFeedback.m_nodeH > y + h) and listFeedback.m_nodeH or (y + h);

		cury = cury + h;
	end

	ScrollView.update(listFeedback);
end


HelpWindow.creatCommonQuestionView = function (self)
	if self.helpSubview2 then
		return;
	end
	-- view 2
	self.helpSubview2 = SceneLoader.load(helpSubview2);
	self.tabView:addChild(self.helpSubview2);

	local srcollViewInfo = publ_getItemFromTree(self.helpSubview2,{"sub_part","sub_view","sub_view_inner", "sv_info"});
	srcollViewInfo:setSize(1150,System.getScreenScaleHeight() - 210)
	--设置滚动条
	srcollViewInfo:setScrollBarWidth(5);
	--加载内容
	local srcollViewInfoW, srcollViewInfoH = srcollViewInfo:getSize();
	srcollViewInfoW = srcollViewInfoW - 30
	local x = 0;
	local y = 0;

	for i = 1, #CommomQuestionConfig do
		local n = new(FanCalculateItem, srcollViewInfoW, srcollViewInfoH, CommomQuestionConfig[i]);
		n:setPos(x, y);
		srcollViewInfo:addChild(n);
		local w, h = n:getSize();
		-- y = y + h + 10;
		y = y + h + 30;
	end

	local gainCoinNode = UICreator.createTextBtn( "Commonx/green_big_wide_btn.png", 900, 365, "获取金币", 34, 255, 255, 255)
	gainCoinNode:setOnClick(self,self.onClickgainCoinBtn)
	srcollViewInfo:addChild(gainCoinNode)
--	dict_set_int("localUrlWebView", "webx", 0);
--	dict_set_int("localUrlWebView", "weby", 0);
--	dict_set_int("localUrlWebView", "webw", 800);
--	dict_set_int("localUrlWebView", "webh", 400);
--	dict_set_string("localUrlWebView", "weburl", "file:///android_asset/help.html");
--	native_to_java("localUrlWebView");
--	self.webviewIndex = dict_get_int("localUrlWebView", "handle", 0);
--	if self.webviewIndex > 0 then
--		DebugLog("self.webviewIndex : "..self.webviewIndex);
--	end
end

--[[
	function name	   : HelpWindow.createWantToKnowView
	description  	   : 创建基本玩法界面.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.creatPlayMethodView = function(self)
	if self.helpSubview3 then
		return;
	end
	self.helpSubview3 = SceneLoader.load(helpSubview2);
	self.tabView:addChild(self.helpSubview3);

	local srcollViewInfo = publ_getItemFromTree(self.helpSubview3,{"sub_part","sub_view","sub_view_inner", "sv_info"});
	srcollViewInfo:setSize(1150,System.getScreenScaleHeight() - 210)
	--设置滚动条
	srcollViewInfo:setScrollBarWidth(5);
	--加载内容
	local srcollViewInfoW, srcollViewInfoH = srcollViewInfo:getSize();
	srcollViewInfoW = srcollViewInfoW - 30
	local x = 0;
	local y = 0;

	for i = 1, #BaseSkillConfig do
		local n = new(FanCalculateItem, srcollViewInfoW, srcollViewInfoH, BaseSkillConfig[i]);
		n:setPos(x, y);
		srcollViewInfo:addChild(n);
		local w, h = n:getSize();
		-- y = y + h + 10;
		y = y + h + 30;
	end
end

--[[
	function name	   : HelpWindow.createWantToKnowView
	description  	   : 创建番型计算界面.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.createFanCalculateView = function(self)
	if self.helpSubview4 then
		return;
	end

	self.helpSubview4 = SceneLoader.load(helpSubview2);
	self.tabView:addChild(self.helpSubview4);

	local srcollViewInfo = publ_getItemFromTree(self.helpSubview4,{"sub_part","sub_view","sub_view_inner", "sv_info"});
	srcollViewInfo:setSize(1150,System.getScreenScaleHeight() - 210)
	--设置滚动条
	srcollViewInfo:setScrollBarWidth(5);
	--加载内容
	local srcollViewInfoW, srcollViewInfoH = srcollViewInfo:getSize();
	srcollViewInfoW = srcollViewInfoW - 30
	local x = 0;
	local y = 0;

	for i = 1, #FanStyleCalcConfig do
		local n = new(FanCalculateItem, srcollViewInfoW, srcollViewInfoH, FanStyleCalcConfig[i]);
		n:setPos(x, y);
		srcollViewInfo:addChild(n);
		local w, h = n:getSize();
		y = y + h + 30;
	end
end





--*****************************************************************按键响应 **************************************************--
--[[
	function name	   : HelpWindow.onClickgainCoinBtn
	description  	   : 购买金币按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickgainCoinBtn = function( self )
	umengStatics_lua(Umeng_HelpCharge);
	local player = PlayerManager.getInstance():myself();
	if player.mid <= 0 then
		Banner.getInstance():showMsg(PromptMessage.helpViewMallLimit);
		return;
	end


    local param_t = {t = RechargeTip.enum.help_wnd ,probability_giftpack = 1,isShow = true, is_check_bankruptcy = false, is_check_giftpack = true,}
    RechargeTip.create(param_t)

end

--[[
	function name	   : HelpWindow.onClickuploadImgBtn
	description  	   : 添加图片按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickuploadImgBtn = function( self )
	publ_selectImage(kUploadFeedBackImage);
end

--[[
	function name	   : HelpWindow.onClickfeedbackBtn
	description  	   : 反馈按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickfeedbackBtn = function( self )
	DebugLog("~!@###HelpWindow.onClickfeedbackBtn")
	umengStatics_lua(Umeng_HelpSubmitFeed);
	local player = PlayerManager.getInstance():myself();
	-- if player.mid <= kNumZero then
	-- 	Banner.getInstance():showMsg(PromptMessage.helpViewFeedLimit);
	-- 	return;
	-- end

	local feedbackStr = self.editview:getText();

	if not feedbackStr or feedbackStr == kNullStringStr or feedbackStr == " " then
		Banner.getInstance():showMsg(PromptMessage.helpViewFeedNull);
		return;
	end
	if self.lastfeedback == feedbackStr then
		Banner.getInstance():showMsg(PromptMessage.helpViewSameAsLast);
		return;
	end

	self.lastfeedback = feedbackStr;
	umengStatics_lua(Umeng_HelpFeedWords);
	if PlatformFactory.curPlatform then
		if GameConstant.iosDeviceType > 0 then
		else
			feedbackStr = (GameString.convert2UTF8(PlatformFactory.curPlatform:returnIsLianyunName()) or "") .. GameString.convert2UTF8(feedbackStr);
		end
	end
	local param_data = {};
	param_data.appid = kHelpViewPHPSendingView.appid;
	param_data.game =  kHelpViewPHPSendingView.game;
	param_data.title = kHelpViewPHPSendingView.ftitle;
	param_data.ftype = kHelpViewPHPSendingView.ftype;
	param_data.fwords = feedbackStr;
	param_data.fcontact = self:getFcontact();  --附加信息
    if not player or not player.mid or player.mid <= 0 then
        if GameConstant.iosDeviceType > 0 then
            param_data.mid = GameConstant.imei;
        else
            param_data.mid = SystemGetSitemid()
        end
    end
	HttpModule.getInstance():execute(HttpModule.s_cmds.requsetSendFeedback, param_data, self.m_event, kFeedbackURL);
end

HelpWindow.onClickTab = function ( self, index )
	-- body
	DebugLog("----------------------------------" .. tostring(index))
	local strTab = {"tab_1", "tab_2", "tab_3", "tab_4"};
	local view = {self.helpSubview1,self.helpSubview2,self.helpSubview3,self.helpSubview4};
	local flag = {
		{true, false, false,false},
		{false, true, false,false},
		{false, false, true,false},
		{false, false, false,true},
	};
	local tabs = {
		{1, 2, 2,2},
		{1, 1, 2,2},
		{1, 1, 1,2},
		{1, 1, 1,1},
	}
	local files = {
		"Commonx/tab_left.png",
		"Commonx/tab_right.png",
	}


	self.wantToKnowImg:setVisible( flag[index][1] );
	self.commonQuestionImg:setVisible( flag[index][2] );
	self.playMethodImg:setVisible( flag[index][3] );
	self.fanCalculateImg:setVisible( flag[index][4] );

	self.wantToKnow:setFile( files[ tabs[index][1] ] )
	self.commonQuestion:setFile( files[ tabs[index][2] ] )
	self.playMethod:setFile( files[ tabs[index][3] ] )
	self.fanCalculate:setFile( files[ tabs[index][4] ] )

	for i = 1, 4 do
		--publ_getItemFromTree(self.tabView, {"tab_view",strTab[i],"tab_bg"}):setVisible( i == index );
		if view[i] then
			view[i]:setVisible(i == index);
		end
	end
end

--[[
	function name	   : HelpWindow.onClickwantToKnow
	description  	   : 我要提问按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickwantToKnow = function(self)
	self:checkOpenDebugMode()

	umengStatics_lua(Umeng_HelpFeedTag);

	delete(self.showViewAnim);
	self.showViewAnim = nil;
	--创建我要提问视图
	self:onClickTab(1);
	self.showViewAnim = new(AnimInt , kAnimNormal , 0 , 1 , self.animTime , 0);
	self.showViewAnim:setEvent(self , self.createWantToKnowView);
end

--[[
	function name	   : HelpWindow.onClickPlayMethod
	description  	   : 基本玩法按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickPlayMethod = function(self)
	umengStatics_lua(Umeng_HelpRuleTag);

	delete(self.showViewAnim);
	self.showViewAnim = nil;
	--创建基本玩法视图
	self:onClickTab(3);
	self.showViewAnim = new(AnimInt , kAnimNormal , 0 , 1 , self.animTime , 0);
	self.showViewAnim:setEvent(self , self.creatPlayMethodView);
end

--[[
	function name	   : HelpWindow.onClickfanCalculate
	description  	   : 番型计算按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickfanCalculate = function(self)
	umengStatics_lua(Umeng_HelpTypeTag);

	delete(self.showViewAnim);
	self.showViewAnim = nil;
	--创建番型计算视图
	self:onClickTab(4);
	self.showViewAnim = new(AnimInt , kAnimNormal , 0 , 1 , self.animTime , 0);
	self.showViewAnim:setEvent(self , self.createFanCalculateView);
end

--检测开启/关闭debug模式
function HelpWindow:checkOpenDebugMode(  )
	local clickTime = os.clock()
	if self.openDebugData.lastClickTime == 0
		or clickTime - self.openDebugData.lastClickTime <= self.openDebugData.elapseTime then
		self.openDebugData.lastClickTime = clickTime
		self.openDebugData.nowClickNum = self.openDebugData.nowClickNum + 1
		if self.openDebugData.nowClickNum >= self.openDebugData.needClickNum then --开启/关闭debug
			if DEBUGMODE == 1 then
				DEBUGMODE = 0
				-- Banner.getInstance():showMsg("关闭debug模式")
			elseif DEBUGMODE == 0 then
				-- Banner.getInstance():showMsg("开启debug模式")
				DEBUGMODE = 1
			end
			self.openDebugData.lastClickTime = 0
			self.openDebugData.nowClickNum = 0
		end
	else
		DebugLog("too slow, restart calculate....")
		self.openDebugData.lastClickTime = 0
		self.openDebugData.nowClickNum = 0
		self:checkOpenDebugMode()              --重新开始计算
	end
end

--[[
	function name	   : HelpWindow.onClickCommonQuestion
	description  	   : 常见问题按键监听.
	param 	 	 	   : self
	last-modified-date : Dec.17 2013
	create-time  	   : Oct.28 2013
]]
HelpWindow.onClickCommonQuestion = function(self)
	umengStatics_lua(Umeng_HelpQuestionTag);

	delete(self.showViewAnim);
	self.showViewAnim = nil;
	--创建常见问题视图
	self:onClickTab(2);
	self.showViewAnim = new(AnimInt , kAnimNormal , 0 , 1 , self.animTime , 0);
	self.showViewAnim:setEvent(self , self.creatCommonQuestionView);
	-- self:creatCommonQuestionView();
end

--********************************************************PHP请求*****************************************************--
--[[
	function name      : HelpWindow.onFriendHttpRequestsListenster
	description  	   : The method of sending PHP.
	param 	 	 	   : self
						 command     String  -- 命令字段
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]

HelpWindow.onHttpRequestsListenster = function(self,command,...)
	if HelpWindow.httpRequestsCallBackFuncMap[command] then
		HelpWindow.httpRequestsCallBackFuncMap[command](self,...);
	end
end

--HTTP回调
--[[
	function name      : HelpWindow.sendFeedbackCallBack
	description  	   : 反馈PHP回调.
	param 	 	 	   : self
						 isSuccess   Boolean -- the request is whether or not successful.
						 data   	 Table   -- the request of php request.
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]
HelpWindow.requsetSendFeedbackCallBack = function( self, isSuccess, data )

	if not isSuccess or not data then
	    return;
	end

	if isSuccess then
		DebugLog("....................." .. tostring(data))
		mahjongPrint(data)
		self.fid = GetNumFromJsonTable(data.ret, kFid, kNumZero);
		if self.fid == kNumZero then
			self.lastfeedback = kNullStringStr;
			Banner.getInstance():showMsg(PromptMessage.helpViewFeedFailed);
			return;
		end
		--如果有图片开始上传图片
		if self.imageSelected then
			self:sendFeedbackImg();
		end
		Banner.getInstance():showMsg(PromptMessage.helpViewFeedSuccess);

		self.editview:setText(kNullStringStr);
		local service = {};
		service.question = self.lastfeedback;
		self.serviceInfo[#self.serviceInfo + 1] = service;

		--更新反馈列表
		self:updateFeedbackList();

	end
end

--[[
	function name      : HelpWindow.getFeedbackListCallBack
	description  	   : 得到反馈列表PHP回调.
	param 	 	 	   : self
						 isSuccess   Boolean -- the request is whether or not successful.
						 data   	 Table   -- the request of php request.
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]
HelpWindow.requsetFeedbackListCallBack = function( self, isSuccess, data )
	if self.loading then
		self.loading:setVisible(false);
		self.loading:removeProp(1);
	end

	if not isSuccess or not data then
	    return;
	end

	if isSuccess then
		self.getFeedbackFlag = true;
		self.feedbackNum = tonumber(#data.ret);
		if self.feedbackNum ~= kNumZero then
			self.historyTitles = {};
			self.historyAnwers = {};
			for k, v in pairs(data.ret) do
				local service = {};
				service.id 		 = GetStrFromJsonTable(v, kMsgId, kNullStringStr);
				service.question = GetStrFromJsonTable(v, kMsgTitle, kNullStringStr);
				service.answer	 = GetStrFromJsonTable(v, kRptTitle, kNullStringStr);
				service.votescore= GetStrFromJsonTable(v, kVotescore, kNullStringStr);
				service.readed	 = GetStrFromJsonTable(v, kReaded, kNullStringStr);
				self.serviceInfo[#self.serviceInfo + 1] = service;
			end

			self:updateFeedbackList();
		end
	end
end


HelpWindow.requsetFeedbackSolveCallBack = function( self, isSuccess, data )
	--dd.dd.dd=0;
end

HelpWindow.requsetFeedbackVoteCallBack = function( self, isSuccess, data )
	--kk.dd.dd=0;
end

--[[
	function name      : HelpWindow.getFcontact
	description  	   : 得到反馈机型列表.
	param 	 	 	   : self
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]
HelpWindow.getFcontact = function( self )
	if GameConstant.iosDeviceType > 0 then
		local fcontactstring = "Version.mini_ver:"..tostring(Version.mini_ver).." , "..GameConstant.feedBackExtraString;
		return fcontactstring;
	end
	local tempFeedList = CreatingViewUsingData.helpView.feedBack.feedList;
	local api = GameConstant.api
	local loginType = PlatformFactory.curPlatform:getCurrentLoginType();
	local fcontact = kNullStringStr;
	fcontact = fcontact .. tempFeedList.loginType .. (loginType or kNullStringStr);
	fcontact = fcontact .. tempFeedList.model_name .. (GameConstant.model_name or kNullStringStr);
	fcontact = fcontact .. tempFeedList.macAddress .. (GameConstant.macAddress or kNullStringStr);
	fcontact = fcontact .. tempFeedList.version .. (GameConstant.Version or kNullStringStr);
	fcontact = fcontact .. tempFeedList.device;
	fcontact = fcontact .. tempFeedList.net .. (GameConstant.net or kNullStringStr);
	fcontact = fcontact .. tempFeedList.ip .. (getPhoneIP() or kNullStringStr);
	fcontact = fcontact .. tempFeedList.isSdCard .. (GameConstant.isSdCard or kNullStringStr);
	fcontact = fcontact .. tempFeedList.platformType .. (GameConstant.platformType or kNullStringStr);
	fcontact = fcontact .. tempFeedList.api .. (GameConstant.api or kNullStringStr);
	fcontact = fcontact .. tempFeedList.mini_ver .. tostring(Version.mini_ver);
	fcontact = fcontact .. tempFeedList.endingType;
	return fcontact;
end

--[[
	function name      : HelpWindow.getFcontact
	description  	   : 发送反馈图片.
	param 	 	 	   : self
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]
HelpWindow.sendFeedbackImg = function( self )
	umengStatics_lua(Umeng_HelpFeedImage)
	local player = PlayerManager.getInstance():myself();
	local api_data = {};
	api_data.method = kHelpToJavaImg.method;
	api_data.mid = player.mid;
	api_data.param = {};
	api_data.param.fid = self.fid;
	api_data.param.appid = kHelpToJavaImg.appid;
	api_data.param.game = kHelpToJavaImg.game;
	api_data.param.pfile = kHelpToJavaImg.pfile;
	local post_data = {};
	post_data.ImageName = kHelpToJavaImg.iname;
	post_data.Url =	kFeedbackURL;
	post_data.Api = api_data;
	post_data.type = kHelpToJavaImg.ftype;
	local dataStr = json.encode(post_data);
	native_to_java(kUploadFeed, dataStr);
end

HelpWindow.sendFeedbackSolve = function( self, fid, bSolve )
	--发送请求
    local param_data = {};
    param_data.appid = kHelpViewPHPSendingView.appid;
	param_data.game =  kHelpViewPHPSendingView.game;
	param_data.title = kHelpViewPHPSendingView.ftitle;
	param_data.ftype = kHelpViewPHPSendingView.ftype;

    param_data.fid 		= fid;
    param_data.solved 	= bSolve and "1" or "0";
    HttpModule.getInstance():execute(HttpModule.s_cmds.requsetFeedbackSolve, param_data, self.m_event, kFeedbackURL);

end

 HelpWindow.sendFeedbackVote = function( self, fid, vote )
	--发送请求
    local param_data = {};
    param_data.appid = kHelpViewPHPSendingView.appid;
	param_data.game =  kHelpViewPHPSendingView.game;
	param_data.title = kHelpViewPHPSendingView.ftitle;
	param_data.ftype = kHelpViewPHPSendingView.ftype;
    param_data.fid 		= fid;
    param_data.score 	= vote;
    HttpModule.getInstance():execute(HttpModule.s_cmds.requsetFeedbackVote, param_data, self.m_event, kFeedbackURL)
end




--回调函数映射表
HelpWindow.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requsetSendFeedback] = HelpWindow.requsetSendFeedbackCallBack,
	[HttpModule.s_cmds.requsetFeedbackList] = HelpWindow.requsetFeedbackListCallBack,
	[HttpModule.s_cmds.requsetFeedbackSolve] = HelpWindow.requsetFeedbackSolveCallBack,
	[HttpModule.s_cmds.requsetFeedbackVote] = HelpWindow.requsetFeedbackVoteCallBack
};


--[[
	function name      : HelpWindow.callEvent
	description  	   : 回调函数.
	param 	 	 	   : self
	last-modified-date : Dec. 17 2013
	create-time		   : Oct. 28 2013
]]
HelpWindow.callEvent = function(self, param, data)
	if param == kSelectImage then
		if data.result == kSuccess then
			--显示截图
			self:setUploadPhoto(CreatingViewUsingData.helpView.feedBack.selectImg.fileName)
			--self.uploadImg:setFile(CreatingViewUsingData.helpView.feedBack.selectImg.fileName);
			self.imageSelected = true;
		else
			Banner.getInstance():showMsg(PromptMessage.helpViewLoadPicFailed);
		end
	elseif param == kUploadFeed then
		local bannerTips = PromptMessage.helpViewLoadPicFailed
		if data and data.ret then
			local isSave = tonumber(data.ret.isSave or 0)
			if tonumber(isSave) == kNumOne then
				bannerTips = PromptMessage.helpViewFeedThanksFeed
				self.imageSelected = false;
				--恢复默认图片
				self:setUploadPhoto(nil)
			end
		end
		Banner.getInstance():showMsg(bannerTips);
	end
end
HelpWindow.setUploadPhoto = function ( self, filepath )
	if self.m_photoImageMask then
		self.m_photoImageMask:removeFromSuper()
		self.m_photoImageMask = nil
	end
	if not filepath then
		return
	end
    TextureCache.instance():get(filepath):reload()
	require("coreex/mask")
	self.m_photoImageMask = new(Mask,filepath,"Hall/help/help_mask.png")
	self.uploadImg:addChild(self.m_photoImageMask)
	self.m_photoImageMask:setAlign(kAlignCenter)
end
HelpWindow.readCommomQuestionString = function ( self , index )
	local indexOfTable = CommomQuestionString[index];

	return indexOfTable;
end


--常见问题

CommomQuestionConfig =
{
	[1] =
	{
		["T"] = "Q: 如何获取金币？",
		["D"] = {
					[1] =
					{
						["T"] = "A: 1.",
						["D"] = "通过商城储值。",
					},
					[2] =
					{
						["T"] = "   2.",
						["D"] = "注意及时领取任务奖励。",
					},
					[3] =
					{
						["T"] = "   3.",
						["D"] = "每日签到奖励。",
					},
					[4] =
					{
						["T"] = "   4.",
						["D"] = "去活动中心参与活动，获得金币。",
					},
					[5] =
					{
						["T"] = "   5.",
						["D"] = "多玩牌局，提高技巧，赢得金币。",
					},
					[6] =
					{
						["T"] = "   6.",
						["D"] = "破产补助，等待一段时间获得。",
					},
				}
	},
	[2] =
	{
		["T"] = "Q: 我的游戏币为什么不见了？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "请在“我要提问”中及时提交丢失游戏币的时间和数量，我们会立刻进行核查处理。",
					},
				}
	},
	[3] =
	{
		["T"] = "Q: 为什么我的牌局结算不太对？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "请在“我要提问”中及时提交具体的牌局时间、输赢金币情形和手牌信息，若有截图请一并提交。我们会立刻进行核查处理。",
					},
				}
	},
	[4] =
	{
		["T"] = "Q: 为什么我支付成功了，金币却没有到账？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "金币的发放需要一定的时间，一般在五分钟之内，请耐心等待。若长时间未到账，请查看是否已经成功扣费，若已经扣费，请联系我们的客服。",
					},
				}
	},
	[5] =
	{
		["T"] = "Q: 为什么我无法进行支付？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "请检查下网络、是否有足够的额度进行充值，重新尝试下。若依旧无法充值，请在反馈中描述所遇到的情形。",
					},
				}
	},
	[6] =
	{
		["T"] = "Q: 为什么有时无法登录游戏、突然掉线、画面停滞或者频繁被托管？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "游戏运行需要稳定流畅的网络环境，上述情形可能为您当前网络不佳或者无网络。请先检查网络连接，清除游戏缓存，若依然存在请彻底关闭应用程序再重新启动，或者稍后再试。",
					},
				}
	},
	[7] =
	{
		["T"] = "Q: 为什么有时游戏会自动退出或者无法进入？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "如果您安装了流氓软件、网络不佳、终端内存不足等，可能会导致这些问题。请先检查网络，关闭后台的其他程序再重新登录；若问题依然存在，请及时反馈。",
					},
				}
	},
	[8] =
	{
		["T"] = "Q: 游戏币有什么用？可以兑换成现金和实物么？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "根据相关法规，游戏币仅为个人游戏用途，不具任何财产功能。游戏中禁止玩家间倒币、转让、赠送以及兑换实物。",
					},
				}
	},
	[9] =
	{
		["T"] = "Q: 每局和每日金币输赢是否有上限呢？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "每局输赢不超过1亿，每日不超过10亿。",
					},
				}
	},
	[10] =
	{
		["T"] = "Q: 游戏是否收入服务费？",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "游戏会根据不同场次，不同玩法收取不同的金币。",
					},
				}
	}
}
--基本玩法

BaseSkillConfig =
{
	[1] =
	{
		["T"] = "一、玩法简介",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "游戏采用四川地区流行的麻将打法，牌面只有万、条、筒三门，至少缺一门才可胡牌。游戏中不可以吃牌，最后四张自动胡牌,剩余最后一张牌时不可以杠牌（杠牌需要补摸牌，最后一张牌后无牌可摸）。目前游戏中有血战到底、换三（两）张、血流成河、好友对战、两房牌、单机以及比赛场玩法。",
					},
				}
    },
	[2] =
	{
		["T"] = "1.血战到底:",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "一家胡了并不结束这局，而是未胡的玩家继续打，直到有三家都胡或者余下的玩家摸完牌。这样先胡的不一定获利最多，点炮的也能翻身，提高了博弈性和趣味性。牌局结束，一并结算。",
					},
				}
    },
	[3] =
	{
		["T"] = "2.换三(两)张：",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "在摸上首牌后，自己拿出三（两）张牌，然后随机与其他人交换;"
					},

					[2] =
					{
						["T"] = "B: ",
						["D"] = "超时由系统代换;",
					},
					[3] =
					{
						["T"] = "C: ",
						["D"] = "少于三（两）张牌不能换;",
					},
					[4] =
					{
						["T"] = "D: ",
						["D"] = "换两张仅针对两房牌玩法。",
					},
				}
	},
	[4] =
	{
		["T"] = "3.血流成河：",
		["D"] = {

					[1] =
					{
						["T"] = "A: ",
						["D"] = "胡牌的人继续打牌摸牌，但不能换张，可以继续打牌，也会点炮，直至牌墙抓完为止。",
					},
					[2] =
					{
						["T"] = "B: ",
						["D"] = "胡牌之后可以补杠，可以直杠和暗杠。注意：如果杠牌会破坏现有牌型，改变胡牌牌张，则不允许杠牌。",
					},
					[3] =
					{
						["T"] = "C: ",
						["D"] = "血流成河没有“天胡”“地胡”番型。",
					},
					[4] =
					{
						["T"] = "D: ",
						["D"] = "当同时出现查花猪、查大叫时，查金币较多的一个。",
					},
				}
	},

	[5] =
	{
		["T"] = "4.好友对战：",
		["D"] = {
                    [1] =
					{
						["T"] = "A: ",
						["D"] = "玩家可以创建自己喜欢的玩法和底注的对战，并可以通过微信和QQ邀请好友加入游戏。",
					},
                    [2] =
					{
						["T"] = "B: ",
						["D"] = "好友对战玩法中没有金币流动，创建对战时仅房主需要消耗少量的金币。",
					},
                    [3] =
					{
						["T"] = "C: ",
						["D"] = "玩家也可以输入正确的房间号码来加入好友创建的对战。",
					},
					--"可以创建自己喜欢的底注和玩法的游戏房间，尽情享受与朋友的私密玩牌时间。",

				}
	},

	[6] =
	{
		["T"] = "5.两房牌：",
		["D"] = {
					[1] =
					{
						["T"] = "A: ",
						["D"] = "游戏中只发条子、筒子两种花色的牌；",
					},
					[2] =
					{
						["T"] = "B: ",
						["D"] = "各家起手摸10张牌；",
					},
					[3] =
					{
						["T"] = "C: ",
						["D"] = "两房牌没有“七对”、“龙七对”、“清七对”、“清龙七对”的番型。",
					},
				}
	},
	[7] =
	{
		["T"] = "6.单机玩法：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "单机场，顾名思义人机对战，玩家可以在网络不佳的情况时选择单机玩法，单机场的金币与联网游戏场不互通，会在每次重新进入时重置。",
					},
				}
	},

	[8] =
	{
		["T"] = "7.比赛场：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "玩家可以在比赛场内选择不同的比赛玩法，赢得比赛即可获得相应的奖励，具体玩法和奖励详见比赛场内游戏介绍。",
					},
				}
	},
	[9] =
	{
		["T"] = "二、术语解释",
		["D"] = {

					[1] =
					{
						["T"] = "1. 缺一门：",
						["D"] = "",
					},
					[2] =
					{
						["T"] = "",
						["D"] = "万筒条中缺少任意一门花色的牌。",
					},
				}
	},

	[10] =
	{
		["T"] = "2. 下叫：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "即听牌，差一张就可以胡牌。"
					},
				}
	},
	[11] =
	{
		["T"] = "3. 根：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "四张相同的牌不作杠，为一根。"
					},
				}
	},
	[12] =
	{
		["T"] = "4. 刮风：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "即明杠，有直杠和面下杠.其中直杠指的是手中有三张一样的牌，杠别人打出的第四张牌；面下杠指的是摸到碰牌的第四张牌后开杠。",
					},
				}
	},
	[13] =
	{
		["T"] = "5. 下雨：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "即暗杠，自己摸到四张一样的牌开杠。"
					},
				}
	},
	[14] =
	{
		["T"] = "6. 擦挂：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "玩家直杠时收取放杠者2倍金币，其余玩家1倍金币，即其余玩家遭了擦挂。"
					},
				}
	},
	[15] =
	{
		["T"] = "7. 抢杠胡：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "指一家面下杠时，恰有另一玩家抢胡这张牌。（直杠和暗杠不能被抢杠胡）"
					},
				}
	},
	[16] =
	{
		["T"] = "8. 自摸加底：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "玩家自摸时额外收取其他未胡玩家1倍底注金币，也称自摸加底。"
					},
				}
	},
	[17] =
	{
		["T"] = "9. 呼叫转移：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "即某玩家杠牌后打出的牌其他玩家可以胡，那么该玩家的刮风下雨所得则转移给胡牌玩家。"
					},
				}
	},
	[18] =
	{
		["T"] = "10. 查花猪：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "手上拿着3种花色牌的玩家称为花猪。流局时，花猪玩家要赔给非花猪并且未胡玩家16倍底注的金币。"
					},
				}
	},
	[19] =
	{
		["T"] = "11. 查大叫：",
		["D"] = {
					[1] =
					{
						["T"] = "",
						["D"] = "流局时，检查玩家是否下叫，没下叫的玩家（花猪除外）要赔给有叫的玩家最大的可能番（大叫）。"
					},
				}
	},
	--}
}
--番型计算
FanStyleCalcConfig =
{
	[1] =
	{
		["T"] = "一、血战的各类番型",
		["T1"]= "1番（x1）",
		["D"] = {
					[1] =
					{
						["T"] = "平胡：",
						["D"] = "即普通的四坎牌加一对将。",
						["F"] = {0x01,0x02,0x03,0x04,0x04,0x04,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x29},
					}
				}
	},
	[2] =
	{
		["T1"] = "2番(x2)",
		["D"]  = {
					[1] =
					{
						["T"] = "对对胡（大对子）：",
						["D"] = "即4副刻子（杠）加一对将。",
						["F"] = {0x01,0x01,0x01,0x05,0x05,0x05,0x12,0x12,0x12,0x16,0x16,0x16,0x19,0x19},
					}
				}
	},
	[3] =
	{
		["T1"] = "3番(x4)",
		["D"]  = {
					[1] =
					{
						["T"] = "清一色：",
						["D"] = "即胡牌时只有一种花色。",
						["F"] = {0x21,0x21,0x21,0x22,0x23,0x24,0x24,0x25,0x26,0x27,0x27,0x27,0x29,0x29},
					},
					[2] =
					{
						["T"] = "带幺九：",
						["D"] = "即每副顺子、刻子和将牌都含有一或九。",
						["F"] = {0x01,0x02,0x03,0x07,0x08,0x09,0x21,0x21,0x21,0x21,0x22,0x23,0x29,0x29},
					},
					[3] =
					{
						["T"] = "七对：",
						["D"] = "即胡牌时手牌全是两张一对的，没有碰或者杠过牌。",
						["F"] = {0x11,0x11,0x13,0x13,0x15,0x15,0x23,0x23,0x26,0x26,0x27,0x27,0x28,0x28},
					}
				}

	},
	[4] =
	{
		["T1"] = "4番(x8)",
		["D"] = {
					[1] =
					{
						["T"] = "清对：",
						["D"] = "即同一种花色的大对子。",
						["F"] = {0x11,0x11,0x11,0x14,0x14,0x14,0x15,0x15,0x15,0x17,0x17,0x17,0x19,0x19},
					},
					[2] =
					{
						["T"] = "将对：",
						["D"] = "即二、五、八的大对子。",
						["F"] = {0x02,0x02,0x02,0x05,0x05,0x05,0x22,0x22,0x22,0x25,0x25,0x25,0x28,0x28},
					}
				}

	},
	[5] =
	{
		["T1"] = "5番(x16)",
		["D"] = {
					[1] =
					{
						["T"] = "龙七对：",
						["D"] = "即在七对的基础上，有两对牌是四张一样的。",
					},
					[2] =
					{
						["T"] = "注意：",
						["D"] = "此四张牌不是杠的牌，不再计七对，同时减一根。",
						["F"] = {0x01,0x01,0x01,0x01,0x05,0x05,0x06,0x06,0x25,0x25,0x27,0x27,0x28,0x28},
					},
					[3] =
					{
						["T"] = "清七对：",
						["D"] = "即同一种花色的七对。",
						["F"] = {0x21,0x21,0x22,0x22,0x24,0x24,0x25,0x25,0x27,0x27,0x28,0x28,0x29,0x29},
					},
					[4] =
					{
						["T"] = "清幺九：",
						["D"] = "即同一种花色的带幺九。",
						["F"] = {0x21,0x21,0x21,0x22,0x22,0x22,0x23,0x23,0x23,0x27,0x28,0x29,0x29,0x29},
					}
				}
	},
	[6] =
	{
		["T1"] = "6番(x32)",
		["D"] = {
					[1] =
					{
						["T"] = "天胡：",
						["D"] = "即庄家刚摸好牌就自然成胡。",
					},
					[2] =
					{
						["T"] = "地胡：",
						["D"] = "胡庄家打出的第一张牌或闲家起手牌就下叫，并在第一轮摸牌，在胡牌之前没有任何碰、杠（含暗杠），否则不算。",
					},
					[3] =
					{
						["T"] = "清龙七对：",
						["D"] = "即同一种花色的青龙七对，算番时减去一番。",
					}

				}

	},
	[7] =
	{
		["T"] = "二、血流的番型",
		["D"] = {
					[1] =
					{
						["T"] = "基本番型：",
						["D"] = "平胡、对对胡、清一色、带幺九、七对、龙七对、清七对、清幺九。",
					},
					[2] =
					{
						["T"] = "额外番型：",
						["D"] = "自摸加底、杠、根。",
					},
					[3] =
					{
						["T"] = "",
						["D"] = "（注：杠和根参与胡牌牌型计算时，只按第一次胡牌的杠和根计算）",
					}

				}

	},
	[8] =
	{
		["T"] = "三、另加番",
		["D"] = {
					[1] =
					{
						["T"] = "1.",
						["D"] = "杠上花，加1番。（杠上花：杠牌，补牌自摸成胡）",
					},
					[2] =
					{
						["T"] = "2.",
						["D"] = "杠上炮，加1番。（杠上炮：玩家杠牌后打出的那张牌正是其他玩家所需的叫牌。即玩家杠牌，补杠后打出，让其他玩家给胡了）",
					},
					[3] =
					{
						["T"] = "3.",
						["D"] = "抢杠胡，加1番。（抢杠胡：在某个玩家进行面下杠时，恰有另一玩家抢胡这张牌）",
					},
					[4] =
					{
						["T"] = "4.",
						["D"] = "每有一根，加1番。",
					},
					[5] =
					{
						["T"] = "5.",
						["D"] = "每有一杠，加1番。",
					},
					[6] =
					{
						["T"] = "6.",
						["D"] = "海底捞月，加1番。（海底捞月：牌面最后一张麻将牌，起底（最后一张）即为海底捞月）",
					},
					[7] =
					{
						["T"] = "7.",
						["D"] = "金钩钓，加1番。（金钩钓：所有其余牌均已碰或者杠只留一张手牌的单吊）",
					}

				}

	},

	[9] =
	{
		["T"] = "四、计算",
		["D"] = {
					[1] =
					{
						["T"] = "1.",
						["D"] = "正常计算",
					},
					[2] =
					{
						["T"] = "   a）",
						["D"] = "番：用来算倍数，各个番数有对应的倍数。",
					},
					[3] =
					{
						["T"] = "   b）",
						["D"] = "倍数：用来算金币，倍数为2的“番数减1”次方。即1番对应1倍、2番对应2倍、3番对应4倍、4番对应8倍、5番对应16倍、6番对应32倍",
					},
					[4] =
					{
						["T"] = "   c）",
						["D"] = "底注：游戏房间设定的固定基础金币。",
					},
					[5] =
					{
						["T"] = "   d）",
						["D"] = "刮风：直杠，立刻收取放杠者2倍金币，其余玩家1倍金币；面下杠，立刻收其他未胡者1倍金币。",
					},
					[6] =
					{
						["T"] = "   e）",
						["D"] = "下雨：立刻收取其他未胡者2倍金币。",
					},
					[7] =
					{
						["T"] = "   f）",
						["D"] = "破产：牌局中对手若破产，系统则只扣除其所有金币，多出部分不予计算。",
					},
					[8] =
					{
						["T"] = "2.",
						["D"] = "正常胡牌（无逃跑、流局）",
					},
					[9] =
					{
						["T"] = "   a）",
						["D"] = "基本输（赢）金币，即底注X倍数+刮风下雨的金币。系统每局向每位玩家收取固定的服务费。",
					},
					[10] =
					{
						["T"] = "   b）",
						["D"] = "点炮，只有点炮者输金币，自摸胡，所有未胡者输金币。",
					},
					[11] =
					{
						["T"] = "   c）",
						["D"] = "一炮多响，按玩家之间各自一对一计算金币。",
					},
					[12] =
					{
						["T"] = "   d）",
						["D"] = "刮风下雨，按玩家之间各自一对一计算金币。",
					},
					[13] =
					{
						["T"] = "3.",
						["D"] = "流局",
					},
					[14] =
					{
						["T"] = "   a）",
						["D"] = "查花猪，花猪赔给非花猪玩家16倍底注",
					},
					[15] =
					{
						["T"] = "   b）",
						["D"] = "查大叫，没下叫的玩家（花猪除外）赔给叫的玩家最大的可能番。",
					},
					[16] =
					{
						["T"] = "   c）",
						["D"] = "没下叫的玩家刮风下雨所得无效，全部退还。",
					},
					[17] =
					{
						["T"] = "4.",
						["D"] = "逃跑处理",
					},
					[18] =
					{
						["T"] = "   a）",
						["D"] = "未胡牌玩家逃跑后由系统代打，并参与流局查花猪、查大叫。",
					},
					[19] =
					{
						["T"] = "   b）",
						["D"] = "流局时，没下叫玩家最后退还刮风下雨所得，已逃跑玩家部分归系统。",
					}

				}

	}
}
