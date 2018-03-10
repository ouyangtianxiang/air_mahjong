local matchHelpLayout = require(ViewLuaPath.."matchHelpLayout");

MatchHelpView = class(SCWindow);

MatchHelpView.ctor = function(self, data)
    self.m_data = data;

    self.window = SceneLoader.load(matchHelpLayout);
    self:addChild(self.window);
    self:setWindowNode(self.window);

    self.img_win_bg = publ_getItemFromTree(self.window, {"bgImage"});
    makeTheControlAdaptResolution(self.img_win_bg);
    --禁止窗外关闭
    self.window:setEventTouch(self, function ( self )
    end);

    self.btnClose = publ_getItemFromTree(self.window, MatchHelpView.s_controlsMap["btnClose"]);
    self.btnClose:setOnClick(self, function(self)
        self:hideWnd();
    end);

    --动态根据data的值生成控件显示
    self.helpScrollView = publ_getItemFromTree(self.window, MatchHelpView.s_controlsMap["helpScrollView"]);
    local w, h = self.helpScrollView:getSize();
    local str = self.m_data;
     
    local descText = new(TextView, str, w, h, kAlignLeft, nil, 30, 0x94, 0x32, 0x00);
    self.helpScrollView:addChild(descText);
    self.helpScrollView:setSize(w, h);

    if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.btnClose:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.btnClose.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
        self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_mid.png");
    end
    self:showWnd();
end

MatchHelpView.dtor = function ( self )

end

MatchHelpView.s_controlsMap =
{
    ["btnClose"]           = {"bgImage", "btnClose"},
    ["helpScrollView"]     = {"bgImage", 'helpFormBgImg', "helpScrollView"},
};

