-- 设置弹窗
local settingPopWindow = require(ViewLuaPath.."settingPopWindow");
local settingContent = require(ViewLuaPath.."settingContent");
--local fetionSettingContent = require(ViewLuaPath.."fetionSettingContent");
local settingCustom = require(ViewLuaPath.."settingCustom");
require("MahjongPlatform/Platform/TrunkPlatform");
--require("MahjongLogin/SelectDomainView");
--require("MahjongLogin/LoginMethod/CellphoneLogin")
require("MahjongSocket/NetConfig")
SettingWindow = class(SCWindow);
SettingWindow.subTitleX = 20;
SettingWindow.descX = 20;
SettingWindow.buttonX = 384;
SettingWindow.splitX = 0;
SettingWindow.titleH = 30;
SettingWindow.descH = 60;
SettingWindow.sliderX = 150;
-- 按键动作
SettingWindow.btnAction_changeAcount 	= 1; -- 切换账号
SettingWindow.btnAction_clearBuffer 	= 2; -- 清除缓存
SettingWindow.btnAction_teachHelp 		= 3; -- 新手教程
SettingWindow.btnAction_feedback 		= 4; -- 反馈
SettingWindow.btnAction_BindBYPassCard  = 5; -- 绑定博雅通行证
SettingWindow.btnAction_userRule 		= 6; -- 用户条款
SettingWindow.btnAction_serverRule 		= 7; -- 服务条款
SettingWindow.btnAction_download 		= 8; -- 资源下载
SettingWindow.btnAction_socketType 		= 9; -- 切换PHP服务器
SettingWindow.btnAction_update       	= 10; -- 更新

kNormalServer 	= 1;
kDevServer 	= 2;
kTestServer 	= 3;
kCustomPersonalServer = 4;

SettingWindow.ctor = function ( self , delegate)
	self.delegate = delegate;
	--------------------------------------------------------------
	--加载背景
	self.window = SceneLoader.load(settingPopWindow);
	self:addChild(self.window);
--	self.parentNode:addChild(self)

	self.window_tmp = publ_getItemFromTree(self.window, {"img_win_bg"});
	self:setWindowNode( self.window_tmp );
	self:setAutoRemove( false );

	--加载内容
	local srcollViewInfo = publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg","sv_info"});
	--设置滚动条
	srcollViewInfo:setScrollBarWidth(5);

	--引擎的BUG，必须重新再setSize一下
	local srcoll_w , srcoll_h = srcollViewInfo:getSize();
	DebugLog("srcoll_h : "..srcoll_h);
	srcollViewInfo:setSize(srcoll_w , srcoll_h);

	local w , h = 0 , 0;

	--测试
	--服务器切换
	if 1 == DEBUGMODE then
		self.debug = SceneLoader.load(settingCustom);
		srcollViewInfo:addChild(self.debug);
		w, h = self.debug:getSize();
		DebugLog("h : "..h);
		-- srcollViewInfo:addChild(self.debug);
		-- self.content:setPos(0, h);

		self.socketType = NetConfig.getInstance():getCurSocketType()

		self.btn_socket_1 = publ_getItemFromTree(self.debug,{"view_setting","view_debug","btn_change_server_1"});
		self.btn_socket_2 = publ_getItemFromTree(self.debug,{"view_setting","view_debug","btn_change_server_2"});
		self.btn_socket_3 = publ_getItemFromTree(self.debug,{"view_setting","view_debug","btn_change_server_3"});
		self.btn_socket_4 = publ_getItemFromTree(self.debug,{"view_setting","view_debug","btn_change_server_4"});

		self.btn_socket_1:setOnClick(self, function ( self )
			self:onClick(SettingWindow.btnAction_socketType , kNormalServer);
		end);
		self.btn_socket_2:setOnClick(self, function ( self )
			self:onClick(SettingWindow.btnAction_socketType , kDevServer);
		end);
		self.btn_socket_3:setOnClick(self, function ( self )
			self:onClick(SettingWindow.btnAction_socketType , kTestServer);
		end);
		self.btn_socket_4:setOnClick(self, function ( self )
			self:onClick(SettingWindow.btnAction_socketType , kCustomPersonalServer);
		end);
		self:setSocketTypeStatu();
	end

	--加载内容
	local settingName = GameConstant.platformType == PlatformConfig.platformFetion and fetionSettingContent or settingContent;
	if GameConstant.platformType == PlatformConfig.platformDingkai then
		settingName = settingContent_dk
	end
	self.content = SceneLoader.load(settingName);
	self.content:setPos(0 , h);
	srcollViewInfo:addChild(self.content);
	-- self.content:setPos(0 , h);


	--设置音效皮肤
	self.sliderEffect = publ_getItemFromTree(self.content,{"view_setting","view_sound","view_effect", "view_slider", "sld_effect"});
	self.sliderEffect:setImages("Hall/setting/progress_bar_bg.png", "Hall/setting/progress_bar.png", "Hall/setting/slider.png");

	self.sliderSound = publ_getItemFromTree(self.content,{"view_setting","view_sound","view_volume", "view_slider", "sld_volume"});
	self.sliderSound:setImages("Hall/setting/progress_bar_bg.png", "Hall/setting/progress_bar.png", "Hall/setting/slider.png");

	if GameConstant.platformType == PlatformConfig.platformWDJ or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then
		self.sliderEffect:setImages("Login/wdj/setting/progress_bar_bg.png","Login/wdj/setting/progress_bar.png","Hall/setting/slider.png");
		self.sliderSound:setImages("Login/wdj/setting/progress_bar_bg.png","Login/wdj/setting/progress_bar.png","Hall/setting/slider.png");
	end

	--设置事件

	--1.声音
	self.sliderEffect:setOnChange(self, SettingWindow.voiceChange);
	self.sliderSound:setOnChange(self, SettingWindow.musicChange);

	publ_getItemFromTree(self.content,{"view_setting","view_sound","view_effect", "btn_mute"}):setOnClick(self, function ( self )
		self:voiceChange(0);
		self.sliderEffect:setProgress(0);
	end);

	publ_getItemFromTree(self.content,{"view_setting","view_sound","view_effect", "btn_max_volume"}):setOnClick(self, function ( self )
		self:voiceChange(1);
		self.sliderEffect:setProgress(1);
	end);


	publ_getItemFromTree(self.content,{"view_setting","view_sound","view_volume", "btn_mute"}):setOnClick(self, function ( self )
		self:musicChange(0);
		self.sliderSound:setProgress(0);
	end);
	publ_getItemFromTree(self.content,{"view_setting","view_sound","view_volume", "btn_max_volume"}):setOnClick(self, function ( self )
		self:musicChange(1);
		self.sliderSound:setProgress(1);
	end);

	--设置帐号
	publ_getItemFromTree(self.content,{"view_setting","view_count","text_count"}):setText("");

    --如果是起凡，隐藏切换按钮
  --[[  if GameConstant.platformType == PlatformConfig.platformDingkai then
        publ_getItemFromTree(self.content,{"view_setting","view_count","btn_change_count"}):setVisible(false);
    end
]]--
	--切换账号
	local changeAccountBtn = publ_getItemFromTree(self.content,{"view_setting","view_count","btn_change_count"})
	if GameConstant.check_changeAccount ~= nil then --后台控制屏蔽更新按钮或者审核状态
		changeAccountBtn:setVisible(false)
	end
	changeAccountBtn:setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_changeAcount);
	end);

if 1 == DEBUGMODE and GameConstant.iosDeviceType>0 then
	local iosTestbutton = UICreator.createBtn( "Commonx/green_small_wide_btn.png");
	iosTestbutton:setSize(changeAccountBtn:getSize());
	local x,y = changeAccountBtn:getPos();
	local wid = changeAccountBtn:getSize();
	iosTestbutton:setPos(x + wid,y);
	iosTestbutton:setAlign(kAlignRight);
	iosTestbutton:setOnClick(self,function (self)
		native_to_java("iosShowDownloadPacketView")
	end)
	changeAccountBtn:getParent():addChild(iosTestbutton);

	local upbtnText = new( Text, "更新测试包", 0, 0, kAlignCenter, nil, 34, 0xff, 0xff, 0xff);
	upbtnText:setPos(0,10)
	upbtnText:setAlign(kAlignTop)
	--upbtnText:setAlign(kAlignCenter)
	iosTestbutton:addChild(upbtnText);
end


	--清除缓存
	publ_getItemFromTree(self.content,{"view_setting","view_clean_cache","btn_clean_cache"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_clearBuffer);
	end);

	--新手教程
	publ_getItemFromTree(self.content,{"view_setting","view_teach","btn_teach"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_teachHelp);
	end);

	--反馈
	publ_getItemFromTree(self.content,{"view_setting","view_feedback","btn_feedback"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_feedback);
	end);

	--更新
	local updateBtn = publ_getItemFromTree(self.content,{"view_setting","view_update", "btn_update"})
	if GameConstant.check_updateVersion ~= nil
		or GameConstant.checkType == kCheckStatusOpen then --后台控制屏蔽更新按钮或者审核状态
		updateBtn:setVisible(false)
	end
	publ_getItemFromTree(self.content,{"view_setting","view_update","btn_update"}):setOnClick(self , function ( self )
		self:onClick(SettingWindow.btnAction_update);
	end);
	publ_getItemFromTree(self.content,{"view_setting","view_update","btn_update","activityNum"}):setVisible(GlobalDataManager.getInstance():canGetUpdateRewardOrHasUpdate());

	--绑定 最新修改规则为，只要没绑定过手机帐号的，绑定按钮显示，点击进入手机帐号登录界面
    local btnBind = publ_getItemFromTree(self.content,{"view_setting","view_bind","btn_bind"});
    btnBind:setVisible(not GlobalDataManager.getInstance():getIsCellAcccountBind());
    btnBind:setOnClick(self, function ( self )
            --PlatformFactory.curPlatform:login(PlatformConfig.CellphoneLogin);
            require("MahjongLogin/LoginMethod/CellphoneLogin")
            CellphoneLoginWindow:showViewBind();
            self:hide();
        end);
    --设置绑定提示显示
    publ_getItemFromTree(btnBind, {"tip"}):
                        setVisible(not GlobalDataManager.getInstance():getIsCellAcccountBind());
--	if GameConstant.platformType ~= PlatformConfig.platformFetion then
--        btnBind:setOnClick(self, function ( self )
--                    if GameConstant.platformType == PlatformConfig.platformWDJ or
--                    PlatformConfig.platformWDJNet == GameConstant.platformType then
--                        PlatformFactory.curPlatform:login(PlatformConfig.WandouLogin);
--                        -- self:onCloseBtnClick();
--                        self:hide();
--                    else
--                        self:onClick(SettingWindow.btnAction_changeAcount);
--                    end
--                end);
--	end


	--喇叭消息设置
	btnText = publ_getItemFromTree(self.content,{"view_setting","view_display","btn_display","Text1"})
	GameConstant.isDisplayBroadcast = g_DiskDataMgr:getAppData("displayBroadcastMessage", 1);
	if GameConstant.isDisplayBroadcast == 1 then------------------当前是显示状态
		btnText:setText("隐   藏");
	else
		btnText:setText("显   示");
	end
	publ_getItemFromTree(self.content,{"view_setting","view_display","btn_display"}):setOnClick(self, function ( self )
		if GameConstant.isDisplayBroadcast == 0 then
			GameConstant.isDisplayBroadcast = 1;
			btnText:setText("隐   藏");
		else
			GameConstant.isDisplayBroadcast = 0;
			btnText:setText("显   示");
		end
		g_DiskDataMgr:setAppData("displayBroadcastMessage",GameConstant.isDisplayBroadcast);
	end);

	--用户条款
	publ_getItemFromTree(self.content,{"view_setting","view_user_rule","btn_user_rule"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_userRule);
	end);

	--服务条款
	publ_getItemFromTree(self.content,{"view_setting","view_server_rule","btn_server_rule"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_serverRule);
	end);
	--资源下载
	publ_getItemFromTree(self.content,{"view_setting","view_res_download","btn_res_download"}):setOnClick(self, function ( self )
		self:onClick(SettingWindow.btnAction_download);
	end);

	if GameConstant.iosDeviceType>0 then
			local view_res_download = publ_getItemFromTree(self.content,{"view_setting","view_res_download"})
			view_res_download:setVisible(false);
			if GameConstant.iosPingBiFee then
				local view_update = publ_getItemFromTree(self.content,{"view_setting","view_update"})
				view_update:setVisible(false);
			end
		end

	--动画开关
	local animBtn     = publ_getItemFromTree(self.content,{"view_setting","view_anim","btn_display"})
	local animBtnText = publ_getItemFromTree(animBtn,{"Text1"})
	if GameConstant.switchAnimIsOpen == 1 then------------------当前是显示状态
		animBtnText:setText("关   闭");
	else
		animBtnText:setText("开   启");
	end
	animBtn:setOnClick(self,function ( self )
		if GameConstant.switchAnimIsOpen == 0 then---未开启
			GameConstant.switchAnimIsOpen = 1;
			animBtnText:setText("关   闭");
		else
			GameConstant.switchAnimIsOpen = 0;
			animBtnText:setText("开   启");
		end

		g_DiskDataMgr:setAppData("hallAnimIsOpen",GameConstant.switchAnimIsOpen);
	end)


	--禁止窗外关闭
	self.window:setEventTouch(self, function ( self )
		-- body
	end);
	--设置关闭事件
	publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setType(Button.Gray_Type)
	publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setOnClick(self, function ( self )
		self:hideWnd();

	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
		PlatformConfig.platformWDJNet == GameConstant.platformType then
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setFile("Login/wdj/Hall/Commonx/close_btn.png");
		publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}).disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.window_tmp:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
	end

	if not PlatformFactory.curPlatform:isCancelBindBtn() then
		btnBind:setVisible(false);
	end

	if PlatformFactory.curPlatform:hasOnlyGuestLogin() then
		publ_getItemFromTree(self.content,{"view_setting","view_count","btn_change_count","Text1"}):setText("重新登录");
	end
end


SettingWindow.setSocketTypeStatu = function ( self, destType )
	local src = destType or self.socketType

	self.btn_socket_1:setEnable(true);
	self.btn_socket_2:setEnable(true);
	self.btn_socket_3:setEnable(true);
	self.btn_socket_4:setEnable(true);
	if kDevServer == src then
		self.btn_socket_2:setEnable(false);
	elseif kTestServer == src then
		self.btn_socket_3:setEnable(false);
	elseif kCustomPersonalServer == src then
		self.btn_socket_4:setEnable(false);
	else
		self.btn_socket_1:setEnable(false);
	end
end

SettingWindow.hide = function ( self )
	-- 保存一次音乐、音效值
	g_DiskDataMgr:setAppData('voice',self.voice)
	g_DiskDataMgr:setAppData('music',self.music)
    self:hideWnd();
end

SettingWindow.show = function ( self )
	if 1 == DEBUGMODE then
		self.socketType = NetConfig.getInstance():getCurSocketType()
		self:setSocketTypeStatu();
	end

	--设置帐号
	local loginType = GameConstant.lastLoginType;

	local str = "";
	if PlatformFactory.curPlatform and loginType then

		local loginCls = PlatformFactory.curPlatform:getLoginUtl(loginType);
		if loginCls then
			str = loginCls:getLoginUserName();
		end
	end

	if(PlayerManager.getInstance():myself().nickName) and PlayerManager.getInstance():myself().nickName ~= "" then
		str = GameString.convert2Platform(str)..GameString.convert2Platform((PlayerManager.getInstance():myself().nickName) or "");
	else
		str = "未登录";
	end

	publ_getItemFromTree(self.content,{"view_setting","view_count","text_count"}):setText(str);


	publ_getItemFromTree(self.content,{"view_setting","view_update","btn_update","activityNum"}):setVisible(GlobalDataManager.getInstance():canGetUpdateRewardOrHasUpdate());

	-- 设置当前音效、音乐音量
	self.voice = g_DiskDataMgr:getAppData('voice',0.5)
	self.music = g_DiskDataMgr:getAppData('music',0.5)
	self.sliderEffect:setProgress(self.voice);
	self.sliderSound:setProgress(self.music);

	self:showWnd();
end

-- 设置切换服务器的名字
SettingWindow.setChangeSocketName = function (self , socketType)
	self.socketType = socketType;
	g_DiskDataMgr:setAppData(kHallConfigDictKey_Value.HallConfigTime, 1)--重新拉大厅配置
	self:setSocketTypeStatu(socketType);
end

SettingWindow.action_change_account = function (self)
		umengStatics_lua(Umeng_SettingChangeLogin);
        new_pop_wnd_mgr.get_instance():set_back_to_hall_actively( false );
		if 1 == DEBUGMODE then
			if self.changeToSocketType and self.socketType ~= self.changeToSocketType then
				self:setChangeSocketName(self.changeToSocketType);
				self.delegate:clickChangeSocketType(self.changeToSocketType);
			end
		end
		DebugLog("SettingWindow.delegate.clickChangeLoginMethod")
		SocketManager.getInstance():syncClose(); -- 关闭socket
		self.delegate:clickChangeLoginMethod();
		BroadcastMsgManager.getInstance().m_queueForWin = {};
        GlobalDataManager.getInstance():reset_record_info();
end

-- 在内部分发
SettingWindow.onClick = function ( self, actionType , socketType )
	if not self.delegate then
		return;
	end
	DebugLog("SettingWindow.onClick")
	if SettingWindow.btnAction_socketType == actionType then  -- 切换服务器类型
		self.changeToSocketType = socketType
		--self.socketType = socketType;
		self:setSocketTypeStatu( self.changeToSocketType );
		DebugLog("SettingWindow.setSocketTypeStatu")
	elseif SettingWindow.btnAction_changeAcount == actionType then -- 切换账号
        self:action_change_account();
	elseif SettingWindow.btnAction_clearBuffer == actionType then -- 清除缓存
		umengStatics_lua(Umeng_SettingClear);
		self.delegate:clickClearBuffer();
		BroadcastMsgManager.getInstance().m_queueForWin = {};
	elseif SettingWindow.btnAction_teachHelp == actionType then -- 新手教程
		umengStatics_lua(Umeng_SettingTeach);
		self.delegate:clickTeachHelp();
	elseif SettingWindow.btnAction_feedback == actionType then -- 反馈
		umengStatics_lua(Umeng_SettingFeed);
		self.delegate:clickFeedBackAndHelp();
		self:hide()
	elseif SettingWindow.btnAction_BindBYPassCard == actionType then -- 博雅通行证
		umengStatics_lua(Umeng_SettingBinding);
		self.delegate:OnBoyaaLoginClick();
		self:hide();
	elseif SettingWindow.btnAction_userRule == actionType then -- 用户条款
		umengStatics_lua(Umeng_SettingUserRule);
		self.delegate:clickUsersTerms();
	elseif SettingWindow.btnAction_serverRule == actionType then -- 服务条款
		umengStatics_lua(Umeng_SettingServiceRule);
		self.delegate:clickServiceTerms();
	elseif SettingWindow.btnAction_download == actionType then  -- 下载表情
		umengStatics_lua(Umeng_SettingResDownload);
		GlobalDataManager.isActivityDownload = true;
		self.delegate:clickDownloadResoures();
	elseif SettingWindow.btnAction_update == actionType then    -- 更新
		umengStatics_lua(Umeng_SettingUpdate);
		self.delegate:OnUpdateClick();
		self:hide();
	end
end


SettingWindow.voiceChange = function(self,pos)
	umengStatics_lua(Umeng_SettingSound);
   	self.voice = pos;
   	GameEffect.getInstance():setVolume(pos);
end

SettingWindow.musicChange = function(self,pos)
	umengStatics_lua(Umeng_SettingMusic);
   	self.music = pos;
   	GameMusic.getInstance():setVolume(pos);
end

function SettingWindow.onWindowHide( self )
	self.super.onWindowHide(self);
	--new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.windows.SettingWindow);
end

SettingWindow.dtor = function ( self )
	self:hide();
	self:removeAllChildren();
end
