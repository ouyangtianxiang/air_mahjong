local needTeachLayout = require(ViewLuaPath.."needTeachLayout");

NeedTeachView = class(CustomNode)

NeedTeachView.ctor = function (self , root)
	self.root = root;
	self.cover:setEventTouch(self , function (self)
		
	end);

	self.layout = SceneLoader.load(needTeachLayout);
	self:addChild(self.layout);

	local cancelBtn = publ_getItemFromTree(self.layout, {"bgview" ,"btn_close"});
	cancelBtn:setOnClick(self , function ( self )
		self.root:removeChild(self , true);
		new_pop_wnd_mgr.get_instance():hide_and_show( "NeedTeachView" );
	end);
	local doNotNeedBtn = publ_getItemFromTree(self.layout, {"bgview" , "notNeedTeach"});
	doNotNeedBtn:setOnClick(self , function ( self )
		if not SocketManager.getInstance().m_isRoomSocketOpen then
			Banner.getInstance():showMsg("正在连接服务器");
			return;
		end
		if self.root:requestQuickStartGame() then
			GameConstant.isDirtPlayGame = true;
		end
		self.root:removeChild(self , true);
		
	end);
	local NeedBtn = publ_getItemFromTree(self.layout, {"bgview" , "needTeach"});
	NeedBtn:setOnClick(self , function ( self )
		self.root:removeChild(self , true);
		self.root:clickTeachHelp();
		-- 教学完成后显示首冲
	end);
end

NeedTeachView.dtor = function (self)
	self:removeAllChildren();
end

