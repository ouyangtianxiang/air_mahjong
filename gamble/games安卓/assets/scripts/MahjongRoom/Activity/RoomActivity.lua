--房间内server推送活动弹窗
local roomActivity = require(ViewLuaPath.."roomActivity");

RoomActivity = class(CustomNode);

RoomActivity.ctor = function( self, node, ref )
	self.roomRef = ref;
	self.node = node;
	self.node:addChild(self);
	GameConstant.roomActivityShowing = true;
	self.cover:setFile(CreatingViewUsingData.commonData.blankBg.fileName, CreatingViewUsingData.commonData.bg.x,CreatingViewUsingData.commonData.bg.y);
	
	self.layout = SceneLoader.load(roomActivity);
	self:addChild(self.layout);
	self.layout:setVisible(true);

	self.background = publ_getItemFromTree(self.layout, {"background"});
	self.background:setEventTouch(self , function ( self )
		-- Don't do anything.
	end);

	--获得节点信息
	self.baseNode  			= publ_getItemFromTree(self.layout, {"background", "baseNode"});
	self.titleText 			= publ_getItemFromTree(self.layout, {"background", "baseNode", "titleText"});
	self.moneyText 			= publ_getItemFromTree(self.layout, {"background", "baseNode", "innerBg","view_top", "view_coid", "text_coin"});
	self.content   			= publ_getItemFromTree(self.layout, {"background", "baseNode", "innerBg", "view_bottom"});
	self.progressBg 		= publ_getItemFromTree(self.layout, {"background", "baseNode", "innerBg", "view_bottom", "progressBg"});
	self.progressImg 		= publ_getItemFromTree(self.layout, {"background", "baseNode", "innerBg", "view_bottom", "progressBg","progressImg"});
	self.progressText 		= publ_getItemFromTree(self.layout, {"background", "baseNode", "innerBg", "view_bottom", "progressBg","progressText"});
	self.confirmButton 		= publ_getItemFromTree(self.layout, {"background", "baseNode", "confirmButton"});
	self.confirmButtonText  = publ_getItemFromTree(self.layout, {"background", "baseNode", "confirmButton", "text"});

	if self.baseNode then	
		self.baseNode:setVisible(false);
	end

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
       self.background:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
       self.progressBg:setFile("Login/wdj/Room/progress_bg.png"); 
       self.progressImg:setFile("Login/wdj/Room/progress.png"); 
       publ_getItemFromTree(self.layout,{"background", "baseNode", "innerBg"}):setFile("Login/wdj/Room/roomActivityBg.png");
    end

	Loading.showLoadingAnim("正在努力加载中...");
end

RoomActivity.dtor = function( self )
	self:removeAllChildren();
	GameConstant.roomActivityShowing = false;
end

RoomActivity.hide = function( self )
	umengStatics_lua(kUmengRoomCoinDispatchCloseBtn);
	self.node:removeChild(self , true);
	GameConstant.roomActivityShowing = false;
end

RoomActivity.getFormatTimeStr = function ( self, time )
	-- body
	local timeText;
	local h = math.floor(time/3600);
	local m = math.floor((time - h * 3600)/60);
	local s = math.floor(time - h * 3600 - m*60);
	timeText = string.format("%02d:%02d:%02d", h, m, s );
	return timeText;
end

RoomActivity.createTimerAndDesc = function ( self, time, descText, multiLine )
	-- body
	local timeText = self:getFormatTimeStr(time);
	local timeNode = new(Text, timeText, 0, 0, kAlignLeft, nil, 26, 0xcc, 0x44, 0x00);
	local descNode = new(Text, descText, 0, 0, kAlignLeft, nil, 26, 0x4b, 0x2b, 0x1c);
	local descNode1= nil;

	if multiLine then
		local countPerLine = 21;
		if getStringLen(descText) > countPerLine then
			local subText = getUTF_8String(descText, countPerLine);--string.sub(descText, 1, countPerLine);
			local subText1= string.sub(descText, string.len(subText) + 1, string.len(descText));
			delete(descNode);
			descNode 	= new(Text, subText, 0, 0, kAlignLeft, nil, 26, 0xFF, 0xFA, 0x46);
			descNode1 	= new(Text, subText1, 0, 0, kAlignLeft, nil, 26, 0xFF, 0xFA, 0x46);
		end
	end

	local w, h 	 = self.content:getSize();

	local tw, th = timeNode.m_res.m_width, timeNode.m_res.m_height;
	local dw, dh = descNode.m_res.m_width, descNode.m_res.m_height;

	local x, y = 0, 20;

	x = (w - (tw + dw + 5)) / 2;

	timeNode:setPos(x, y);
	descNode:setPos(x + tw + 5, y);

	if descNode1 then
		local dw1, dh1 = descNode1.m_res.m_width, descNode1.m_res.m_height;
		descNode1:setPos((w - dw1) / 2, y + dh + 5);
	end

	
	self.content:addChild(timeNode);
	self.content:addChild(descNode);
	self.content:addChild(descNode1);

	self.timeNode = timeNode;
	self.time 	  = time;

	local tAnim = timeNode:addPropTransparency(0, kAnimRepeat, 1000, 0, 1, 1);
	tAnim:setDebugName("RoomActivity || anim");
	tAnim:setEvent(self, function ( self )
		-- body
		self.time = self.time - 1;
		if self.time <= 0 then
			self.time = 0;
			self.timeNode:removeProp(0);
		end

		self.timeNode:setText(self:getFormatTimeStr(self.time));
	end);

end


RoomActivity.updateInfo = function( self, data )

	if self.baseNode then
		local title 	= data.data.title or "";  --题目
		local moneyStr 	= data.data.gmoney or "";  --显示的金币字段
		local descStr 	= data.data.desc or "";  --时间后跟的描述
		local rate 		= tonumber(data.data.rate) or 0;  --完成进度(累计任务才有)
		local typeNum 	= tonumber(data.data.type) or 0;  --活动类型
		local award 	= tonumber(data.data.award) or 0;  --是否可以领奖  1可领  0不可领
		local amount 	= tonumber(data.data.amount) or 0;  --需要充值多少钱
		local endtime 	= tonumber(data.data.endtime) or 0;
		local btnName 	= data.data.btn or "立即充值";

		self.titleText:setText(title);
		self.moneyText:setText(string.gsub(moneyStr, "金币", ""));
		--进度条相关
		if typeNum == 1 then
			self.progressImg:setClip(0, 0, 478*(rate/100), 46);
			self.progressText:setText(rate.."%");
			self.progressBg:setVisible(true);
			self:createTimerAndDesc(endtime, descStr, false); -- 文字描述只能显示一行
		else
			self.progressBg:setVisible(false);  --单次任务不显示进度条
			self:createTimerAndDesc(endtime, descStr, true);
		end
		--领奖按钮相关
		umengStatics_lua(kUmengRoomCoinDispatchBuyBtn);
		if award == 1 then
			self.confirmButtonText:setText("领取奖励");
			self.confirmButton:setOnClick(self, function( self )
				self.roomRef:getRoomActivityAward();
				self:hide();
			end);
		else

			self.confirmButtonText:setText(btnName);
			self.confirmButton:setOnClick(self, function( self )

				local pamount = 0;
				if typeNum == 1 then
					--推荐充值剩余金额的金币
					pamount = ProductManager.getInstance():getProductOverop(amount*((100-rate)/100)) or 0;
				else
					pamount = ProductManager.getInstance():getProductOverop(amount) or 0;
				end
				if pamount > 0 then
					local payScene = {};
					payScene.scene_id = PlatformConfig.RoomActivityForPay;
					GlobalDataManager.getInstance():quickPay(pamount, payScene);
				end
				self:hide();
			end);
		end
		self.baseNode:setVisible(true);
	end
	Loading.hideLoadingAnim();
end

