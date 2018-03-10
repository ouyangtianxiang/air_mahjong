--[[
	className    	     :  BoyaaLoginView
	Description  	     :  界面类--博雅通行证登录
	last-modified-date   :  Oct.29 2013
	create-time 	   	 :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]

require("MahjongPlatform/PlatformConfig");
require("MahjongCommon/CustomNode");
require("MahjongLogin/LoginMethod/BoyaaLogin");
local bindPopWindow = require(ViewLuaPath.."bindPopWindow");

BoyaaLoginView = class(SCWindow);

--[[
	function name	   : BoyaaLoginView.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
					   : hallRef   	 	table  -- 大厅界面引用.
	last-modified-date : Oct.29 2013
	create-time  	   : Oct.29 2013
]]
BoyaaLoginView.ctor = function ( self,hallRef)

	self.hallRef = hallRef;
	--加载界面
	self.window = SceneLoader.load(bindPopWindow);
	self:addChild(self.window);


	self.bg = publ_getItemFromTree(self.window, {"img_win_bg"});
	self:setWindowNode( self.bg );

	--设置关闭事件
	publ_getItemFromTree(self.window,{"img_win_bg","btn_close"}):setOnClick(self, function ( self )
		self:hideWnd();
	end);


	--设置个人信息
	local nameStr	= kNullStringStr;--昵称
	local imgStr 	= kNullStringStr; --头像
	local money 	= CreatingViewUsingData.commonData.coinStr .. CreatingViewUsingData.commonData.maoHaoStr .. kNullStringStr;
	local player 	= PlayerManager.getInstance():myself();

	if GameConstant.isLogin == kAlreadyLogin then --表示已经登陆
		--这边需要加上如果有用户的图片，给上用户的图片
		if player.large_image then 
            local isExist , localDir = NativeManager.getInstance():downloadImage(player.large_image);
			self.localDir = localDir;
            imgStr = localDir;
		    if not isExist then -- 图片已下载
		        if tonumber(player.sex) == kNumZero then  
			        imgStr = CreatingViewUsingData.commonData.boyPicLocate;
		        else
			        imgStr = CreatingViewUsingData.commonData.girlPicLocate;
		        end
		    end
		end
		nameStr = player.nickName or kNullStringStr;
		money = money .. (trunNumberIntoThreeOneFormWithInt(player.money) or kNumZero);
	end

	if imgStr ~= kNullStringStr then 
		publ_getItemFromTree(self.window,{"img_win_bg", "img_win_inner_bg", "img_headicon"}):setFile(imgStr);
	end

	--设置昵称
	publ_getItemFromTree(self.window,{"img_win_bg", "img_win_inner_bg", "text_name"}):setText(stringFormatWithString(nameStr,20,true));
	publ_getItemFromTree(self.window,{"img_win_bg", "img_win_inner_bg", "text_coin"}):setText(money);

	--设置注册/登录
	publ_getItemFromTree(self.window,{"img_win_bg", "img_win_inner_bg", "btn_register"}):setOnClick(self,self.boyaaRegist);
	publ_getItemFromTree(self.window,{"img_win_bg", "img_win_inner_bg", "btn_login"}):setOnClick(self,self.boyaaLogin);
	
	self:showWnd();
end

--[[
	function name	   : BoyaaLoginView.deleteSelf
	description  	   : 删除博雅通行证方法.
	param 	 	 	   : self
	last-modified-date : Oct.29 2013
	create-time  	   : Oct.29 2013
]]
BoyaaLoginView.deleteSelf = function(self)
	self.hallRef.boyaaLoginView = nil;
	self:setVisible(false);
	if self.m_parent then 
		self.m_parent:removeChild(self,true);
	end
end

--[[
	function name	   : BoyaaLoginView.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Oct.29 2013
	create-time  	   : Oct.29 2013
]]
BoyaaLoginView.dtor = function ( self )
	self:removeAllChildren();
end

-----------------------------------------------------------按键监听--------------------------------------------------------------
--[[
	function name	   : BoyaaLoginView.boyaaLogin
	description  	   : 博雅通行证登录监听.
	param 	 	 	   : self
	last-modified-date : Oct.29 2013
	create-time  	   : Oct.29 2013
]]
BoyaaLoginView.boyaaLogin = function(self)
	if PlatformConfig.BoyaaLogin == PlatformFactory.curPlatform.curLoginType then
		PlatformFactory.curPlatform:logout();
	else
		PlatformFactory.curPlatform:clearCurUserGameData();
	end
	PlatformFactory.curPlatform:login(PlatformConfig.BoyaaLogin);
	self:deleteSelf();
end

--[[
	function name	   : BoyaaLoginView.boyaaRegist
	description  	   : 博雅通行证注册监听.
	param 	 	 	   : self
	last-modified-date : Oct.29 2013
	create-time  	   : Oct.29 2013
]]
BoyaaLoginView.boyaaRegist = function(self)
	PlatformFactory.curPlatform:getLoginUtl(PlatformConfig.BoyaaLogin):regist();
	self:deleteSelf();
end





