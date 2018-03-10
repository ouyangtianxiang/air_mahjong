-- filename: BroadcastTopNewsItem.lua
-- author: OnlynightZhang
-- desp: 置顶消息项

BroadcastTopNewsItem = class(Node);

-- data BroadcastTopNewsData
BroadcastTopNewsItem.ctor = function( self, data, width )
	self.data = data;
	self.contentHeight = 0;
	self.maxWidth = width;
	if not data or not data:getContent() then
		self:setSize(0,0);
		return;
	end
	self.textContent = new(RichText, data:getContent(), 760, 0, kAlignLeft, nil, 26, 0xcc, 0x44, 0x00,true)--255, 250, 110, true);
	self:addChild( self.textContent );
	self.textContent:setPos(15,0)
	_, self.contentHeight = self.textContent:getSize();
	self:setSize( 0, self.contentHeight + 20 );
	DebugLog("tttttt:linkType="..tostring(self.data and self.data.link_type))
	self.textContent:setOnClick( self, function( self )
		local linkType = self.data.link_type;
		if 1 == linkType then
			DebugLog("tttttt活动中心");
			if HallScene_instance and HallScene_instance.m_bottomLayer then
				HallScene_instance.m_bottomLayer:onClickedActivityBtn();
				self.refNode:hide();
			end
		elseif 2 == linkType then
			DebugLog("tttttt商城");
			if HallScene_instance and HallScene_instance.m_bottomLayer then
				HallScene_instance.m_bottomLayer:onClickedMallBtn();
				self.refNode:hide();
			end
		elseif 3 == linkType then
			DebugLog("tttttt任务");
			if HallScene_instance and HallScene_instance.m_bottomLayer then
				HallScene_instance.m_bottomLayer:onClickedTaskBtn();
				self.refNode:hide();
			end
		elseif 4 == linkType then
			DebugLog("tttttt包厢");
			-- if HallScene_instance then
			-- 	HallScene_instance:onClickedCompartmentBtn();
			-- 	self.refNode:hide();
			-- end
		elseif 5 == linkType then
			DebugLog("tttttt快速开始");
			if HallScene_instance then
				HallScene_instance:onQuickStartGameClick();
				self.refNode:hide();
			end
		elseif 6 == linkType then
			DebugLog("tttttt快速充值");
			if HallScene_instance then 
				getQuickRechargeView(HallScene_instance);
			else
				getQuickRechargeView(RoomScene.instance);
			end
			self.refNode:hide();
		elseif 7 == linkType then
			DebugLog("tttttt更新弹窗");
			if HallScene_instance then
				HallScene_instance:OnUpdateClick();
				self.refNode:hide();
			end
		elseif 8 == linkType then--公告
			if HallScene_instance then
				GlobalDataManager.getInstance():showNoticeWindow();
				self:performLinkClick();
			end
		elseif 9 == linkType then --兑换
			if HallScene_instance then 
				HallScene_instance.m_bottomLayer:onClickedExchangeBtn();
				self.refNode:hide()
			end			
		elseif 10 == linkType then --好友对战
			if HallScene_instance then 
				HallScene_instance:onClickedCreateRoom()
				self.refNode:hide()
			end 
		end

		self:onRoomJump( linkType );
	end);
end

BroadcastTopNewsItem.onRoomJump = function( self, linkType )
	DebugLog( "BroadcastTopNewsItem.onRoomJump" );
	local isInGame = PlayerManager:getInstance():myself().isInGame;
	if RoomScene_instance and not isInGame then
		if linkType == 5 then
			Banner.getInstance():showMsg("您已在房间中，继续玩牌即可");
		else
			GameConstant.isRoomTopNewsLinkType = linkType;
			GameState.changeState( nil, States.Hall );
		end
	else
		GameConstant.isRoomTopNewsLinkType = -1;
	end

	if isInGame then
		Banner.getInstance():showMsg( "游戏中无法跳转" );
	end
end

BroadcastTopNewsItem.performLinkClick = function( self )
	if self.onLinkClickFunc then
		self.onLinkClickFunc( self.onLinkClickObj );
	end
end

BroadcastTopNewsItem.setOnLinkClick = function( self, obj, func )
	self.onLinkClickObj = obj;
	self.onLinkClickFunc = func;
end

BroadcastTopNewsItem.dtor = function( self )
end

BroadcastTopNewsItem.getContentSize = function( self )
	return self.maxWidth, self.contentHeight + 20;
end

BroadcastTopNewsData = class();

BroadcastTopNewsData.ctor = function ( self, data )
	self.type = -1;
	self.link_content = "";
	self.title = "";
	self.start_time = 0;
	self.content = "";
	self.link_type = -1;

	self:setData( data );
end

BroadcastTopNewsData.setData = function( self, data )
	if not data then
		return;
	end

	self.type = data.type and tonumber(data.type) or -1;
	self.link_content = data.link_content and data.link_content or "";
	self.title = data.title and data.title or "";
	self.start_time = data.start_time and tonumber( data.start_time ) or 0;
	self.content = data.content and data.content or "";
	self.link_type = data.link_type and tonumber(data.link_type) or -1;
end

BroadcastTopNewsData.getContent = function( self )
	if self.type == -1 then
		return nil;
	end

	local contentStr = "";
	if self.type == 0 then
		contentStr = "【公告】"..self.content.." #u#e(1)#c28B4DC"..self.link_content.."#n";
	elseif self.type == 1 then
		contentStr = "【系统】"..self.content.." #u#e(1)#c28B4DC"..self.link_content.."#n";
	end

	return contentStr;
end