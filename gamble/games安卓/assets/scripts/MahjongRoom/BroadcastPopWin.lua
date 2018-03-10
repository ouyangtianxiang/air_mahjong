local broadcastPopWin = require(ViewLuaPath.."broadcastPopWin");

BroadcastPopWin = class(SCWindow);

BroadcastPopWin.ctor = function ( self )
	self.layout = SceneLoader.load(broadcastPopWin);
	self:addChild(self.layout);
	self.cover:setEventTouch(self , function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
		if finger_action ==  kFingerUp then
			-- self:popWindowUp();
			-- popWindowUp(self,self.hideHandle, self.bg);
			self:hideWnd();
		end
	end);

	self.bg = publ_getItemFromTree(self.layout, { "bg"});
	self.editText = publ_getItemFromTree(self.layout, { "bg", "inputBg", "addinput"});
	self.editText:setScrollBarWidth(0);
	self.editText:setOnTextChange(self, function ( self )
		self.editText:setText(stringFormatWithString( self.editText:getText(), GameConstant.chatMaxCharNum, true) );
	end);

	self:setAutoRemove( false );
	self:setWindowNode( self.bg );

	self.trumpetBtn = publ_getItemFromTree(self.layout, { "bg","trumpetBtn"});
	self.trumpetTip = publ_getItemFromTree(self.layout, { "bg","trumpetBtn", "trumpetTip"});
	self.trumpetNum = publ_getItemFromTree(self.layout, { "bg","trumpetBtn", "trumpetTip", "trumpetNum"});
	self.trumpetTip:setLevel(10000);

	self.trumpet1 = UICreator.createImg("Room/trumpet1.png");
	self.trumpet2 = UICreator.createImg("Room/trumpet2.png");
	self.trumpet3 = UICreator.createImg("Room/trumpet3.png");

	self.trumpetBtn:addChild(self.trumpet1);
	self.trumpetBtn:addChild(self.trumpet2);
	self.trumpetBtn:addChild(self.trumpet3);

	local w,h = self.trumpetBtn:getSize();
	self.trumpet1:setSize(w,h);
	self.trumpet2:setSize(w,h);
	self.trumpet3:setSize(w,h);

	self.trumpet1:setVisible(false);
	self.trumpet2:setVisible(false);
	self.trumpet3:setVisible(false);

	local count = 1;
	self.trumpetAnim = self.trumpetBtn:addPropTranslate(0, kAnimRepeat, 300, 0, 0, 0, 0, 0);
	self.trumpetAnim:setEvent(self, function(self)
		if 3 < count then
			count = 1;
		end
		self.trumpet1:setVisible(1 == count);
		self.trumpet2:setVisible(2 == count);
		self.trumpet3:setVisible(3 == count);
		count = count + 1;
	end);



	self.trumpetBtn:setOnClick(self, function(self)
		if not self.editText:getText() or #publ_trim(self.editText:getText()) < 1 then
			DebugLog("发送聊天信息失败，字符不合法。");
			Banner.getInstance():showMsg("您发送的信息为空。");
			return ;
		end
		self:useBroadcastTrumpet();
		self:hideWnd();
		self:updateTrumpetNum();
	end);
	self:updateTrumpetNum();
	self:showWnd();
end

BroadcastPopWin.updateTrumpetNum = function ( self )
	if self.trumpetNum and GameConstant.changeNickTimes.propnum > -1 then
		self.trumpetNum:setText(GameConstant.changeNickTimes.propnum);
	end
end

-- 请求使用喇叭进行广播
BroadcastPopWin.useBroadcastTrumpet = function ( self )
	local param = {};

	param.mid  = PlayerManager.getInstance():myself().mid;
	param.name = PlayerManager.getInstance():myself().nickName;
	param.msg  = self.editText:getText();
	SocketManager.getInstance():sendPack(CLIENT_CMD_BROADCAST_TRUMPET, param);
end
-- 返回使用喇叭的结果
BroadcastPopWin.returnTrumpetResult = function ( self, data)
	if -1 == data.flag then
		DebugLog("server send wrong message");
	else
		GameConstant.changeNickTimes.propnum = GameConstant.changeNickTimes.propnum - 1;
		ItemManager.getInstance():removeCard(ItemManager.LABA_CID, 1);
		if data.mid == PlayerManager.getInstance():myself().mid and self.trumpetNum and data.trumpetNum > -1 then
			self.trumpetNum:setText(data.trumpetNum .. "");
		end
	end
end

BroadcastPopWin.dtor = function ( self )
	self:removeAllChildren();
end


