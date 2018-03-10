--[[ 
	YiXinRankWindow.lua
	Author: ClarkWu
	Date: 2015-03-11
	Last modification : 2015-03-11
	Description:好友榜
]]--
local yxRankCommon = require(ViewLuaPath.."yxRankCommon");

require("MahjongCommon/MahjongListView");
require("MahjongCommon/CustomNode");
require("MahjongHall/Rank/YiXinFriendRankItem")
require("MahjongHall/Rank/YiXinGlobalRankItem");


YiXinRankWindow = class(CustomNode);

local STATE_NONE 	= 0;
local STATE_FRIEND 	= 1;
local STATE_GLOBAL 	= 2;

YiXinRankWindow.ctor = function ( self, delegate )
	self.delegate = delegate;

	self.cover:setEventTouch(self , function (self)
		
	end);

	--tab
	self.mainContent = SceneLoader.load(yxRankCommon);
	self:addChild(self.mainContent);

	self.m_mid = PlayerManager.getInstance():myself().mid or 0;
	self.m_player = PlayerManager.getInstance():myself();

	self.m_event = EventDispatcher.getInstance():getUserEvent();

	EventDispatcher.getInstance():register(self.m_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self:getAllControls();

	self.returnBtn:setOnClick(self, self.clickReturnBtn);

	self.myself = PlayerManager.getInstance():myself();

	self.m_state = STATE_NONE;
	
	-- --好友榜
	self.m_rankFriendBtn:setOnClick(self,self.clickFriendBtn);

	-- --全国榜
	self.m_rankGlobalBtn:setOnClick(self,self.clickGlobalBtn);

	self.m_rankFriendBtn:setType(Button.Gray_Type)
	self.m_rankGlobalBtn:setType(Button.Gray_Type)

	self.delegate.m_mainView:addChild(self);
	self:show();
end

YiXinRankWindow.getAllControls = function ( self )
	self.tabView 					= publ_getItemFromTree(self.mainContent, {"content"});
	self.returnBtn 					= publ_getItemFromTree(self.mainContent, {"retBtn"});
	--tab
	self.m_rankFriendBtn 			= publ_getItemFromTree(self.tabView, {"tab_view","tab_2"});
	self.m_rankGlobalBtn 			= publ_getItemFromTree(self.tabView, {"tab_view","tab_3"});

	self.m_rankFriendSelected 		= publ_getItemFromTree(self.tabView, {"tab_view","tab2_selected"});
	self.m_rankGlobalSelected 		= publ_getItemFromTree(self.tabView, {"tab_view","tab3_selected"});

	self.m_rankFriendView 			= publ_getItemFromTree(self.tabView, {"friendView"});
	self.m_rankFriendListView 		= publ_getItemFromTree(self.tabView, {"friendView", "top_view", "listview"});
	self.m_rankGlobalFriendView 	= publ_getItemFromTree(self.tabView, {"globalView"});
	self.m_rankGlobalFriendListView = publ_getItemFromTree(self.tabView, {"globalView", "top_view", "listview"});

	self.m_rankFriendBottomView 	= publ_getItemFromTree(self.tabView, {"friendView","bottom_view"});
	self.m_rankFriendBottomNotChamp = publ_getItemFromTree(self.tabView, {"friendView","bottom_view","img_place"});
	self.m_rankFriendBottomNotChampT = publ_getItemFromTree(self.tabView, {"friendView","bottom_view","img_place","Text3"});
	self.m_rankFriendBottomChamp 	= publ_getItemFromTree(self.tabView, {"friendView","bottom_view","champion"});
	self.m_rankFriendBottomHeadBg	= publ_getItemFromTree(self.tabView, {"friendView","bottom_view","head_bg"});
	self.m_rankFriendBottomName 	= publ_getItemFromTree(self.tabView, {"friendView","bottom_view","my_name"});
	self.m_rankFriendBottomCoin 	= publ_getItemFromTree(self.tabView, {"friendView","bottom_view","my_coin"});
	self.m_rankFriendChamp 			= publ_getItemFromTree(self.tabView, {"friendView","bottom_view","champion_img"});
	self.m_rankFriendNoFriend 		= publ_getItemFromTree(self.tabView, {"friendView", "top_view", "no_text_view"});

	self.m_rankGlobalBottomView 	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view"});
	self.m_rankGlobalBottomNotChamp = publ_getItemFromTree(self.tabView, {"globalView","bottom_view","img_place"});
	self.m_rankGlobalBottomNotChampT = publ_getItemFromTree(self.tabView, {"globalView","bottom_view","img_place","Text3"});
	self.m_rankGlobalBottomChamp 	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view","champion"});
	self.m_rankGlobalBottomHeadBg	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view","head_bg"});
	self.m_rankGlobalBottomName 	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view","my_name"});
	self.m_rankGlobalBottomCoin 	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view","my_coin"});
	self.m_rankGlobalChamp        	= publ_getItemFromTree(self.tabView, {"globalView","bottom_view","champion_img"});	
	self.m_rankGlobalNoFriend 		= publ_getItemFromTree(self.tabView, {"globalView", "top_view", "no_text_view"});
end

YiXinRankWindow.updataUIByGlobalEvent = function(self,param)
	if param and param.type == GlobalDataManager.UI_UPDATA_MONEY then

		self.myself.money = self.myself.money+param.money;
		if self.m_state == STATE_FRIEND then 
			self.m_rankFriendBottomCoin:setText(trunNumberIntoThreeOneFormWithInt(self.myself.money ,false))
		elseif self.m_state == STATE_GLOBAL then 
			self.m_rankGlobalBottomCoin:setText(trunNumberIntoThreeOneFormWithInt(self.myself.money ,false))
		end
    end
end

YiXinRankWindow.clickFriendBtn = function(self)
	self.m_state = STATE_FRIEND;

	self.m_rankFriendSelected:setVisible(true);
	self.m_rankGlobalSelected:setVisible(false);
	self.m_rankFriendBtn:setEnable(false);
	-- self.m_rankFriendBtn:setColor(255,255,255);
	self.m_rankGlobalBtn:setEnable(true);

	self.m_rankFriendView:setVisible(true);
	self.m_rankFriendListView:setVisible(true);
	self.m_rankGlobalFriendView:setVisible(false);
	self.m_rankGlobalFriendListView:setVisible(false);

	self.m_rankFriendBottomView:setVisible(true);
	self.m_rankGlobalBottomView:setVisible(false);

	if self.m_rankFriendadapter then 
		self.m_rankFriendListView:setAdapter(self.m_rankFriendadapter);
		self.m_rankFriendListView:setVisible(true);
		self.m_rankFriendNoFriend:setVisible(false);
	else
		self:requestRankReward(0);
	end

end

YiXinRankWindow.clickGlobalBtn = function(self)
	self.m_state = STATE_GLOBAL;

	self.m_rankFriendSelected:setVisible(false);
	self.m_rankFriendBtn:setEnable(true);
	self.m_rankGlobalSelected:setVisible(true);
	self.m_rankGlobalBtn:setEnable(false);
	-- self.m_rankGlobalBtn:setColor(255,255,255);

	self.m_rankFriendView:setVisible(false);
	self.m_rankFriendListView:setVisible(false);
	self.m_rankGlobalFriendView:setVisible(true);
	self.m_rankGlobalFriendListView:setVisible(true);

	self.m_rankFriendBottomView:setVisible(false);
	self.m_rankGlobalBottomView:setVisible(true);

	if self.m_rankglobalAdapter then 
		self.m_rankGlobalFriendListView:setAdapter(self.m_rankglobalAdapter);
		self.m_rankGlobalNoFriend:setVisible(false);
		self.m_rankGlobalFriendListView:setVisible(true);
	else
		self:requestRankReward(1);
	end

end

YiXinRankWindow.createFriendList = function(self,data)
	if data or #data > 0 then
		self.m_rankFriendadapter = new(CacheAdapter, YiXinFriendRankItem, data);
		self.m_rankFriendListView:setAdapter(self.m_rankFriendadapter);
		self.m_rankFriendListView:setVisible(true);
		self.m_rankFriendNoFriend:setVisible(false);
	else
		self.m_rankFriendNoFriend:setVisible(true);
		self.m_rankFriendListView:setVisible(false);
	end
end

YiXinRankWindow.updateGlobalData = function(self,myData)
	if not myData then 
		-- 没有数据的话
		self.m_rankGlobalBottomChamp:setVisible(false);
		self.m_rankGlobalBottomNotChamp:setVisible(true);
		self.m_rankGlobalBottomNotChamp:setFile("Hall/hallRank/rank_bg2.png");
		self.m_rankGlobalBottomNotChampT:setText("未上榜");
		self.m_rankGlobalBottomNotChampT:setColor(129,1123,93);

		if not self.m_player then
			return;
		end


		if self.m_player.small_image and self.m_player.small_image ~= "" then 
			local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_player.small_image);
			self.localDir = localDir; -- 下载图片
		    if not isExist then
		        if tonumber(kSexMan) == tonumber(self.m_player.sex) then
		            localDir = "Login/yx/Commonx/default_man.png";
			    else
		            localDir = "Login/yx/Commonx/default_woman.png";
			    end
		    end
			self.m_rankGlobalBottomHeadBg:setFile(localDir);

			setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png",localDir)
		else
			if self.m_player.sex == 1 then  -- 男人
				self.m_rankGlobalBottomHeadBg:setFile("Login/yx/Commonx/default_man.png");
				setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_man.png")
			else
				self.m_rankGlobalBottomHeadBg:setFile("Login/yx/Commonx/default_woman.png");
				setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_woman.png")
			end

		end
		return;
	end

	if myData.rank then 
		if tonumber(myData.rank) <=3 and tonumber(myData.rank) > 0 then 
			self.m_rankGlobalBottomNotChamp:setVisible(false);
			self.m_rankGlobalBottomChamp:setVisible(true);

			self.m_rankGlobalBottomChamp:setFile("Hall/hallRank/place_" .. myData.rank .. ".png");
		elseif tonumber(myData.rank) > 3 then 
			self.m_rankGlobalBottomChamp:setVisible(false);
			self.m_rankGlobalBottomNotChamp:setVisible(true);
			self.m_rankGlobalBottomNotChamp:setFile("Hall/hallRank/place_other.png");
			self.m_rankGlobalBottomNotChampT:setText(myData.rank .. "");
			self.m_rankGlobalBottomNotChampT:setColor(255,255,255);
		else
			self.m_rankGlobalBottomChamp:setVisible(false);
			self.m_rankGlobalBottomNotChamp:setVisible(true);
			self.m_rankGlobalBottomNotChamp:setFile("Hall/hallRank/rank_bg2.png");
			self.m_rankGlobalBottomNotChampT:setText("未上榜");
			self.m_rankGlobalBottomNotChampT:setColor(129,1123,93);
		end
	end

	if myData.icon and myData.icon ~= "" then 
		local isExist , localDir = NativeManager.getInstance():downloadImage(myData.icon);
		self.localDir = localDir; -- 下载图片
		if not isExist then
		    if tonumber(kSexMan) == tonumber(myData.sex) then
		       localDir = "Login/yx/Commonx/default_man.png";
		   else
		       localDir = "Login/yx/Commonx/default_woman.png";
		   end
		end
		self.m_rankGlobalBottomHeadBg:setFile(localDir);
		setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png",localDir)
	else
		if myData.sex == 1 then  -- 男人
			self.m_rankGlobalBottomHeadBg:setFile("Login/yx/Commonx/default_man.png");
			setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_man.png")
		else
			self.m_rankGlobalBottomHeadBg:setFile("Login/yx/Commonx/default_woman.png");
			setMaskImg(self.m_rankGlobalBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_woman.png")
		end
	end

	if myData.nickName then 
		self.m_rankGlobalBottomName:setText(stringFormatWithString(myData.nickName, 12, true))
	end

	if myData.value then 
		self.m_rankGlobalBottomCoin:setText(trunNumberIntoThreeOneFormWithInt(myData.value) or 0);
	end

	if myData.title then 
		self.m_rankGlobalChamp:setFile("Hall/hallRank/wealth_level_" .. myData.title .. ".png");
	end
end


YiXinRankWindow.updateFriendData = function(self,myData)
	if not myData then 
		-- 没有数据的话
		self.m_rankFriendBottomChamp:setVisible(false);
		self.m_rankFriendBottomNotChamp:setVisible(true);
		self.m_rankFriendBottomNotChamp:setFile("Hall/hallRank/rank_bg2.png");
		self.m_rankFriendBottomNotChampT:setText("未上榜");
		self.m_rankFriendBottomNotChampT:setColor(129,1123,93);

		if not self.m_player then
			return;
		end


		if self.m_player.small_image and self.m_player.small_image ~= "" then 
			local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_player.small_image);
			self.localDir = localDir; -- 下载图片
		    if not isExist then
		        if tonumber(kSexMan) == tonumber(self.m_player.sex) then
		            localDir = "Login/yx/Commonx/default_man.png";
			    else
		            localDir = "Login/yx/Commonx/default_woman.png";
			    end
		    end
			self.m_rankFriendBottomHeadBg:setFile(localDir);
			setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png",localDir)
		else
			if self.m_player.sex == 1 then  -- 男人
				self.m_rankFriendBottomHeadBg:setFile("Login/yx/Commonx/default_man.png");
				setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_man.png")
			else
				self.m_rankFriendBottomHeadBg:setFile("Login/yx/Commonx/default_woman.png");
				setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_woman.png")
			end
		end
		return;
	end

	if myData.rank then 
		if tonumber(myData.rank) <=3 and tonumber(myData.rank) > 0 then 
			self.m_rankFriendBottomNotChamp:setVisible(false);
			self.m_rankFriendBottomChamp:setVisible(true);

			self.m_rankFriendBottomChamp:setFile("Hall/hallRank/place_" .. myData.rank .. ".png");
		elseif tonumber(myData.rank) > 3 then 
			self.m_rankFriendBottomChamp:setVisible(false);
			self.m_rankFriendBottomNotChamp:setVisible(true);
			self.m_rankFriendBottomNotChamp:setFile("Hall/hallRank/place_other.png");
			self.m_rankFriendBottomNotChampT:setText(myData.rank .. "");
			self.m_rankFriendBottomNotChampT:setColor(255,255,255);
		else
			self.m_rankFriendBottomChamp:setVisible(false);
			self.m_rankFriendBottomNotChamp:setVisible(true);
			self.m_rankFriendBottomNotChamp:setFile("Hall/hallRank/rank_bg2.png");
			self.m_rankFriendBottomNotChampT:setText("未上榜");
			self.m_rankFriendBottomNotChampT:setColor(129,1123,93);
		end
	end

	if myData.icon and myData.icon ~= "" then 
		local isExist , localDir = NativeManager.getInstance():downloadImage(myData.icon);
			self.localDir = localDir; -- 下载图片
		    if not isExist then
		        if tonumber(kSexMan) == tonumber(myData.sex) then
		            localDir = "Login/yx/Commonx/default_man.png";
			    else
		            localDir = "Login/yx/Commonx/default_woman.png";
			    end
		    end
		self.m_rankFriendBottomHeadBg:setFile(localDir);
		setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png",localDir)
	else
		if myData.sex == 1 then  -- 男人
			self.m_rankFriendBottomHeadBg:setFile("Login/yx/Commonx/default_man.png");
			setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_man.png")
		else
			self.m_rankFriendBottomHeadBg:setFile("Login/yx/Commonx/default_woman.png");
			setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png","Login/yx/Commonx/default_woman.png")
		end
	end

	if myData.nickName then 
		self.m_rankFriendBottomName:setText(stringFormatWithString(myData.nickName, 12, true))
	end

	if myData.value then 
		self.m_rankFriendBottomCoin:setText(trunNumberIntoThreeOneFormWithInt(myData.value) or 0);
	end

	if myData.title then 
		self.m_rankFriendChamp:setFile("Hall/hallRank/wealth_level_" .. myData.title .. ".png");
	end
end

-- 请求获取奖励
YiXinRankWindow.requestRankReward = function (self,type)
	local param = {};
	self.m_type = type;
	param.type = self.m_type;
	param.accessToken = GameConstant.accessToken;
	Loading.showLoadingAnim("正在努力为您加载...");
	HttpModule.getInstance():execute(HttpModule.s_cmds.requestYiXinChipBoard, param, self.m_event);
end

-- 排行榜的php获取到数据
YiXinRankWindow.onHttpRequestsCallBack = function (self ,command, isSuccess, data)
	Loading.hideLoadingAnim();
	if HttpModule.s_cmds.requestYiXinChipBoard == command then
		if self.m_type == 0 then 
			self:requestRankRewardForFriendCallBack(isSuccess,data);
		elseif self.m_type == 1 then 
			self:requestGlobalRankRewardForFriendCallBack(isSuccess,data);
		end
	end
end

YiXinRankWindow.requestRankRewardForFriendCallBack = function(self,isSuccess,data)
	if not data then 
		return ;
	end
	if isSuccess then 
		if data.status == 1 then 
			Loading.hideLoadingAnim();
			local myselfData = {};
			myselfData.accountId = data.data.me.accountId or 0;
			myselfData.nickName = data.data.me.nick or "";
			myselfData.ingame = data.data.me.ingame or false;
			myselfData.title = data.data.me.title or "1";
			myselfData.sex = data.data.me.sex or 1;
			myselfData.value = data.data.me.value or 0;
			myselfData.hide = data.data.me.hide or 0;
			myselfData.icon = data.data.me.icon or "";
			myselfData.rank = data.data.me.rank or 0;

			self:updateFriendData(myselfData);

			local friendList = {};
			for k,v in pairs(data.data.list) do 
				friendList[#friendList + 1] = {};
				friendList[#friendList].accountId = v.accountId or "1";
				friendList[#friendList].mnick = v.nick or "";
				friendList[#friendList].money = v.value or 0;
				friendList[#friendList].icon = v.icon or "";
				friendList[#friendList].gender = v.sex or kSexWomen;
				friendList[#friendList].ingame = v.ingame or false;
				friendList[#friendList].rankNum = v.rank or "1";
				local date = os.date("%x");
				local invitestr = g_DiskDataMgr:getAppData("yixin_date" .. friendList[#friendList].accountId,"");
				if invitestr == date then 
					friendList[#friendList].invited = 1;
				else
					friendList[#friendList].invited = 0;
				end
				friendList[#friendList].titleStr = v.title or "1";
			end
		 	self:createFriendList(friendList);
		else
			Banner.getInstance():showMsg(data.msg or "");
		end
	end
end

YiXinRankWindow.requestGlobalRankRewardForFriendCallBack = function(self,isSuccess,data)
	if not data then 
		return ;
	end
	if isSuccess then 
		if data.status == 1 then 
			local myselfData = {};
			myselfData.accountId = data.data.me.accountId or 0;
			myselfData.nickName = data.data.me.nick or "";
			myselfData.ingame = data.data.me.ingame or false;
			myselfData.title = data.data.me.title or "1";
			myselfData.sex = data.data.me.sex or 1;
			myselfData.value = data.data.me.value or 0;
			myselfData.hide = data.data.me.hide or 0;
			myselfData.icon = data.data.me.icon or "";
			myselfData.rank = data.data.me.rank or 0;
		 	
		 	self:updateGlobalData(myselfData);

		 	local globalList = {};
		 	for k,v in pairs(data.data.list) do 
		 		globalList[#globalList+1] = {};
				globalList[#globalList].accountId = v.accountId or "1";
				globalList[#globalList].mnick = v.nick or "";
				globalList[#globalList].money = v.value or 0;
				globalList[#globalList].gender = v.sex or kSexWomen;
				globalList[#globalList].icon = v.icon or "";
				local date = os.date("%x");
				local addstr = g_DiskDataMgr:setAppData("yixin_date_global" .. globalList[#globalList].accountId,"");
				if v.friend then 
					globalList[#globalList].isFriend = 1; -- 1表示是好友
				else
					if addstr == date then 
						globalList[#globalList].isFriend = 2; -- 2 表示不是好友，但是今天加过好友
					else
						globalList[#globalList].isFriend = 0; -- 0 表示不是好友，但今天没有加过好友
					end
				end
				globalList[#globalList].rankNum = v.rank or "1";
				globalList[#globalList].titleStr = v.title or "1";
		 	end
		 	self:createGlobalList(globalList)
		else
			Banner.getInstance():showMsg(data.msg or "");
		end
	end
end


YiXinRankWindow.createGlobalList = function(self,data)
	if data or #data > 0 then
		self.m_rankglobalAdapter = new(CacheAdapter, YiXinGlobalRankItem, data);
		
		self.m_rankGlobalFriendListView:setAdapter(self.m_rankglobalAdapter);

		self.m_rankGlobalFriendListView:setVisible(true);
		self.m_rankGlobalNoFriend:setVisible(false);
	else
		self.m_rankGlobalNoFriend:setVisible(true);
		self.m_rankGlobalFriendListView:setVisible(false);
	end
end

YiXinRankWindow.dtor = function (self)
	DebugLog("YiXinRankWindow dtor");
	self.m_showFriendFlag = false;
	self.m_showGlobalFlag = false;
	self:removeAllChildren();
	EventDispatcher.getInstance():unregister(self.m_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

YiXinRankWindow.clickReturnBtn = function (self)
	self:hide();
end

YiXinRankWindow.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.m_rankFriendBottomHeadBg:setFile(self.localDir);
            setMaskImg(self.m_rankFriendBottomHeadBg,"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end

YiXinRankWindow.show = function( self )
	self:preEnterAnim()
	self:setVisible(true);

	HallTransAnim:playEnterLeft(self.tabView,self.returnBtn,self.delegate.m_hallImg,self,function ( self )
		self.firstShowFlag = true;	
		self:clickFriendBtn();  --默认加载好友榜
	end)	

end

YiXinRankWindow.preEnterAnim = function (self)
	self.tabView:setPos( 0,0 + 720)
	self.returnBtn:setPos(18,20 - 150)	
end

YiXinRankWindow.hide = function (self)
	DebugLog( "RankWindow.hide" );
	if self:getVisible() == true then
		if HallTransAnim.isPlaying then 
			return 
		end 

		HallTransAnim:playExitLeft(self.tabView,self.returnBtn,self.delegate.m_hallImg,self,function ( self )
--			umengStatics_lua(Umeng_RankBack);
			Loading.hideLoadingAnim();
			self:setVisible(false);
			CustomNode.hide(self);
			self:removeFromSuper();
			GlobalDataManager.getInstance():updateScene();
			self.delegate:preEnterAnim()
			self.delegate:playEnterAnim()
		end)
		return true 
	end
end

YiXinRankWindow.getNameImgPath = function( self, str )
	-- 8;//"神马都是浮云";   7;//"富可敌国";   6;//"富甲天下";
	-- 5;//"千万富翁";   4;//"百万富翁";   3;//"家财万贯";
	-- 2;//"略有钱财";   1;//"一贫如洗";
	str = str or 1;
	local pathStr = "newHall/rank/name" .. str .. ".png";
	return pathStr;
end


