-- 淘汰弹窗
local eliminatedWnd = require(ViewLuaPath.."eliminatedWnd");
QuitPopWin = class(SCWindow);

QuitPopWin.ctor = function ( self, data, rootNode, timeFlag)
	if rootNode then
		rootNode:addChild(self);
	end

	self.myself = PlayerManager.getInstance():myself();

	--加载界面
	self.window = SceneLoader.load(eliminatedWnd);
	self:addChild(self.window);
	self:setVisible(false);

	self.bg = publ_getItemFromTree(self.window, {"img_win_bg"});
	self:setWindowNode( self.bg );

	publ_getItemFromTree(self.window,{"img_win_bg","img_inner_bg","rankNum"}):setText("" .. data.rank);
	publ_getItemFromTree(self.window,{"img_win_bg","btn_continue"}):setOnClick(self, self.onClickContinueBtn);
	publ_getItemFromTree(self.window,{"img_win_bg","btn_banckToHall"}):setOnClick(self, self.onClickBackToHallBtn);
	publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"}):setOnClick(self, self.onClickConfirmBtn);

	if timeFlag then
		publ_getItemFromTree(self.window,{"img_win_bg","btn_continue"}):setVisible(false);
		publ_getItemFromTree(self.window,{"img_win_bg","btn_banckToHall"}):setVisible(false);
		publ_getItemFromTree(self.window,{"img_win_bg","btn_confirm"}):setVisible(true);
		--publ_getItemFromTree(self.window,{"img_win_bg","img_inner_bg", "Text3"}):setText("您在" .. data.matchName .. "中被淘汰出局");
	end

	self:showWnd();
end

-- 继续报名按钮
QuitPopWin.onClickContinueBtn = function ( self )
	if HallScene_instance and HallScene_instance.matchApplyWindow then 
		self:hideWnd()
	end 

	local matchRoomData = HallConfigDataManager.getInstance():returnMatchDataByLevel(GameConstant.curRoomLevel);
	if not matchRoomData then 
		Banner.getInstance():showMsg("您的网络不稳定");
		self:onClickBackToHallBtn();
		return ;
	end

	local money = self.myself.money;
	if matchRoomData.offline > money then
		require("MahjongCommon/RechargeTip");
        local param_t = {t = RechargeTip.enum.enter_match, 
                isShow = true, roomlevel = GameConstant.curRoomLevel, money= matchRoomData.offline,
                recommend= matchRoomData.recommend,
                is_check_bankruptcy = true, 
                is_check_giftpack = true,};
        RechargeTip.create(param_t)
	elseif matchRoomData.exceed < money then
		local str = "      你的金币高于场区上限" .. tostring(matchRoomData.exceed) .. ", 是否要进入更高底注的比赛场？";
		local view = PopuFrame.showNormalDialog( "温馨提示", str, GameConstant.curGameSceneRef, nil, nil, true, false );
		view:setConfirmCallback(self, function ( self )
			GameConstant.continueMatchFlag = 1;
			self:onClickBackToHallBtn();
		end);
		if view then
			view:setCallback(view, function ( view, isShow )
				if not isShow then
					
				end
			end);
		end
	else
		GameConstant.continueMatchFlag = 1;
		self:onClickBackToHallBtn();
	end
end

-- 返回比赛场选择界面
QuitPopWin.onClickBackToHallBtn = function ( self )
	if RoomScene_instance then
		RoomScene_instance:backToMatchSelectView();
	end
	PlayerManager.getInstance():myself().isInGame = false;
end

QuitPopWin.onClickConfirmBtn = function ( self )
	if HallScene_instance and HallScene_instance.matchApplyWindow then 
		self:hideWnd()
	elseif HallScene_instance then
		HallScene_instance:closeAllPopuWnd();
	else
		self:onClickBackToHallBtn();
	end

end


QuitPopWin.hide = function(self)
	CustomNode.hide(self);
end

QuitPopWin.dtor = function ( self )
	-- self:removeAllChildren();
end