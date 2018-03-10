NoticeItem = class(Node);

NoticeItem.ctor = function ( self, data, refNode )
	self.refNode      = refNode;
	self.title        = data.title
	self.content      = data.content
	self.link_type    = data.link_type
	self.link_content = data.link_content
	self.start_time   = data.start_time
    self.m_h_ajust = 15;--调整item间距 
	self:creat();
end

NoticeItem.creat = function ( self )
    
	local title = self.start_time .. "  " .. self.title;
	self.titleView = new(Text, title, 700, 50, kAlignTopLeft, nil, 26, 0x4b , 0x2b , 0x1c)--24, 250, 230, 90);
	self.titleView:setPos(25,0)
	_, self.titleH  = self.titleView:getSize();
    self.titleH = self.titleH -15;
	self:addChild(self.titleView);

	self.contentView = new(TextView, self.content, 700, 0, kAlignLeft, nil, 26, 0x94 , 0x32 , 0x00)--24, 250, 240, 200);
	self.contentView:setPos(25, self.titleH );
	_, self.contentH = self.contentView:getSize();
	self:addChild(self.contentView);
	DebugLog("NoticeItem:linkType="..tostring(self.link_type))
	local linkType = tonumber(self.link_type);
	if 0 ~= linkType then
		self.linkView = new(Text, self.link_content, 0, 50, kAlignLeft, kFontTextUnderLine, 26, 0x27 , 0x99 , 0x00)--24, 40, 180, 220);
		self.linkView:setSize(self.linkView.m_res:getWidth(), self.linkView.m_res:getHeight());
		self.linkView:setPos(25, self.titleH +self.contentH);
		_, self.linkH = self.linkView:getSize();
		self.linkView:setEventTouch(self, function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
			if kFingerUp == finger_action then
                if HallScene_instance then
                    HallScene_instance:closeAllPopuWnd();
                end
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
				elseif 9 == linkType and HallScene_instance.m_bottomLayer then --兑换
					if HallScene_instance then 
						HallScene_instance.m_bottomLayer:onClickedExchangeBtn();
						self.refNode:hide()
					end
				elseif 10 == linkType then --好友对战
					if HallScene_instance then 
						HallScene_instance:onClickedCreateRoom()
						self.refNode:hide()
					end
                elseif 11 == linkType then--比赛场
                 	if HallScene_instance then 
						HallScene_instance:onClickedMatchBtn()
						self.refNode:hide()
					end	
				end
			end
		end);
		self:addChild(self.linkView);
	end

	self.splitLine = UICreator.createImg("Commonx/split_hori.png")
	self.splitLine:setAlign(kAlignBottomLeft)
	self.splitLine:setSize(750,2)
	self.splitLine:setPos(0,0)
	self:addChild(self.splitLine)

	self:setSize(0, self.titleH + self.contentH + (self.linkH or 0)+self.m_h_ajust);
end

NoticeItem.getTotalLength = function ( self )
	return (self.titleH + self.contentH + (self.linkH or 0)+self.m_h_ajust*2);
end

