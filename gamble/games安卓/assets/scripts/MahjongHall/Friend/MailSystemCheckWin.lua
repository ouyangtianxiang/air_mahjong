local mailSystemCheckWin = require(ViewLuaPath.."mailSystemCheckWin");

MailSystemCheckWin = class(SCWindow);


MailSystemCheckWin.ctor = function( self,data,hasReward,needUpdateMailWin)----needUpdateMailWin已读  状态改变了,需通知消息列表需重新排序
	
	self.uiBg = SceneLoader.load(mailSystemCheckWin);
	self:addChild(self.uiBg);

	--self.window = SceneLoader.load(bankruptcyWnd);
	--self:addChild(self.windo
	--self.m_time = time; -- 破产需要显示的时间
	--.title,self.data.content
	self.isNeedNoticeUpdateMailWind = needUpdateMailWin


	self:setWindowNode( publ_getItemFromTree(self.uiBg,{"bg"} ) );

	publ_getItemFromTree(self.uiBg, {"bg","title"}):setText(stringFormatWithString(data.title ,32,true))

	self.descText = new(TextView, "", 700, 270, kAlignTopLeft, nil, 30, 0x4b, 0x2b, 0x1c);
	publ_getItemFromTree(self.uiBg, {"bg","frame","view2"}):addChild(self.descText)
	self.descText:setText(data.content)

	publ_getItemFromTree(self.uiBg, {"bg","close_btn"}):setOnClick(self,self.closeCallback)

	self.okBtn = publ_getItemFromTree(self.uiBg, {"bg","Button2"})
	self.okBtnText = publ_getItemFromTree(self.uiBg, {"bg","Button2","Text2"})
	

	self.hasReward = hasReward
	self.canGet = (data.award == 0)
	
	if hasReward then 
		self.okBtn:setOnClick(self,self.clickGetRewardBtn)
	else
		self.okBtn:setOnClick(self,self.closeCallback)	
	end 
	self.id = data.id

	self:setBtnState(self.hasReward,self.canGet)
	self.okBtn:setType(Button.Gray_Type)

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self:addToRoot();
	self:showWnd();
end

MailSystemCheckWin.setBtnState = function ( self, hasReward, canGet )
	if hasReward then --有奖消息
		if canGet then --可领
			self.okBtn:setIsGray(false)
			self.okBtn:setPickable(true)
			self.okBtnText:setText("领取") 
		else 
			self.okBtn:setIsGray(true)
			self.okBtn:setPickable(false)
			self.okBtnText:setText("已领") 
		end 
	else --无奖消息
		self.okBtn:setIsGray(false)
		self.okBtn:setPickable(true)
		self.okBtnText:setText("知道了") 
	end 
end
MailSystemCheckWin.clickGetRewardBtn = function ( self )
	-- body
	self:getReward()
end


MailSystemCheckWin.closeCallback = function ( self )
	if self.isNeedNoticeUpdateMailWind then
		EventDispatcher.getInstance():dispatch(MailWindow.updateSystemListView);
	end 
	self:hideWnd();
end

MailSystemCheckWin.setCheckCallback = function ( self, obj, func )
	self.rewardObj = obj
	self.rewardFunc = func
end

MailSystemCheckWin.getReward  = function( self, data )
	local param = {};
	param.mid 	    = PlayerManager.getInstance():myself().mid;
	param.version   = GameConstant.Version;
	param.api 		= GameConstant.api
	param.id        = self.id
	Loading.showLoadingAnim("正在努力为您加载...");
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_SYSTEM_REWARD, param);
	
end






MailSystemCheckWin.onPhpMsgResponse = function (self, data,command, isSuccess , jsonData,...)
	Loading.hideLoadingAnim();
	if not isSuccess or not data then
        return;
    end
	if PHP_CMD_REQUEST_SYSTEM_REWARD == command then
		local status = tonumber(data.status) or 0;
		if status == 1 then
			if self.rewardObj and self.rewardFunc then 
				self.rewardFunc(self.rewardObj,self.id)
			end 
			--self:setBtnState(true,false)
			showGoldDropAnimation()
			self.isNeedNoticeUpdateMailWind = true
			self:closeCallback()
			
		else --领取失败
		end 
		Banner.getInstance():showMsg(tostring(data.msg));
	end
end





MailSystemCheckWin.dtor = function( self )
    self.data = nil
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end


