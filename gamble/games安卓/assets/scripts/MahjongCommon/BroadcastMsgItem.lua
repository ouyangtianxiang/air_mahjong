require("uiex/richText");
BroadcastMsgItem = class(Node);

BroadcastMsgItem.ctor = function ( self, data, ref)
	self.ref		  = ref;
	self.msgType	  = data.msgType;
	self.msg 		  = data.msg;
	self.mid		  = data.mid;
	if 1 == data.msgType then--系统
		r = 0xcc--255
		g = 0x44--250
		b = 0x00--110
	elseif 2 == data.msgType then--公告
		r = 0x09--120
		g = 0x7c--250
		b = 0x25--120
	elseif 3 ==  data.msgType then
		r = 0x4b--255
		g = 0x2b--255
		b = 0x1c--255
	end
	self.contentH = 0;

	self.countId = data.countId	
	self:creat(r, g, b);
end

BroadcastMsgItem.creat = function ( self, r, g, b )
	if 3 ~= self.msgType then
		self.contentView = new(TextView, self.msg, 760, 0, kAlignLeft, nil, 26, r, g, b);
		self:addChild(self.contentView);
		self.contentView:setPos(15,0)
		_, self.contentH = self.contentView:getSize();
	elseif 3 == self.msgType then
		local nickName = self:getNickName();
		if "" == nickName then
			nickName = " ";
		end

		local pos1, pos2 = string.find(self.msg, "】");
		local pos3 = string.find(self.msg, ":");
		local str1 = string.sub(self.msg, 1, pos2);
		local str2 = string.sub(self.msg, pos2+1, pos3-1);
		local str3 = string.sub(self.msg, pos3, string.len(self.msg));
		local str = str1 .. "#u#e(1)" .. str2.. "#n" .. str3;
		self.nickNameView = new(RichText, str, 760, 0, kAlignLeft, nil, 26, r, g, b, true);
		self.nickNameView:setOnClick(self, function ( self )
			self.ref:searchFriendById({self.mid});
			FriendDataManager.getInstance():requestFriendsIsOnlineSocket();
		end);
		self:addChild(self.nickNameView);
		self.nickNameView:setPos(15,0)
		_, self.contentH = self.nickNameView:getSize();
	end

	if self.countId % 2 == 1 then --奇数
		local bgImg = UICreator.createImg("Commonx/chat_text_bg.png", 0,0)
		bgImg:setSize(830,self.contentH + 10)
		bgImg:setLevel(-1)
		--bgImg:setPos(0,0)
		--bgImg:setAlign(kAlignCenter)
		self:addChild(bgImg)

		if PlatformConfig.platformWDJ == GameConstant.platformType or 
		   PlatformConfig.platformWDJNet == GameConstant.platformType then 
    		bgImg:setFile("Login/wdj/Hall/Commonx/chat_text_bg.png");
    	end
	end
	self:setSize(0, self.contentH + 10 );
end

BroadcastMsgItem.getNickName = function ( self )
	local _, p1 = string.find(self.msg, "】"); 
	local p2, _ = string.find(self.msg, ":");

	return (string.sub(self.msg, p1+1, p2-1))
end

BroadcastMsgItem.getTotalLength = function ( self )
	return (self.contentH + 20);
end

