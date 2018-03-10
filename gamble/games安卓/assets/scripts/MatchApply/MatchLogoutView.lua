local logoutMatchLayout = require(ViewLuaPath.."logoutMatchLayout");

MatchLogoutView = class(SCWindow);

MatchLogoutView.ctor = function ( self, rootNode, str1, str2, str3)
    self.rootNode = rootNode;
    self.str1 = str1;
    self.str2 = str2;
    self.str3 = str3;
    self:load();
    self:showWnd();
    

end

MatchLogoutView.dtor = function (self)
    DebugLog("[MatchLogoutView]:dtor");
end


MatchLogoutView.setCancelExitCallback = function ( self, obj, func )
    self._cancelObj  = obj
    self._cancelFunc = func
end

MatchLogoutView.load = function ( self )
    self.layout = SceneLoader.load(logoutMatchLayout);
    self:addChild(self.layout);
    self.cover:setEventTouch(self,function(self)
    end);

    self.bg = publ_getItemFromTree(self.layout, {"bgImage"});
    self.btnClose = publ_getItemFromTree(self.layout, {"bgImage", "btnClose"});
    self.btnOk = publ_getItemFromTree(self.layout, {"bgImage", "btnOk"});
    self.btnCancel = publ_getItemFromTree(self.layout, {"bgImage", "btnCancel"});
    self.Text1 = publ_getItemFromTree(self.layout, {"bgImage", "framImg", "Text1"});
    self.Text2 = publ_getItemFromTree(self.layout, {"bgImage", "framImg", "Text2"});
    self.Text3 = publ_getItemFromTree(self.layout, {"bgImage", "framImg", "Text3"});

    self:setWindowNode(self.bg);

    if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then  
        self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
        self.bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end


    self.btnCancel:setOnClick(self, function(self)
        DebugLog("ttt cancel");
        self:hideWnd()
    end);

    self.btnClose:setOnClick(self, function(self)
        DebugLog("ttt close");
        self:hideWnd()
    end);

    self.btnOk:setOnClick(self, function(self)
        DebugLog("ttt ok");
        if MatchRoomScene_instance then -- 定时赛预赛房间内退出
            MatchRoomScene_instance:exitGame();
        else -- 人满赛/定时赛报名界面退出
            self.rootNode:onGoBackSelectPlaySpace();
        end
    end);

    self.Text1:setText(self.str1);
    self.Text2:setText(self.str2);
    self.Text3:setText(self.str3);
end

MatchLogoutView.onWindowHide = function ( self )

    self.super.onWindowHide(self)
    if self._cancelObj and self._cancelFunc then 
        self._cancelFunc(self._cancelObj)
    end 
end
