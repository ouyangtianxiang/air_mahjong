local pswInputLayout = require(ViewLuaPath.."pswInputLayout");
InputPswWindow = class(SCWindow);

InputPswWindow.ctor = function ( self )
	self.layout = SceneLoader.load(pswInputLayout);
	self:addChild(self.layout);
	self.inputText = publ_getItemFromTree(self.layout, { "inputBg", "pswInput"});
	self.confirmBtn = publ_getItemFromTree(self.layout, { "confirm" });
	self.cancelBtn = publ_getItemFromTree(self.layout, { "cancel" });
	self.bg = publ_getItemFromTree(self.layout, { "bg" });
	self:setAutoRemove( false );
	self:setWindowNode( self.layout );

	self.cancelBtn:setOnClick(self, function ( self )
		self:hideWnd();
	end);

	 if PlatformConfig.platformWDJ == GameConstant.platformType or 
		PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.cancelBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.cancelBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
        self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
    end

	self.confirmBtn:setOnClick(self, function ( self )
		self:setVisible(false);
		if self.confirmCallback then
			self.confirmCallback(self.confirmObj, publ_trim(self.inputText:getText() or ""));
		end
	end);
	self.inputText:setHintText("请输入密码", 150, 40, 40);
	self.confirmCallback = nil;
	self.confirmObj = nil;
end

InputPswWindow.show = function ( self )
	self:showWnd();
end

InputPswWindow.setConfirmCallback = function ( self, obj, fun )
	self.confirmCallback = fun;
	self.confirmObj = obj;
end

InputPswWindow.dtor = function ( self )
	self:removeAllChildren();
end

