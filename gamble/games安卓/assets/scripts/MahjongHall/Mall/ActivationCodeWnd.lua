local activationCodeWnd = require(ViewLuaPath.."activationCodeWnd");

ActivationCodeWnd = class(SCWindow);

ActivationCodeWnd.ctor = function( self, parent )
	self.m_layout = SceneLoader.load( activationCodeWnd );
	self:addChild( self.m_layout );
	self.m_phpEvent = EventDispatcher.getInstance():getUserEvent(); -- php注册回调事件
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end
	self:initView();
end

ActivationCodeWnd.dtor = function( self )
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

ActivationCodeWnd.requestActivationCallBack = function( self, isSuccess, data )
	if isSuccess and data then
		local status = data.status
		local msg = data.msg

		if 1 == status then
			AnimationAwardTips.play(msg);
			PlayerManager.getInstance():myself():addMoney(tonumber(data.data.money) or 0);
			PlayerManager.getInstance():myself():addCoupons(tonumber(data.data.coupons) or 0);

			local laba = nil 
			if data.data and data.data.card and data.data.card['22'] then 
				laba = data.data.card['22']
			end 
			if laba then
				GameConstant.changeNickTimes.propnum = GameConstant.changeNickTimes.propnum + tonumber(laba);
			end
			-- local circletype = data.data.card["5"];
			-- if circletype then
			-- 	PlayerManager.getInstance():myself().circletype = 1;
			-- end
			showGoldDropAnimation();
		else
			self:showTips( msg );
		end
	end
end

ActivationCodeWnd.initView = function( self )
	self.m_window = publ_getItemFromTree(self.m_layout, {"img_bg"});
	self:setWindowNode( self.m_window );

	self.m_activeCodeEdit = publ_getItemFromTree(self.m_layout, {"img_bg","view_content" ,"img_edit_text_bg","edit_text_active_code"});
	self.m_errTipsText    = publ_getItemFromTree(self.m_layout, {"img_bg","view_content", "text_tips"});
	self.m_submitBtn      = publ_getItemFromTree(self.m_layout, {"img_bg","btn_submit"});
	self.m_closeBtn       = publ_getItemFromTree(self.m_layout, {"img_bg","btn_close"});

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.m_closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.m_window:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
		self.m_closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
	end

	self.m_activeCodeEdit:setOnTextChange(self, function ( self )
		self.m_activeCodeEdit:setText(stringFormatWithString( self.m_activeCodeEdit:getText(), GameConstant.chatMaxCharNum, true), nil, nil, 250, 240, 200 );
	end);
	self.m_activeCodeEdit:setHintText("请输入领取奖励的激活码", 255, 255, 255);

	self.m_errTipsText:setVisible( false );
	self.m_submitBtn:setOnClick( self, function( self )
		self:onSubmitClick();
	end);

	self.m_closeBtn:setOnClick( self, function( self )
		self:hideWnd();
	end);

	self:showWnd();
end

ActivationCodeWnd.onSubmitClick = function( self )
	local activationCode = self.m_activeCodeEdit:getText();
	if activationCode == kNullStringStr then
		-- Banner.getInstance():showMsg( "请输入激活码" );
		self:showTips( "请输入激活码" );
		return;
	end
	self:showTips( "", false );
	self:activate( activationCode );
end

ActivationCodeWnd.showTips = function( self, tips, notShow )
	if not tips then
		return;
	end

	if not self.m_textTips then
		self.m_textTips = publ_getItemFromTree(self.m_layout,{"img_bg","view_content","text_tips"});
	end
	self.m_textTips:setVisible( not notShow );

	if notShow then
		return;		
	end
	
	self.m_textTips:setText( tips );
end

ActivationCodeWnd.activate = function( self, activationCode )
	Loading.showLoadingAnim("兑换中...");
	local param = {};
	param.activation = activationCode;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_ACTIVATION, param);
end


ActivationCodeWnd.httpRequestMap = {
    [PHP_CMD_REQUEST_ACTIVATION] = ActivationCodeWnd.requestActivationCallBack,
};


ActivationCodeWnd.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	Loading.hideLoadingAnim();
	if self.httpRequestMap[cmd] then 
		DebugLog("ActivationCodeWnd deal http cmd "..cmd);
		self.httpRequestMap[cmd](self,isSuccess,param,...)
	end
end