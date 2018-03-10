
CreateUserWindow = class(SCWindow)

CreateUserWindow.ctor = function ( self )
	self:loadData()

	self:initView()
end

CreateUserWindow.dtor = function ( self )
	self:removeAllChildren();
end

function CreateUserWindow:initView(  )
	-- body
	self._bg  = new(Image,"Commonx/pop_window_big.png",0,0)
	self._bg:setAlign(kAlignCenter)


	self:setWindowNode( self._bg );
	self:setCoverEnable( false );-- 允许点击cover

	local btnText = new( Text, "创建游客账号", 0, 0, kAlignCenter, nil, 34, 0xff, 0xff, 0xff);
	btnText:setPos(0,30)
	btnText:setAlign(kAlignTop)
	self._bg:addChild(btnText)

	local closeBtn = new(Button,"Commonx/close_btn.png","Commonx/close_btn_disable.png")
	closeBtn:setPos(-25,-25)
	closeBtn:setAlign(kAlignTopRight)
	self._bg:addChild(closeBtn)
	closeBtn:setOnClick(self,function ( self )
		self:saveData()
		self:hideWnd()
	end)

	self:createNewBtn()
	self:createResetGuestButton();

    self._sv = new(ScrollView, 0, 0, 960, 440, false);
    self._sv:setDirection(kVertical);
    self._sv:setPos(40,150)

    self:addChild(self._bg)
    self._bg:addChild(closeBtn)
    self._bg:addChild(self._sv)

    for i=1,#self.idlist do
    	self:createItem(self.idlist[i],i-1)
    end
end

function CreateUserWindow:createNewBtn()
	local btn = new(Button,"Commonx/green_small_btn.png")
	btn:setPos(-200,100)
	btn:setAlign(kAlignTop)
	self._bg:addChild(btn)
	btn:setOnClick(self,function ( self )
		self:createNewId()
	end)

	local btnText = new( Text, "创建新账号", 0, 0, kAlignCenter, nil, 26, 0xff, 0xff, 0xff);
	btnText:setPos(0,-4)
	btnText:setAlign(kAlignCenter)
	btn:addChild(btnText)
end

function CreateUserWindow:createResetGuestButton()
	local btn = new(Button,"Commonx/green_small_btn.png")
	btn:setPos(200,100)
	btn:setAlign(kAlignTop)
	self._bg:addChild(btn)
	btn:setOnClick(self,function ( self )
		self:resetGuestButtonTouch()
	end)

	local btnText = new( Text, "还原游客", 0, 0, kAlignCenter, nil, 26, 0xff, 0xff, 0xff);
	btnText:setPos(0,-4)
	btnText:setAlign(kAlignCenter)
	btn:addChild(btnText)
end

function CreateUserWindow:resetGuestButtonTouch()
	self.chooseuid = "";
	self:prepareGuestLogin();
	self:hideWnd()
end

function CreateUserWindow:createItem( id,index )
	local node = new(Node)
	node:setSize(960,80)

	local btn  = new(Button,"Commonx/green_small_btn.png")
	btn:setAlign(kAlignRight)
	btn:setOnClick(self,self.selectedUser)
	node:addChild(btn)
	btn.__tag  = id or ""

	local btnText = new( Text, "选 择", 0, 0, kAlignCenter, nil, 26, 0xff, 0xff, 0xff);
	btnText:setPos(0,-4)
	btnText:setAlign(kAlignCenter)
	btn:addChild(btnText)

	if tostring(id)==tostring(self.chooseuid) then
		btnText:setText("当前的选择",0,0,0xff0000,0,0);
	end

	local idText  = new( Text, tostring(id), 0, 0, kAlignLeft, nil, 30, 0x4b, 0x2b, 0x1c);
	idText:setAlign(kAlignLeft)
	idText:setPos(0,0)
	node:addChild(idText)

	node:setPos(0, (index or #self.idlist)*80)

	self._sv:addChild(node)
end

function CreateUserWindow:createNewId( )
	local regTime = os.time()..math.random(1000,9000)
	self:createItem(regTime)
	table.insert(self.idlist, regTime)
	DebugLog(regTime);
end


function CreateUserWindow:selectedUser( finger_action,x,y,drawing_id_first,drawing_id_current,sender )

	if not sender then
		return
	end

	GameConstant.NewUserLoginRegTime = string.sub(sender.__tag or "1234",1,4)
	DebugLog("GameConstant.NewUserLoginRegTime:"..GameConstant.NewUserLoginRegTime);
	self.chooseuid = sender.__tag;
	self:prepareGuestLogin();
	self:hideWnd()
end

function CreateUserWindow:prepareGuestLogin ()
	self:saveData();
	local loginMethod = PlatformConfig.GuestLogin
	if loginMethod == GameConstant.lastLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	Loading.showLoadingAnim("登录中...");
	--如果socket断开了 需连socket
	if not SocketManager.m_isRoomSocketOpen then
		SocketManager.getInstance():openSocket(loginMethod)
	else
		PlatformFactory.curPlatform:login(loginMethod);
	end
end

function CreateUserWindow:hideWnd(... )
	--在其他地方去了
	--self:saveData()
	self.super.hideWnd(self,...)
end

function CreateUserWindow:saveData()
	DebugLog("CreateUserWindow:saveData")
	DebugLog(self.idlist)
	local locallist = {};
	locallist.uidlist = self.idlist;
	locallist.chooseuid = self.chooseuid or "";
	local ids  = json.encode(locallist)
	g_DiskDataMgr:setFileKeyValue(GameConstant.CreateGuestInfoMapListKey,"userid",ids)
	DebugLog(locallist);
end

function CreateUserWindow:loadData()
	local ids   = g_DiskDataMgr:getFileKeyValue(GameConstant.CreateGuestInfoMapListKey,"userid","")
	local locallist = json.mahjong_decode_node(ids) or {};
	self.idlist = locallist.uidlist or {};
	self.chooseuid = locallist.chooseuid or "";
	DebugLog("CreateUserWindow:loadData")
	DebugLog(locallist)
end
