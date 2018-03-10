-- 
-- 
-- 
local changeNicknameWnd = require(ViewLuaPath.."changeNicknameWnd");

ChangeNicknameWnd = class(SCWindow);

--更新剩余次数事件
ChangeNicknameWnd.updateLeftTimesEvent = EventDispatcher.getInstance():getUserEvent();

function ChangeNicknameWnd:ctor( parent, sex, vipModTimes, cardsNum, vipLevel )
	self.parent = parent;
	self.sex = sex or "";
	self.vipModTimes = vipModTimes or 0;
	self.cardsNum = cardsNum or 0;
	self.vipLevel = vipLevel;

	self.layout = SceneLoader.load( changeNicknameWnd );
	self:addChild( self.layout );
	self:initView();

	if self.parent then
		self.parent:addChild( self );
	else
		self:addToRoot();
	end


	EventDispatcher.getInstance():register( ChangeNicknameWnd.updateLeftTimesEvent, self, self.onChangeLeftTimes );
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

function ChangeNicknameWnd:dtor()
	EventDispatcher.getInstance():unregister( ChangeNicknameWnd.updateLeftTimesEvent, self, self.onChangeLeftTimes );
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

function ChangeNicknameWnd:onChangeLeftTimes()
	self:updateLeftTimes( GameConstant.changeNickTimes.vipTimes, GameConstant.changeNickTimes.cardsNum );
end



ChangeNicknameWnd.onPhpMsgResponse = function ( self, param, cmd, isSuccess, jsonData )
	if cmd == PHP_CMD_REQUSET_CHANGE_NICK_NAME  then 
		self:requestChangeNicknameCallback( isSuccess, param, jsonData );
	end
end 

function ChangeNicknameWnd:requestChangeNicknameCallback( isSuccess, data, jsonData )
	DebugLog( "ChangeNicknameWnd:requestChangeNicknameCallback isSuccess=" .. tostring(isSuccess) );
	if not data then
		return;
	end

	local flag = GetBooleanFromJsonTable(data, "flag", false);
	local msg = GetStrFromJsonTable(data, "msg");
		

	if flag == true then
		msg = msg or "修改数据成功";
		Banner.getInstance():showMsg(msg);
		updateChangeNicknameTimes( data );
		local mnick = data.changeInfo.mnick and data.changeInfo.mnick or "";

		if self.okFunc and self.okObj then
			self.okFunc( self.okObj, mnick );
		end
		self:hideWnd();
	else 
    	msg = msg or "修改昵称失败";
    	Banner.getInstance():showMsg(msg);
	end
end

function ChangeNicknameWnd:initView()
	self.window = publ_getItemFromTree( self.layout, {"img_bg"} );
	self:setWindowNode( self.window );

	self.btnClose = publ_getItemFromTree( self.layout, {"img_bg", "btn_close"} );
	self.btnOK = publ_getItemFromTree( self.layout, {"img_bg", "btn_ok"} );
	self.textLeftTimes = publ_getItemFromTree( self.layout, {"img_bg", "text_left_change_tips"} );
	self.textNickname = publ_getItemFromTree( self.layout, {"img_bg", "img_nickname_bg", "text_nickname" } );

	self.textNickname:setText( self.nickname );
	self.textNickname:setOnTextChange(self, self.onTextChange);
	self.textNickname:setHintText("请输入昵称", 0xad, 0x9e, 0x95);
	self:updateLeftTimes( self.vipModTimes, self.cardsNum );
	self.btnClose:setOnClick( self, function( self )
		self:hideWnd();
	end);
	self.btnOK:setOnClick( self, function( self )
		if self.textNickname:getText() ~= self.nickname then
			local player = PlayerManager.getInstance():myself();
			if self.leftTimes and self.leftTimes > 0 or player.vipLevel >= 6 then
				self:requestChangeNickname( self.textNickname:getText() );
			else
				DebugLog( "ChangeNicknameWnd:initView" );
				require("MahjongCommon/ExchangePopu");
				self.exchangePopu = new(ExchangePopu, ItemManager.CHANGE_NICK_CID, self.parent );
				self.exchangePopu:setOnWindowHideListener( self, function( self )
					self.exchangePopu = nil;
				end);
				self.exchangePopu:showWnd();
			end
		else
			self:hideWnd();
		end
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
        PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
		self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
		self.window:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
	end
end

function ChangeNicknameWnd:updateLeftTimes( vipModTimes, cardsNum )
	self.leftTimes = self:getLfetTimes( vipModTimes, cardsNum );
	self.textLeftTimes:setText( self:getLeftModTimeText( self.leftTimes ) );
end

function ChangeNicknameWnd:getLfetTimes( vipModTimes, cardsNum )
	return vipModTimes + cardsNum;
end

function ChangeNicknameWnd:getLeftModTimeText( leftTimes )
	if self.vipLevel >= 6 then
		return "您目前为vip"..self.vipLevel.."玩家，可获得无限次改名机会！";
	else
		return "剩余修改次数".. (leftTimes or 0) .."次，提升VIP可以获得更多改名次数哦！";
	end	
end

function ChangeNicknameWnd:setOnOkClickListener( obj, func )
	self.okObj = obj;
	self.okFunc = func;
end

function ChangeNicknameWnd:onTextChange()
	if getStringLen(self.textNickname:getText()) > 20 then
		self.textNickname:setText("");
		local msg = "您输入的昵称太长或没有输入昵称，请重新输入!";
		Banner.getInstance():showMsg(msg);
	end
end

function ChangeNicknameWnd:requestChangeNickname( newNickname )
	if not newNickname or ( newNickname and newNickname == "" ) then
		self:hideWnd();
		return;
	end

	if self:checkAndUploadUserInfo() then
		return;
	end
end

function ChangeNicknameWnd:checkAndUploadUserInfo()
	self.myUserInfo = PlayerManager.getInstance():myself();
	local nick = self.myUserInfo.nickName;
	local gender = self.myUserInfo.sex;
	self.newNick = self.textNickname:getText();
	self.newNick = publ_trim(self.newNick);
	if nick == self.newNick and gender == self.gender then
		return true;  --没有需要更新的数据
	end
	if getStringLen(self.newNick) > 20 or self.newNick == "" then
		local msg = "您输入的昵称太长或没有输入昵称";
		Banner.getInstance():showMsg(msg);
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
	-- local msg = "正在同步服务器，请稍候";
	-- Banner.getInstance():showMsg(msg);
	local param_data = {};
	param_data.mid = self.myUserInfo.mid;
	param_data.sitemid = SystemGetSitemid();
	param_data.mnick = self.newNick;
	param_data.msex = self.gender;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUSET_CHANGE_NICK_NAME, param_data);
	return false;
end
