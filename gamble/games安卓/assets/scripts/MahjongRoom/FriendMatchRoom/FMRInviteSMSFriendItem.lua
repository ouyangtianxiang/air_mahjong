FMRInviteSMSFriendItem = class(Node)

function FMRInviteSMSFriendItem:ctor(data)
	-- body
	self:setSize(775,80)
	self:initView(data)
end

function FMRInviteSMSFriendItem:dtor()
	self._data = nil
	-- body
	if self.inviteAnim then 
		delete(self.inviteAnim)
		self.inviteAnim = nil
	end 
end

function FMRInviteSMSFriendItem:initView(data)
	self._data = data

	local splitLine = UICreator.createImg("Commonx/split_hori.png",0,0)
	splitLine:setAlign(kAlignBottom)
	splitLine:setSize(755,2)
	self:addChild(splitLine)
	--UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
	--UICreator.createBtn = function ( imgDir, x, y, obj, func)
	local nameText  = UICreator.createText(stringFormatWithString(data.name or "",9,true), 20,0,0,0,kAlignLeft, 30, 0x4b, 0x2b, 0x1c)
	nameText:setAlign(kAlignLeft)
	self:addChild(nameText)

	local phoneNum  = UICreator.createText(tostring(data.number),260,0,0,0,kAlignLeft, 30, 0xcc, 0x44, 0x00)
	phoneNum:setAlign(kAlignLeft)
	self:addChild(phoneNum)

	self.inviteBtn       = UICreator.createBtn("Commonx/green_small_btn.png",20,4,self, self.onClickedInviteBtn)
	self.inviteBtn:setAlign(kAlignRight)
	self:addChild(self.inviteBtn)

	local btnText        = UICreator.createText("邀 请",0,-4,0,0,kAlignCenter, 30, 0xff, 0xff, 0xff)
	self.inviteBtn:addChild(btnText)
	btnText:setAlign(kAlignCenter)
end

function FMRInviteSMSFriendItem:sendInviteSMS( )
	local data = GlobalDataManager.getInstance().m_b_invite_match and GlobalDataManager.getInstance().fm_match_invite_data 
                 or GlobalDataManager.getInstance().fmInviteInfo--id=发送邀请短信&s[]=phonebook
	if data and data.sms then 
		local str = data.sms.desc or ""
		str = str .. " " .. (data.sms.url or "")

	    local param = {};
	    param.name  	= self._data.name or "";
	    param.phone 	= self._data.number or "";
	    param.type  	= 1--
	    param.content   = str --fmInviteInfo
		
	    SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_INVITE_SMS, param)
	    Banner.getInstance():showMsg("邀请短信已发送,请注意查收...");	
	else 
		Banner.getInstance():showMsg("配置错误，未拉取到短信配置！")	
	end 
end

function FMRInviteSMSFriendItem:onClickedInviteBtn( )
	-- body
	if not self.inviteAnim then 
		self.inviteBtn:setPickable(false)
		self.inviteBtn:setGray(true)

	    --DebugLog("NewFriendView.sendInviteSms");
	    self:sendInviteSMS()

		self.inviteAnim = new(AnimInt, kAnimNormal, 0, 1, 30000, 0)---1分钟邀请1次
		self.inviteAnim:setDebugName("FMRInviteSMSFriendItem|inviteAnim")
		self.inviteAnim:setEvent( self, function ( self )
			
			if self.inviteAnim then 
				delete(self.inviteAnim)
				self.inviteAnim = nil 
			end
			self.inviteBtn:setPickable(true)
			self.inviteBtn:setGray(false)
		end)

	end 
end


