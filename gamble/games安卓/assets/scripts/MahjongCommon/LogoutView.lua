local logoutViewLayout = require(ViewLuaPath.."logoutViewLayout");
require("uiex/richText");
LogoutView = class(SCWindow);

LogoutView.ctor = function ( self , _delegate )
	self.delegate = _delegate;
	self:show();
end

--[[

    local bg = UICreator.createImg("Hall/hallComon/hallBgMid.jpg",0,0)
    bg:addToRoot()
    local str =  5 
    local richText = new(RichText, str, 330, 0, kAlignLeft, nil, 26, 0x68, 0x3a, 0x23, true);
    richText:addToRoot()
    richText:setPos(100,100)
]]

LogoutView.resetNum = function ( self, value )
	local preStr = "亲,您再玩#cD22819#s36 "
	local numStr = tostring(value or 5)
	local str    = " #c683A23#s24局就可以开启宝箱了！话费、金币、道具奖励任你抽，您确定要放弃这次机会并退出游戏吗？"

	if not self.richText then 
		self.richText = new(RichText, preStr..numStr..str, 330, 0, kAlignLeft, nil, 26, 0x68, 0x3a, 0x23, true);
		self.richText:setPos(0,0)
		self.textNode:addChild(self.richText)
	else 
		self.richText:setText(preStr..numStr..str)
	end 

end

LogoutView.show = function ( self )
	self.window = SceneLoader.load(logoutViewLayout);
	self:addChild(self.window);

	self.img_win_bg = publ_getItemFromTree(self.window, {"img_win_bg"});
	self:setWindowNode( self.img_win_bg );

	self.closeBtn    = publ_getItemFromTree(self.window , LogoutView.s_controlsMap["closeBtn"]);
	self.leftBtn 	 = publ_getItemFromTree(self.window , LogoutView.s_controlsMap["leftBtn"]);
	self.rightBtn 	 = publ_getItemFromTree(self.window , LogoutView.s_controlsMap["rightBtn"]);

	self.textNode    = publ_getItemFromTree(self.window,  LogoutView.s_controlsMap["textNode"]);

	self:resetNum(tostring(GlobalDataManager.getInstance().lastChestRemainNum))
	--self.numText:setText()



	self.closeBtn:setOnClick(self , function ( self )
		self:hideWnd();
	end);
	self.leftBtn:setOnClick(self , function ( self )
		native_muti_exit()
		self:hide();
	end)
	self.rightBtn:setOnClick(self , function ( self )
		self:onClickedSureBtn()
	end)

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
        self.closeBtn:setFile("Login/wdj/Hall/Commonx/close_btn.png");
        self.closeBtn.disableFile = "Login/wdj/Hall/Commonx/close_btn_disable.png";
        self.img_win_bg:setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
        --publ_getItemFromTree(self.window,{"img_win_bg","img_win_inner_bg"}):setFile("Login/wdj/Hall/Commonx/innerBg.png");
    end
	self:showWnd();
end

LogoutView.onClickedSureBtn = function ( self )
	local tolevel = GlobalDataManager.getInstance().lastRoomlevel or 0
	local data,levelType = HallConfigDataManager.getInstance():returnDataByLevel(tolevel)
	
	if data and levelType and (levelType == "xl" or levelType == "xz" or levelType == "lfp") then 
		--
		local myMoney = tonumber(PlayerManager.getInstance():myself().money)
		local requireMoney = tonumber(data.require or 0)
		local exceedMoney  = tonumber(data.exceed or data.uppermost or 0)
		if myMoney >= requireMoney and myMoney <= exceedMoney then 
			self.delegate:toRoom(tolevel)
		else
			self.delegate:onClickedQuickStartBtn();
		end 	
	else 
		self.delegate:onClickedQuickStartBtn();
	end 
	self:hide();
end
LogoutView.dtor = function ( self )
	self.delegate.logoutView = nil;
	self:removeAllChildren();
end

LogoutView.s_controlsMap = {
	["closeBtn"]     		= {"img_win_bg","btn_close"},
	["leftBtn"]     		= {"img_win_bg","btn_left"},
	["rightBtn"] 			= {"img_win_bg","btn_right"},
	["textNode"]   		    = {"img_win_bg","View1"},

}


