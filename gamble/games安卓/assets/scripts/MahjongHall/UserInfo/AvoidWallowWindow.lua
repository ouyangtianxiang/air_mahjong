--[[
	className    	     :  AvoidWallowWindow
	Description  	     :  防沉迷界面.
	last-modified-date   :  Dec. 16 2013
	create-time 	   	 :  Nov. 6  2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
local avoidWallowLayout = require(ViewLuaPath.."avoidWallowLayout");
AvoidWallowWindow = class(SCWindow);

--[[
	function name	   : AvoidWallowWindow.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 outRef    -- 外部引用方法
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
AvoidWallowWindow.ctor = function(self,outRef)
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.layout = SceneLoader.load(avoidWallowLayout);
	self:addChild(self.layout);
	self:setWindowNode( self.layout );
--	self:setCoverTransparent();
	self:setCoverEnable(true);
	
	-- 弹窗落下
	self:showWnd();

	self.closeBtn = publ_getItemFromTree(self.layout, {"closeBtn"});
	self.closeBtn:setOnClick(self,function(self)
		self:hideWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		publ_getItemFromTree(self.layout, {"bg"}):setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
		publ_getItemFromTree(self.layout, {"frame","smile"}):setFile("Login/wdj/Hall/userinfo/content_bg.png");
	end

	self.m_input_realName = publ_getItemFromTree(self.layout, {"frame", "editBg1", "nameEdit"});
	self.m_input_identity = publ_getItemFromTree(self.layout, {"frame", "editBg2", "idEdit"});

	self.outRef = outRef;

	self.submit = publ_getItemFromTree(self.layout, {"confirmBtn"});
	self.submit:setOnClick(self,self.onSubmitClick);
end

--[[
	function name	   : AvoidWallowWindow.hide
	description  	   : 界面隐藏方法.
	param 	 	 	   : self
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
AvoidWallowWindow.hide = function ( self )
	-- self:setVisible(false);
	self:dtor();
end

--[[
	function name	   : AvoidWallowWindow.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
AvoidWallowWindow.dtor = function(self)
	self.outRef.m_avoidWallowWindow = nil;
	self:removeAllChildren();
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

--********************************************************按键监听**********************************************--
--[[
	function name	   : AvoidWallowWindow.onSubmitClick
	description  	   : 提交按键监听.
	param 	 	 	   : self
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
AvoidWallowWindow.onSubmitClick = function(self)
	local realName = self.m_input_realName:getText();
	local identity = self.m_input_identity:getText();
	local mark = self:judgeInputIllegal(realName,identity);
	--if mark then
	--	self:hideWnd();
	--end
end

--[[
	function name	   : AvoidWallowWindow.judgeInputIllegal
	description  	   : 真实姓名和身份证验证.
	param 	 	 	   : self
	last-modified-date : Dec. 16 2013
	create-time  	   : Nov. 6  2013
]]
AvoidWallowWindow.judgeInputIllegal = function (self,realName,identity)
	realName = publ_trim(realName);
	identity = publ_trim(identity);

	if realName == kNullStringStr or realName== nil then
		local str = PromptMessage.avoidNullNameMessage;
		Banner.getInstance():showMsg(str);
		return;
	end

	if identity == kNullStringStr or identity == nil then
		local str = PromptMessage.avoidNullIdentityMessage;
		Banner.getInstance():showMsg(str);
		return false;
	end

	if string.len(identity) ~= kNumFifteen and string.len(identity) ~= kNumEighteen then
		local str = PromptMessage.avoidIdentityLenError;
		Banner.getInstance():showMsg(str);
		return false;
	end

	if string.len(identity) == kNumFifteen and string.match(identity,CreatingViewUsingData.commonData.regularJudgeByIdentity) == nil then
		local str = PromptMessage.avoidIdentityNotNumber;
		Banner.getInstance():showMsg(str);
		return false;
	end

	if string.match(string.sub(identity,kNumOne,kNumSeventeen),CreatingViewUsingData.commonData.regularJudgeByIdentity)  == nil then
		local str = PromptMessage.avoidIdentityNotForRule;
		Banner.getInstance():showMsg(str);
		return false;
	end
	if string.len(identity) == kNumEighteen then
		local str=string.sub(identity,kNumSeven,kNumTen);
		if tonumber(str) < kFangchenmiYear or tonumber(str) > tonumber(os.date(CreatingViewUsingData.commonData.regularJudgeYear)) then
			local str= PromptMessage.avoidIdentityYearError;
			Banner.getInstance():showMsg(str);
			return false;
		end		
	end
	self:onAvoidWallowPHPRequest(realName,identity);

	return true;
end

--*************************************************************PHP 请求**************************************************--
--[[
	function name      : AvoidWallowWindow.onPhpMsgResponse
	description  	   : The method of sending PHP.
	param 	 	 	   : self
						 command     String  -- 命令字段
 	last-modified-date : Dec. 16 2013
	create-time		   : Nov. 6 2013
]]

AvoidWallowWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestsCallBackFuncMap[cmd] then 
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end
--发请求
--[[
	function name      : AvoidWallowWindow.onAvoidWallowPHPRequest
	description  	   : 发送防沉迷信息PHP.
	param 	 	 	   : self
						 realName 		String -- 真实姓名
						 identity 		String -- 身份证号码 
 	last-modified-date : Dec. 16 2013
	create-time		   : Nov. 6 2013
]]
AvoidWallowWindow.onAvoidWallowPHPRequest = function(self,realName,identity)
	local param_data = {};
	param_data.mid = PlayerManager:getInstance():myself().mid;
	param_data.name = GameString.convert2UTF8(realName);
	param_data.idcard = identity;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_AVOID_WALLOW, param_data);
end

--返回PHP请求
--[[
	function name      : AvoidWallowWindow.requestAvoidWallowCallBack
	description  	   : The method of getting PHP.返回好友实名验证是否成功
	param 	 	 	   : self
					     isSuccess   Boolean -- the request is whether or not successful.
						 data   	 Table   -- the request of php request.
 	last-modified-date : Dec. 16 2013
	create-time		   : Nov. 6 2013
]]

AvoidWallowWindow.requestAvoidWallowCallBack = function(self,isSuccess,data)
	--DebugLog("AvoidWallowWindow.requestAvoidWallowCallBack")
	if not data then
        return;
    end
    --DebugLog(tostring(isSuccess))
    --mahjongPrint(data)

	if not isSuccess then 
		local status = GetNumFromJsonTable(data,kStatus)
		local msg = GetStrFromJsonTable(data,kMsg)
		Banner.getInstance():showMsg(msg)
		return
	end 

	if isSuccess then 
		local status = GetNumFromJsonTable(data,kStatus);
		local msg = GetStrFromJsonTable(data,kMsg);
		local isAdult = kNumMinusTwo;
		if kNumOne == status  then
			isAdult=GetNumFromJsonTable(data,kIsAdult);
			GameConstant.isAdult = isAdult;
			g_DiskDataMgr:setAppData(kMid, PlayerManager.getInstance():myself().mid)
			self.outRef.realNameBtn:setVisible(false);
			self.outRef.realNameImage:setVisible(true);

		elseif kNumMinusOne == status then         --请求失败	(一般是格式错误)
			isAdult = kNumMinusOne;		
		end

		g_DiskDataMgr:setAppData(kIsAdultVerify,isAdult)

		Banner.getInstance():showMsg(msg);
		self:dtor();

	end
end

--public parameter which to regist the event that friend PHP request needs.
AvoidWallowWindow.httpRequestsCallBackFuncMap ={
	[PHP_CMD_REQUEST_AVOID_WALLOW] = AvoidWallowWindow.requestAvoidWallowCallBack,
}

