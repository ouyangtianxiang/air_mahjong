-- 宝箱弹窗
local chestWnd = require(ViewLuaPath.."chestWnd");
ChestPop = class(SCWindow);


ChestPop.ctor = function ( self, data )
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self.data = data;
	self.requireChestPopWndFlag = 0;
	self.layout = SceneLoader.load(chestWnd);
	self:addChild(self.layout);

	self.bg = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode( self.bg );

	self.cover:setEventTouch(self , function (self)
		self:hideWnd();
	end);

	--[[
	publ_getItemFromTree(self.layout, {"bg", "box1"}):setOnClick(self,function(self)
		self:onBoxClick(0);
	end);
	publ_getItemFromTree(self.layout, {"bg", "box2"}):setOnClick(self,function(self)
		self:onBoxClick(1);
	end);
	publ_getItemFromTree(self.layout, {"bg", "box3"}):setOnClick(self,function(self)
		self:onBoxClick(2);
	end);
	publ_getItemFromTree(self.layout, {"bg", "box4"}):setOnClick(self,function(self)
		self:onBoxClick(3);
	end);
]]
	for i=1,4 do
		publ_getItemFromTree(self.layout, {"bg", string.format("bg%d",i),"box1"}):setOnClick(self,function(self)
			self:onBoxClick(i-1);
		end);
	end

	self:show();
end


--宝箱奖励swf动画
ChestPop.play_swf = function (self)
    if not self.m_award_data then
        return;
    end
    for i = 1, #self.m_award_data.data.goods do
        local choosed = self.m_award_data.data.goods[i].choosed;
        if choosed == 1 then
            self.m_award_goods = self.m_award_data.data.goods[i];
        end
    end
    if not self.m_award_goods then
        return;
    end
    if self.swf_node then
        self.swf_node:removeFromSuper();
    end
    --self.m_award_goods = {title = "10元话费券"};
    --0：银宝箱 1：金宝箱
    local boxType = RoomData.getInstance().boxType or 0;

    local node = new(SCWindow)
    node:setWindowNode(node);
    node:setCoverEnable(false);
    node:setVisible(false);

    --光
    local light = new(Image,"Room/box_light.png");
    light:setSize(720,720);
    light:setVisible(true);
    light:setAlign(kAlignCenter);
    node:addChild(light);
    node.light = light;


    --奖品
    local award = new(Image,"Commonx/windowsCoin.png");--new(Image,"Commonx/blank.png");
    award:setSize(144,194);
    award:setPos(0, -30);
    award:setAlign(kAlignCenter);
    node:addChild(award);
    node.award = award;
    local isExist, localDir = NativeManager.getInstance():downloadImage(self.m_award_goods.img);
    node.award_local_dir = localDir;
    if isExist then
        award:setFile(localDir);
	end

    local prop =  light:addPropRotate(
                                1,
                                kAnimRepeat,
                                5000,200,0,
                                360,
                                kCenterDrawing);


    local box_1_swf_info = boxType == 1 and require("qnSwfRes/box_1_swf_info") or require("qnSwfRes/box_2_swf_info");
    local box_1_swf_pin = boxType == 1 and require("qnSwfRes/box_1_swf_pin") or require("qnSwfRes/box_2_swf_pin");
    local swf_box = new(SwfPlayer,box_1_swf_info, box_1_swf_pin);
    swf_box:play(1,true,1);
    swf_box:setAlign(kAlignCenter);
    self:addChild(swf_box);
    self.swf_box = swf_box;

    
    self:addChild(node);
    self.swf_node = node;


    --swf_box:setCompleteEvent
    swf_box:setFrameEvent(self, function (self)
        --显示后面界面上应该显示的奖品
        self.swf_node:setVisible(true);
        --刷新数据
        self:updateAward();

        --星星
        local box_1_swf_info = require("qnSwfRes/box_star_swf_info");
        local box_1_swf_pin = require("qnSwfRes/box_star_swf_pin");
        local swf = new(SwfPlayer,box_1_swf_info, box_1_swf_pin);
        swf:play(1,false,1);
        swf:setAlign(kAlignCenter);
        self.swf_node:addChild(swf);
    end, 20);

    --title
    local title = new(Text, self.m_award_goods.title or "", 0, 0, kAlignCenter, "", 30, 0xff , 0xff , 0xff)
    title:setAlign(kAlignCenter);
    title:setPos(0, 100);
    node:addChild(title);

    --button
    local btn = new(Button, "Commonx/green_small_btn.png", nil, nil, nil, 0, 0, 0, 0);
    btn:setAlign(kAlignCenter);
    btn:setPos(0, 180);
    btn:setOnClick(self, function (self)
        self.swf_node:setVisible(false);
        self.swf_node = nil;
        self:setVisible(false);
        self:hideWnd();
    end);
    node:addChild(btn);

    --
    local t = new(Text, "确 定", 0, 0, kAlignCenter, "", 30, 0xff , 0xff , 0xff)
    t:setAlign(kAlignCenter);
    t:setPos(0, -8);
    btn:addChild(t);
end

--刷新数据
ChestPop.updateAward = function (self)
    local data = self.m_award_data;
    if not data then
        return;
    end
    for i=1, #data.data.goods do
	    local imgUrl = data.data.goods[i].img
	    local title = data.data.goods[i].title
        local choosed = data.data.goods[i].choosed;
	    --local boxPos = string.format("box%d",i);
	    --local textPos = string.format("Text%d",i);
	    local itemPos = string.format("bg%d",i)

	    local item    = publ_getItemFromTree(self.layout, {"bg", itemPos})
	    item:setFile("Room/chest/item_s.png")
			
	    if PlatformConfig.platformWDJ == GameConstant.platformType or 
		    PlatformConfig.platformWDJNet == GameConstant.platformType then
		    item:setFile("Login/wdj/Room/chest/item_s.png");
  	    end
	    local boxText = publ_getItemFromTree(self.layout, {"bg", itemPos, "Text1"});
	    boxText:setText(title);

	    local boxImg  = publ_getItemFromTree(self.layout, {"bg", itemPos, "box1"});
	    local tmpNode = new(ChestAwardNode, boxImg, imgUrl);

	    self:addChild(tmpNode);
 
    end

    self.tipMsg = data.msg
    --    	if nil ~= self.tipMsg and "" ~= self.tipMsg then
    --			if GameConstant.curGameSceneRef then
    --				GameConstant.curGameSceneRef:showChestAwardTip(self.tipMsg);
    --			end
    --		end

    -- 更新金币
    if tonumber(data.data.money) > 0 then
	    --showGoldDropAnimation();
	    PlayerManager.getInstance():myself():addMoney(tonumber(data.data.money))
	    if RoomScene_instance and not FriendMatchRoomScene_instance then 
		    SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid});
	    end 
    end
    -- 更新喇叭
    if data.data.card["22"] and "" ~= data.data.card["22"] then
	    GameConstant.changeNickTimes.propnum = tonumber(data.data.card["22"])
    end

    -- 更新话费卷
    PlayerManager.getInstance():myself():setCoupons(tonumber(data.data.coupons))

    local str = data.data.playstr
    if nil ~= str and "" ~= str then
	    self:broadcast(str);
    end

    if 0 == tonumber(data.data.open) then
	    if GameConstant.curGameSceneRef then
		    GameConstant.curGameSceneRef:hideChestStartup();
	    end
    elseif 1 == tonumber(data.data.open) then
	    if GameConstant.curGameSceneRef then
		    GameConstant.curGameSceneRef:updateChestImg(1);

		    local t = {};
		    t.process = tonumber(data.data.process)
		    t.need = tonumber(data.data.need)
		    GameConstant.curGameSceneRef.chestNeedJu = t.need;
		    GameConstant.curGameSceneRef.chestProcessJu = t.process;
		    GameConstant.curGameSceneRef:updateChestText(t);
	    end
    end
end

ChestPop.onBoxClick = function ( self, pos)
    --self:play_swf();
	if 0 == tonumber(self.data.data.award) then
		local num = tonumber(self.data.data.need) - tonumber(self.data.data.process);
		Banner.getInstance():showMsg("请游戏" .. num .. "局后再参与活动");
	elseif 1 == tonumber(self.data.data.award) then
		self:requireChestAward(pos);
	end
end

ChestPop.show = function ( self )
	if not self.data or not self.data.data or not self.data.data.goods then 
		return 
	end 
	

	for i=1, math.min(#self.data.data.goods,4) do
		local imgUrl = self.data.data.goods[i].img
		local title = self.data.data.goods[i].title
		--local boxPos = string.format("box%d",i);
		--local textPos = string.format("Text%d",i);
		local itemPos = string.format("bg%d",i)

		local boxText = publ_getItemFromTree(self.layout, {"bg", itemPos, "Text1"});
		boxText:setText(title);

		local boxImg  = publ_getItemFromTree(self.layout, {"bg", itemPos, "box1"});
		
		local tmpNode = new(ChestPopNode, boxImg, imgUrl);
		self:addChild(tmpNode);

		if PlatformConfig.platformWDJ == GameConstant.platformType or
           PlatformConfig.platformWDJNet == GameConstant.platformType then
			publ_getItemFromTree(self.layout, {"bg", "title1"}):setFile("Login/wdj/Room/chest/title1.png");
			publ_getItemFromTree(self.layout, {"bg", "title2"}):setFile("Login/wdj/Room/chest/title2.png");
			publ_getItemFromTree(self.layout, {"bg", "titleNum"}):setFile("Login/wdj/Room/chest/0.png");
  		end

		if 1 == self.data.data.award then
			publ_getItemFromTree(self.layout, {"bg", "title1"}):setVisible(true);
		else

			local num = tonumber(self.data.data.need) - tonumber(self.data.data.process);
			local titleNum1 = math.floor(num / 10); --十位
			local titleNum = math.mod(num,10); -- 个位

			local numStr = string.format("Room/chest/%d.png",titleNum);
			if PlatformConfig.platformWDJ == GameConstant.platformType or 
        	   PlatformConfig.platformWDJNet == GameConstant.platformType then
				numStr = string.format("Login/wdj/Room/chest/%d.png",titleNum);
	  		end
			publ_getItemFromTree(self.layout, {"bg", "titleNum"}):setFile(numStr);
			publ_getItemFromTree(self.layout, {"bg", "titleNum"}):setVisible(true);
			publ_getItemFromTree(self.layout, {"bg", "title2"}):setVisible(true);
			if 0 < titleNum1 then
				local tmp = string.format("Room/chest/%d.png",titleNum1);
				publ_getItemFromTree(self.layout, {"bg", "titleNum1"}):setFile(tmp);
				publ_getItemFromTree(self.layout, {"bg", "titleNum1"}):setVisible(true);
			end
		end
	end
	self:showWnd();


end

ChestPop.requireChestAward = function (self,pos)

	local param = {};
	param.position = pos;
	param.level = GameConstant.curRoomLevel;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUIRE_CHEST_AWARD,param);
end


ChestPop.requireChestAwardCallBack = function ( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end

	local status = data.status
    if status and 2 == tonumber(status) then -- 刷新宝箱详情接口
    	self.requireChestPopWndFlag = 1;
    	self:hideWnd();
    elseif status and 1 == tonumber(status) then -- 成功
  
        self.m_award_data = data;
--		for i=1, #data.data.goods do
--			local imgUrl = data.data.goods[i].img
--			local title = data.data.goods[i].title
--            local choosed = data.data.goods[i].choosed;
--			--local boxPos = string.format("box%d",i);
--			--local textPos = string.format("Text%d",i);
--			local itemPos = string.format("bg%d",i)

--			local item    = publ_getItemFromTree(self.layout, {"bg", itemPos})
--			item:setFile("Room/chest/item_s.png")

--			if PlatformConfig.platformWDJ == GameConstant.platformType or 
--			   PlatformConfig.platformWDJNet == GameConstant.platformType then
--				item:setFile("Login/wdj/Room/chest/item_s.png");
--  			end
--			local boxText = publ_getItemFromTree(self.layout, {"bg", itemPos, "Text1"});
--			boxText:setText(title);

--			local boxImg  = publ_getItemFromTree(self.layout, {"bg", itemPos, "box1"});
--			local tmpNode = new(ChestAwardNode, boxImg, imgUrl);
--            tmpNode.node:setVisible(false);
--            table.insert(self.m_award_imgs, tmpNode);
--			self:addChild(tmpNode);
--		end

--		self.tipMsg = data.msg
----    	if nil ~= self.tipMsg and "" ~= self.tipMsg then
----			if GameConstant.curGameSceneRef then
----				GameConstant.curGameSceneRef:showChestAwardTip(self.tipMsg);
----			end
----		end

--		-- 更新金币
--		if tonumber(data.data.money) > 0 then
--			--showGoldDropAnimation();
--			PlayerManager.getInstance():myself():addMoney(tonumber(data.data.money))
--			if RoomScene_instance and not FriendMatchRoomScene_instance then 
--				SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, {["mid"] = PlayerManager.getInstance():myself().mid});
--			end 
--		end
--		-- 更新喇叭
--		if data.data.card["22"] and "" ~= data.data.card["22"] then
--			GameConstant.changeNickTimes.propnum = tonumber(data.data.card["22"])
--		end

--		-- 更新话费卷
--		PlayerManager.getInstance():myself():setCoupons(tonumber(data.data.coupons))

--		local str = data.data.playstr
--		if nil ~= str and "" ~= str then
--			self:broadcast(str);
--		end

--		if 0 == tonumber(data.data.open) then
--			if GameConstant.curGameSceneRef then
--				GameConstant.curGameSceneRef:hideChestStartup();
--			end
--		elseif 1 == tonumber(data.data.open) then
--			if GameConstant.curGameSceneRef then
--				GameConstant.curGameSceneRef:updateChestImg(1);

--				local t = {};
--				t.process = tonumber(data.data.process)
--				t.need = tonumber(data.data.need)
--				GameConstant.curGameSceneRef.chestNeedJu = t.need;
--				GameConstant.curGameSceneRef.chestProcessJu = t.process;
--				GameConstant.curGameSceneRef:updateChestText(t);
--			end
--		end
        --播放动画
        self:play_swf();
    end	
end


ChestPop.broadcast = function ( self, str )
	local t = {};
	t.type = 1;
	t.times = 1;
	t.msg = str;
	t.priority = 1;

	BroadcastMsgManager.getInstance():receiveBroadcastMsg(t);
end

ChestPop.hideHandle = function ( self )
	self:hide();
	if 1 == self.showTipFlag and nil ~= self.tipMsg and "" ~= self.tipMsg then
		self.showTipFlag  = 0;
		if GameConstant.curGameSceneRef then
			GameConstant.curGameSceneRef:showChestAwardTip(self.tipMsg);
		end
	elseif 1 == self.requireChestPopWndFlag then
		self.requireChestPopWndFlag = 0;
		if GameConstant.curGameSceneRef then
			GameConstant.curGameSceneRef:requireChestPopWnd();
		end
	end
end


ChestPop.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.httpRequestMap[cmd] then 
		self.httpRequestMap[cmd](self,isSuccess,param,...)
	end
end

ChestPop.httpRequestMap = {
    [PHP_CMD_REQUIRE_CHEST_AWARD]   = ChestPop.requireChestAwardCallBack,
};
ChestPop.hide = function(self)
	self:removeFromSuper();
end

ChestPop.dtor = function ( self )
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self:removeAllChildren();
end


ChestPop.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if self.swf_node and self.swf_node.award_local_dir  == _detailData  then
			if self.swf_node.award then
                self.swf_node.award:setFile(_detailData);
            end
        end
    end
end


ChestPopNode = class(Node);
ChestPopNode.ctor = function ( self, node, imgUrl )
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	self.node = node;
    local isExist, localDir = NativeManager.getInstance():downloadImage(imgUrl);
    self.localDir = localDir; 
    if isExist then
		self.node:setFile(localDir);
	end

end

ChestPopNode.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
			self.node:setFile(self.localDir);
        end
    end
end

ChestPopNode.dtor = function ( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

ChestAwardNode = class(Node);
ChestAwardNode.ctor = function ( self, node, imgUrl )
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	self.node = node;
    local isExist, localDir = NativeManager.getInstance():downloadImage(imgUrl);
    self.localDir = localDir; 
    if isExist then
		self.node:setFile(localDir);
		self.node:setPickable(false);
	end

end

ChestAwardNode.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
			self.node:setFile(self.localDir);
			self.node:setPickable(false);
        end
    end
end

ChestAwardNode.dtor = function ( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end