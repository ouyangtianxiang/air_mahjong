local createFriendRoomView = require(ViewLuaPath.."createFriendRoomView");

CreateFriendRoomView = class(SCWindow);
CreateFriendRoomView.instance = nil;

-- CreateFriendRoomView.getInstance = function()
-- 	if CreateFriendRoomView.instance == nil then 
-- 		CreateFriendRoomView.instance = new(CreateFriendRoomView);
-- 	end
-- 	return CreateFriendRoomView.instance;
-- end

CreateFriendRoomView.ctor = function ( self )
	self.diIndex = 3; -- diZhu chosen
	self.diNum   = 5; -- diZhu choices
	CreateFriendRoomView.instance = self;
	self:load();
end

CreateFriendRoomView.load = function (self)
	self.layout = SceneLoader.load(createFriendRoomView);
	self:addChild(self.layout);
	self:setWindowNode( self.layout );

	self.cover:setEventTouch(self, function(self)
	end);

	self.diBtn = {}; 
	for i=1, self.diNum do
		table.insert(self.diBtn, publ_getItemFromTree(self.layout, { string.format("di%d", i) }));
		self.diBtn[i]:setOnClick(self, function(self)

		end);
	end

	self.diNoBtn = {};
	for i=1, self.diNum do
		table.insert(self.diNoBtn, publ_getItemFromTree(self.layout, { string.format("di%dNo", i) }));
		self.diNoBtn[i]:setOnClick(self, function(self)
			self:diChoose(i);
		end);
	end

	self.closeBtn   = publ_getItemFromTree(self.layout, { "closeBtn" });
	self.closeBtn:setOnClick(self, function(self)
		-- popWindowUp(self, self.hideHandle, self.layout);
		self:hideWnd();
	end);

	self.confirmBtn = publ_getItemFromTree(self.layout, { "confirmBtn" });
	self.confirmBtn:setOnClick(self, function(self)
		GameConstant.isDirtPlayGame = true;
		self:enterRoom();
	end);

	self:diChoose(self.diIndex); -- init
end

-- 显示选取的底注
CreateFriendRoomView.diChoose = function(self, index)
	if index > self.diNum and index < 1 then
		return;
	end
	self.diIndex = index;

	for i=1,self.diNum do
		self.diBtn[i]:setVisible(self.diIndex == i);
		self.diNoBtn[i]:setVisible(not (self.diIndex == i));
	end
end

-- 请求进入房间
CreateFriendRoomView.enterRoom = function (self)
	local level = self:getLevelByRequire(self.diIndex);
	if not level then
		return;
	end

	if HallScene_instance then
		HallScene_instance:requireEnterRoom(level);
	end
end

-- 取得选取的场次
CreateFriendRoomView.getLevelByRequire = function ( self, diIndex )
	local diIndex = diIndex or 0;

	local roomData = HallConfigDataManager.getInstance():returnLevelFromHallConfigByDi(diIndex);
	if roomData then 
		return roomData.level;
	end
end
CreateFriendRoomView.hideHandle = function ( self )
	self:removeFromSuper();
end

CreateFriendRoomView.dtor = function(self)
	self:removeAllChildren();
	CreateFriendRoomView.instance = nil;
	CreateFriendRoomView.m_instance = nil;
	self = nil;
end

