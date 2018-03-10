local roomBuyPropView = require(ViewLuaPath.."roomBuyPropView");

RoomBuyPropWnd = class(SCWindow); 

--[[
	currentProp  -- 当前是哪个道具，用于获取道具图
	unitPrice   --价格
]]
RoomBuyPropWnd.ctor = function(self, currentProp, player, parent, freeMoney )
	log("RoomBuyPropWnd.ctor  currentProp ==" .. currentProp);
	self.unitPrice = GameConstant.roomPropTab[currentProp];
	self.layout = SceneLoader.load(roomBuyPropView);
	self.m_freeMoney = freeMoney;
	self:initView();

	self:addChild(self.layout);
	self:setWindowNode(publ_getItemFromTree(self.layout, {"bg"}));
	self.parent = parent;
	self.parent:addChild(self);

	self.imgPropIcon:setFile(GameConstant.roomPropMap[currentProp]);

	--获取玩家金币
	self.player = player;
	self.m_maxNum = self:calculateMaxNum( self.m_freeMoney );
	log( "self.m_maxNum = "..self.m_maxNum );
	local totalMoney = tonumber(self.unitPrice) * self.m_maxNum;
	self.textSinglePrice:setText(self.unitPrice .. "金币");
	self.textPropNum:setText(self.m_maxNum);
	self.count = self.m_maxNum;
	self.textAllPrice:setText(totalMoney .. "金币");

	--购买
	self.btnOK:setOnClick(self, function(self)
		self:hideWnd();
		if self.Confirmobj and self.Func then
			self.parent.currentBuyNum  = self.textPropNum:getText() or 1;
			self.Func(self.Confirmobj);
		end
	end);

	--关闭
	self.btnClose:setOnClick(self, function(self)
		self:hideWnd();
	end);

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
       self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
       self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
       publ_getItemFromTree(self.layout, {"bg"}):setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
    end

	--减金币
	self.btnMinCoin:setOnClick(self, function(self)
		if self.count > 1 then
			self.count = self.count - 1;
			self.btnMinCoin:setEnable( true );
		else
			self.count = 1;
		end

		if self.count == 1 then
			self.btnMinCoin:setEnable( false );
		end

		self.btnAddCoin:setEnable( true );
		self.textPropNum:setText(self.count);
		self.textAllPrice:setText(self.count * self.unitPrice .. "金币");
	end);
	self.btnAddCoin:setEnable( false );

	--加金币
	self.btnAddCoin:setOnClick(self, function(self)
		if self.count < self.m_maxNum then
			self.count = self.count + 1;
			self.btnAddCoin:setEnable( true );
		else
			self.count = self.m_maxNum;
		end

		if self.count == self.m_maxNum then
			self.btnAddCoin:setEnable( false );
		end

		self.btnMinCoin:setEnable( true );
		self.textPropNum:setText(self.count);
		self.textAllPrice:setText(self.count * self.unitPrice .. "金币");
	end);
end

RoomBuyPropWnd.setFreeMoney = function( self, freeMoney )
	self.m_freeMoney = freeMoney;
	self.m_maxNum = self:calculateMaxNum( self.m_freeMoney );
	local tenPrice = tonumber(self.unitPrice) * self.m_maxNum;
	self.textSinglePrice:setText(self.unitPrice .. "金币");
	self.textPropNum:setText(self.m_maxNum);
	self.count = self.m_maxNum;
	self.textAllPrice:setText(tenPrice .. "金币");
end

RoomBuyPropWnd.initView = function( self )
	self.btnClose = publ_getItemFromTree(self.layout, {"bg", "closeBtn"});
	self.btnOK = publ_getItemFromTree(self.layout, {"bg", "commitBtn"});
	self.btnAddCoin = publ_getItemFromTree(self.layout, {"bg", "windowFromBg","PlusBtn"});
	self.btnMinCoin = publ_getItemFromTree(self.layout, {"bg", "windowFromBg","LessBtn"});

	self.textUserMoney = publ_getItemFromTree(self.layout, {"bg", "windowFromBg", "PropFromImg", "PropImg"});
	self.textSinglePrice = publ_getItemFromTree(self.layout, {"bg", "windowFromBg", "UnitPriceText"});
	self.textAllPrice = publ_getItemFromTree(self.layout, {"bg", "windowFromBg", "TotalPriceText"});
	self.imgPropIcon = publ_getItemFromTree(self.layout, {"bg", "windowFromBg", "PropFromImg", "PropImg"});
	self.textPropNum = publ_getItemFromTree(self.layout, {"bg", "windowFromBg", "countPropImg", "numText"});
end

RoomBuyPropWnd.calculateMaxNum = function( self, money )
	if not money then
		return 1;
	end
	local num = math.floor( money / self.unitPrice );
	if num >= 10 then
		return 10;
	elseif num > 0 and num < 10 then
		return num;
	end
	return 1;
end

RoomBuyPropWnd.setConfirmCallBack = function(self, obj, objFunc)
	self.Confirmobj = obj;
	self.Func = objFunc;
end

RoomBuyPropWnd.dtor = function(self)
	self.unitPrice = nil;
end

