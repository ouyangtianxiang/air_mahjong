
require("MahjongHall/Rank/RankUserInfo");
require("MahjongHall/Friend/MailSystemCheckWin")
local mailSystemMessageItem = require(ViewLuaPath.."mailSystemMessageItem");



MailSysMessageItem = class(Node)

MailSysMessageItem.ctor = function(self, data, listen, func)
	if not data then
		return;
	end

	self.deleteListener = listen
	self.deleteAction = func
	--self.m_event = EventDispatcher.getInstance():getUserEvent();
	--EventDispatcher.getInstance():register(self.m_event,self,self.onHttpRequestsCallBack);
---------------------------------
	self.uiBg = SceneLoader.load(mailSystemMessageItem);
	self:addChild(self.uiBg);
	self:setSize(self.uiBg:getSize());

	self.bgBtn      =  publ_getItemFromTree(self.uiBg, {"bg"})
	self.bgBtn:setOnClick(self,self.checkMessage)
	self.bgBtn:setType(Button.Gray_Type)
	
	self.titleLabel =  publ_getItemFromTree(self.uiBg, {"bg","title"})
	self.bodyLabel  =  publ_getItemFromTree(self.uiBg, {"bg","content"})
	self.checkBtn   =  publ_getItemFromTree(self.uiBg, {"bg","check"})
	--self.deleteBtn  =  publ_getItemFromTree(self.uiBg, {"bg","delete"})
	self.btnLable   =  publ_getItemFromTree(self.uiBg, {"bg","check","text"})

	self.checkBtn:setOnClick(self,self.checkMessage)
	self.checkBtn:setType(Button.Gray_Type)
	--self.deleteBtn:setOnClick(self,self.onDeleteMessage)

	self:initWithData(data)	
	self.data = data
	
end

MailSysMessageItem.setDeleteCallback = function ( self, obj, func )
	self.deleteListener = obj
	self.deleteAction   = func
end

MailSysMessageItem.initWithData = function( self,data )
--	local curTime 	= os.time();
	local date 		= os.date("*t", data.start_time);
	local timeStr   = string.format("(%d.%02d.%02d至",date.year,date.month,date.day)

	date 		    = os.date("*t", data.end_time);
	timeStr         = timeStr..	string.format("%d.%02d.%02d)",date.year,date.month,date.day)

	self.titleLabel:setText( stringFormatWithString(data.title ,24,true) .. timeStr )
	self.bodyLabel:setText( stringFormatWithString(data.content, 40,true) )

	if data.type == 1 then --无奖消息
		
		if data.isRead then 
			self.btnLable:setText("已 阅")
			self.checkBtn:setIsGray(true);
		else 
			self.btnLable:setText("查 看")
			self.checkBtn:setIsGray(false);
		end 

	else --2 有奖消息
		self.hasReward = true
		if data.award == 0 then --可领取
			self.btnLable:setText("领 取")
			self.checkBtn:setIsGray(false);
		else --已领取
			self.btnLable:setText("已 领")
			--self.checkBtn:setPickable(false);
			self.checkBtn:setIsGray(true);
		end 
	end 


end

MailSysMessageItem.onDeleteMessage = function ( self )
	DebugLog("MailSysMessageItem.onDeleteMessage")
	if self.deleteListener and self.deleteAction then 
		self.deleteAction(self.deleteListener,self.data.id )
	end 
end

MailSysMessageItem.checkMessage = function ( self )
	DebugLog("MailSysMessageItem.checkMessage")
	local needUpdateMailWin = false--已读或者已领奖  状态改变了,需通知消息列表需重新排序

	if not self.hasReward  then --无奖消息  查看
		if not self.data.isRead then
			self.data.isRead = true
			self:saveMessageState()

			needUpdateMailWin = true 
			--self:needNoticeUpdateList()
		end
		self.btnLable:setText("已 阅")
		self.checkBtn:setIsGray(true);		
	end
	local win = new(MailSystemCheckWin,self.data,self.hasReward,needUpdateMailWin)
	win:setCheckCallback(self,self.getRewardSuccessFull)
	--end 
end
--[[
MailSysMessageItem.needNoticeUpdateList = function ( self )
	
end
]]
--type = 1 , 
MailSysMessageItem.getRewardSuccessFull = function ( self,id)
	self.btnLable:setText("已 领")
	--self.checkBtn:setPickable(false);
	self.checkBtn:setIsGray(true);
	self.data.isRead = true
	self.data.award  = 1
	self:saveMessageState()

	--self:needNoticeUpdateList()
end

MailSysMessageItem.saveMessageState = function ( self )
	local message = {}
	for k,v in pairs(self.data) do
		message[k] = v
	end
	SystemMessageData.saveMessage( PlayerManager.getInstance():myself().mid, message)
end

MailSysMessageItem.dtor = function(self)
	self.data = nil
	--EventDispatcher.getInstance():unregister(self.m_event,self,self.onHttpRequestsCallBack);
	self:removeAllChildren();
end