--[[ 
	YiXinFriendRankItem.lua
	Author: YifanHe
	Date: 2014-02-18
	Last modification : 2014-02-18
	Description:今日巅峰榜中玩家展示节点类
]]--
local yifriendItem = require(ViewLuaPath.."yifriendItem");

YiXinFriendRankItem = class(Node)

YiXinFriendRankItem.ctor = function(self, data)
	if not data then
		return;
	end

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	self.m_event = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(self.m_event,self,self.onHttpRequestsCallBack);

	self.listItem = SceneLoader.load(yifriendItem);
	self:addChild(self.listItem);


	self:setSize(self.listItem:getSize());

	self.data = data;

	self:getAllControls();

	if data.icon and data.icon ~= "" and data.icon ~= " " then 
		local isExist , localDir = NativeManager.getInstance():downloadImage(data.icon);
		self.localDir = localDir; -- 下载图片
		if not isExist then
		    if tonumber(kSexMan) == tonumber(data.sex) then
		       localDir = "Login/yx/Commonx/default_man.png";
		   else
		       localDir = "Login/yx/Commonx/default_woman.png";
		   end
		end
		self.m_headBg:setFile(localDir);
		setMaskImg(self.m_headBg,"Hall/hallRank/head_mask.png",localDir)

	else
		if data.sex == 1 then  -- 男人
			self.m_headBg:setFile("Login/yx/Commonx/default_man.png");
		else
			self.m_headBg:setFile("Login/yx/Commonx/default_woman.png");
		end
	end

	if data.rankNum then 
		if tonumber(data.rankNum) <=3 then 

			self.m_placeBg:setVisible(false);
			self.m_placeImg:setVisible(true);

			self.m_placeImg:setFile("Hall/hallRank/place_" .. data.rankNum .. ".png");
		elseif tonumber(data.rankNum) > 3 then 
			self.m_placeImg:setVisible(false);
			self.m_placeBg:setVisible(true);
			self.m_placeText:setText(data.rankNum .. "");
			self.m_placeText:setColor(255,255,255);
		end
	end

	if data.mnick then
		self.m_nick:setText(stringFormatWithString(data.mnick, 12, true));
	end

	if data.money then 
		self.m_coin:setText(trunNumberIntoThreeOneFormWithInt(data.money) or 0);
	end

	if data.titleStr then
		self.m_rightWealth:setFile("Hall/hallRank/wealth_level_" .. data.titleStr .. ".png");
	end

	if data.ingame then 
		self.m_rightWealth:setVisible(true);
		self.m_rightInviteBtn:setVisible(false);
	else
		self.m_rightWealth:setVisible(false);
		self.m_rightInviteBtn:setVisible(true);
		self.m_rightInviteBtn:setOnClick(self,self.onInviteClick)
	end

end

YiXinFriendRankItem.getAllControls = function(self)
	self.m_placeImg = publ_getItemFromTree(self.listItem,{"item_view","place_img"});
	self.m_placeBg = publ_getItemFromTree(self.listItem,{"item_view","view_place"});
	self.m_placeText = publ_getItemFromTree(self.listItem,{"item_view","view_place","Text2"});
	self.m_headBg = publ_getItemFromTree(self.listItem,{"item_view","head_bg"});
	self.m_nick = publ_getItemFromTree(self.listItem,{"item_view","nick"})
	self.m_coin = publ_getItemFromTree(self.listItem,{"item_view","coin"});
	self.m_rightWealth = publ_getItemFromTree(self.listItem,{"item_view","wealth"});
	self.m_rightInviteBtn = publ_getItemFromTree(self.listItem,{"item_view","inviteBtn"});


end

YiXinFriendRankItem.onInviteClick = function(self)
	if not self.data then 
		return ;
	end

	self.m_rightInviteBtn:setFile("Commonx/gray_small_btn.png");
	self.m_rightInviteBtn:setPickable(false);
	self.m_rightInviteBtn:setGray(true);


	local date = os.date("%x");

	g_DiskDataMgr:setAppData("yixin_date" .. self.data.accountId,date);

 	local param = {};
	param.accessToken = GameConstant.accessToken;
	param.account = self.data.accountId;
	HttpModule.getInstance():execute(HttpModule.s_cmds.inviteYiXinFriend, param, self.m_event);
end

YiXinFriendRankItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(self.m_event,self,self.onHttpRequestsCallBack);
	self:removeAllChildren();
end

YiXinFriendRankItem.onHttpRequestsCallBack = function (self, command, isSuccess, data, jsonData)
	Loading.hideLoadingAnim();
	if not isSuccess or not data then
        return;
    end
	if HttpModule.s_cmds.inviteYiXinFriend == command and isSuccess then
		if not data then 
			return ;
		end
		local money = data.data.money or 0;
		local msg = data.msg
		if money > 0 then 
			AnimationAwardTips.play(msg);
			showGoldDropAnimation();
			local param = {};
			param.type = GlobalDataManager.UI_UPDATA_MONEY;
			param.money = money;
			EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent,param);
		else
			Banner.getInstance():showMsg(msg);
		end
	end
end


YiXinFriendRankItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	self.m_headBg:setFile(self.localDir);
            setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png",self.localDir)
            --:setFile(self.localDir);
        end
    end
end


