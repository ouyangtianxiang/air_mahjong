local exchangeGoodesWindow = require(ViewLuaPath.."exchangeGoodesWindow");

ExchangeGoodsWindow = class(SCWindow);

ExchangeGoodsWindow.ctor = function(self)

    self.window = SceneLoader.load(exchangeGoodesWindow);
    self:addChild(self.window);

    self.img_win_bg = publ_getItemFromTree(self.window, {"bg"});
    self:setWindowNode( self.img_win_bg );
    
    self.PNumEdit  = publ_getItemFromTree(self.window,  ExchangeGoodsWindow.s_controlsMap["PNumEdit"]);
    self.NameEdit  = publ_getItemFromTree(self.window,  ExchangeGoodsWindow.s_controlsMap["NameEdit"]);
    self.AddrEdit  = publ_getItemFromTree(self.window,  ExchangeGoodsWindow.s_controlsMap["AddrEdit"]);

     self.btnClose = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["btnClose"]);
     self.btnClose:setOnClick(self, function(self)
        self:hideWnd();
        end
     );

     if PlatformConfig.platformWDJ == GameConstant.platformType or
        PlatformConfig.platformWDJNet == GameConstant.platformType then
         self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
         self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
         self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end

     self.btnOK = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["btnOK"]);
     self.btnOK:setOnClick(self, function(self)
        
		if self.OKFunc and self.OKObj then
			self.OKFunc(self.OKObj);
		end
      end
     );

     local phone1 = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone1"]);
     phone1:setOnClick(self, function(self)
            callPhone("4006331888");
          end);
     local phone2 = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone2"]);
     phone2:setOnClick(self, function(self)
            callPhone("075586166169");
          end);

     --调整字体位置
     local phone1TextX, phone1TextY = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone1"]):getPos();
     local phone1TextW, phone1TextH = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone1Text"]):getSize();

     local textOrX, textOrY= publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["textOr"]):getPos();
     publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["textOr"]):setPos(phone1TextX + 5 + phone1TextW, textOrY);

     local textOrW, textOrH = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["textOr"]):getSize();
     local textOrX, textOrY = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["textOr"]):getPos();

     local phone2X, phone2Y = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone2"]):getPos();
     publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone2"]):setPos(textOrX + textOrW + 5, phone2Y);

    --如果为起凡，将联系方式改为QQ
    if GameConstant.platformType == PlatformConfig.platformDingkai then
        self.phoneNum = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone1"]);
        self.phoneNum:setVisible(false);
        publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phone1"]):setVisible(false);
        self.QQ = publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["textOr"]);
        self.QQ:setText("QQ:2897738207");
        local x, y = self.QQ:getPos();
        self.QQ:setPos(x - 100, y);
    end
    self:showWnd();
end

--返回当前的电话信息
ExchangeGoodsWindow.getPhoneNum = function(self)
   return self.PNumEdit:getText();
end

--返回当前的地址信息
ExchangeGoodsWindow.getAddress = function(self)
    return self.AddrEdit:getText();
end

--返回当前的名字信息
ExchangeGoodsWindow.getName = function(self)
    return self.NameEdit:getText();
end

ExchangeGoodsWindow.setPhoneNum = function(self, phone)
   return self.PNumEdit:setText(phone);
end

ExchangeGoodsWindow.setAddress = function(self, address)
    return self.AddrEdit:setText(address);
end

ExchangeGoodsWindow.setName = function(self, name)
    return self.NameEdit:setText(name);
end
ExchangeGoodsWindow.setOKBtnName = function(self, name)
    publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["btnTitle"]):setText(name or "");
end
ExchangeGoodsWindow.setWindowName = function(self, name)
    publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["winTitle"]):setText(name or "");
end

ExchangeGoodsWindow.setPhoneEnable = function(self, enable)
   self.PNumEdit:setEnable(enable);
end
ExchangeGoodsWindow.setNameEnable = function(self, enable)
   self.NameEdit:setEnable(enable);
end
ExchangeGoodsWindow.setAddressEnable = function(self, enable)
   self.AddrEdit:setEnable(enable);
end

ExchangeGoodsWindow.setWarningVisible = function(self, visible)
   publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["phoneWarning"]):setVisible(visible);
   publ_getItemFromTree(self.window, ExchangeGoodsWindow.s_controlsMap["nameWarning"]):setVisible(visible);
end

ExchangeGoodsWindow.setOKCallBack = function(self, obj, func)
    
    self.OKFunc = func;
    self.OKObj = obj;
end

ExchangeGoodsWindow.hide = function(self)
    self:removeFromSuper();
end


ExchangeGoodsWindow.dtor = function ( self )
	self:removeAllChildren();
end

ExchangeGoodsWindow.s_controlsMap =
{
    ["btnClose"]           = {"bg", "view_top" ,"btnClose"},
    ["frameBgimg"]         = {"bg", "frameBgimg"},
    ["PNumEdit"]           = {"bg", "frameBgimg", "view_phone","img_phone_bg", "et_phone"},
    ["NameEdit"]           = {"bg", "frameBgimg", "view_name","img_name_bg", "et_name"},
    ["AddrEdit"]           = {"bg", "frameBgimg", "view_addr","img_addr_bg", "et_addr"},
    ["btnOK"]              = {"bg", "btnOK"},
    ["btnTitle"]           = {"bg", "btnOK", "text_title"},
    ["winTitle"]           = {"bg", "view_top", "text_title"},
    ["phoneWarning"]       = {"bg", "frameBgimg", "view_phone","text_warning"},
    ["nameWarning"]        = {"bg", "frameBgimg", "view_name","text_warning"},
    ["phone1"]             = {"bg", "frameBgimg", "btn_phone1"},
    ["phone1Text"]             = {"bg", "frameBgimg", "btn_phone1", "text_phone"},
    ["phone2"]             = {"bg", "frameBgimg", "btn_phone2"},
    ["phone2Text"]             = {"bg", "frameBgimg", "btn_phone2", "text_phone"},
    ["textOr"]             = {"bg", "frameBgimg", "text_or"},
    
};

