--[[ 
	RankWindow.lua
	Author: YifanHe
	Date: 2014-02-17
	Last modification : 2014-02-17
	Description:新版排行榜界面，拥有巅峰榜、战神榜和土豪榜三个界面，可以展示榜单和领取奖励。
]]--
require("MahjongHall/hall_2_interface_base")

local rankCommon = require(ViewLuaPath.."rankCommon");
local rankListItem1 = require(ViewLuaPath.."rankListItem1");
local rankListItem2 = require(ViewLuaPath.."rankListItem2");
local rankListItem4 = require(ViewLuaPath.."rankListItem4");

require("ui/listView");
require("MahjongCommon/CustomNode");
require("MahjongHall/Rank/PaiJuRankListItem");
require("MahjongHall/Rank/WinRankListItem");
require("MahjongHall/Rank/CharmRankItem");

require("MahjongHall/Rank/TopRankItem");
require("MahjongHall/Rank/RankUserInfo");
local VipIcon_map = require("qnPlist/VipIcon")

RankWindow = class(hall_2_interface_base);

local STATE_NONE 	= 0;
local STATE_TOP 	= 1;
local STATE_MONEY 	= 2;
local STATE_WIN 	= 3;
local STATE_CHARM 	= 4;

RankWindow.ctor = function ( self, delegate)
    if not delegate then
        return;
    end
--    g_GameMonitor:addTblToUnderMemLeakMonitor("rank",self)
	self.delegate =delegate

    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.rank);
    self:set_tab_title({"今日巅峰榜", "本周魅力榜", "超级富豪榜", "超级战神榜"});
    self:set_tab_count(4);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();
end

RankWindow.getAllControls = function ( self )
	self.tabView 					= self.m_v;--publ_getItemFromTree(self.mainContent, {"content"});
	--self.returnBtn 					= publ_getItemFromTree(self.mainContent, {"retBtn"});

    self.m_content = SceneLoader.load(rankCommon);
    self.m_bg:addChild(self.m_content);

--	local testui = self.m_bg--publ_getItemFromTree(self.tabView,{"bg"})
--	testui:setSize(System.getScreenScaleWidth() - 80,System.getScreenScaleHeight() - 140)	
	--tab
	self.m_rankTopBtn 				= self.m_btn_tab[1]--publ_getItemFromTree(self.m_content, {"tab_view","tab_1"});
	self.m_rankMoneyBtn 			= self.m_btn_tab[3]--publ_getItemFromTree(self.m_content, {"tab_view","tab_2"});
	self.m_rankWinBtn 				= self.m_btn_tab[4]--publ_getItemFromTree(self.m_content, {"tab_view","tab_3"});
	self.m_rankCharmBtn 			= self.m_btn_tab[2]--publ_getItemFromTree(self.m_content, {"tab_view","tab_4"});

	self.m_rankTopImg 				= self.m_btn_tab[1].img--publ_getItemFromTree(self.m_content, {"tab_view","top_img"});
	self.m_rankMoneyImg 			= self.m_btn_tab[3].img--publ_getItemFromTree(self.m_content, {"tab_view","rich_img"});
	self.m_rankWinImg 				= self.m_btn_tab[4].img-- publ_getItemFromTree(self.m_content, {"tab_view","mars_img"});
	self.m_rankCharmImg 			= self.m_btn_tab[2].img--publ_getItemFromTree(self.m_content, {"tab_view","charm_img"});

	self.m_rankTopSubView			= publ_getItemFromTree(self.m_content, {"v","topInfo"});
	self.m_rankCharmSubView			= publ_getItemFromTree(self.m_content, {"v","charmInfo"});
	self.m_rankMoneySubView			= publ_getItemFromTree(self.m_content, {"v","richInfo"});
	self.m_rankWinSubView			= publ_getItemFromTree(self.m_content, {"v","marsInfo"});

	self.m_topRewardBtn				= publ_getItemFromTree(self.m_content, {"v","topInfo" , "mid_view", "Button1"});
	self.m_charmRewardBtn			= publ_getItemFromTree(self.m_content, {"v","charmInfo", "mid_view", "Button1"});

	self.m_switchTopRankBtn         = publ_getItemFromTree(self.m_content, {"v","topInfo","mid_view","Button2"});
	self.m_switchTopRankBtn:setOnClick(self,self.onClickSwitchTopRank)

	self.m_switchCharmRankBtn       = publ_getItemFromTree(self.m_content, {"v","charmInfo" , "mid_view", "Button2"});
	self.m_switchCharmRankBtn:setOnClick(self,self.onClickSwitchCharmRank)

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
		self.m_rankTopImg:setFile("Login/wdj/Hall/Commonx/tag_red.png");
		self.m_rankMoneyImg:setFile("Login/wdj/Hall/Commonx/tag_red.png"); 
		self.m_rankWinImg:setFile("Login/wdj/Hall/Commonx/tag_red.png"); 	
		self.m_rankCharmImg:setFile("Login/wdj/Hall/Commonx/tag_red.png"); 
	end


end

RankWindow.on_enter = function (self)


	self.m_mid = PlayerManager.getInstance():myself().mid or 0;

	--个人榜单信息字段
	self.m_nameStr = "";
	self.m_moneyStr = "0";
	self.m_titleStr = "1";
	self.m_recordStr = "";
	self.m_levelStr = "";
	self.m_top_levelStr = "";
	self.m_top_moneyStr = "0";
	self.m_top_wintimeStr = "0";
	self.m_top_drawtimeStr = "0";
	self.m_top_losttimeStr = "0";

	self.currentShowID = 1; --当前显示的

	--获取本地缓存数据
	self.localTopData   = self:getTopRankLocal();
	self.localPaiJuData = self:getMoneyRankLocal();
	self.localWinData   = self:getWinRankLocal();
	self.localCharmData = self:getCharmRankLocal();

	self.m_event = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(self.m_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self.myself = PlayerManager.getInstance():myself();
	self.m_state = STATE_NONE;

	--tab
	--self.mainContent = SceneLoader.load(rankCommon);
	--self:addChild(self.mainContent);
	
	self:getAllControls()

    --tab click
    self:set_tab_callback(self,self.tab_click);

	self.curTopRankIsToday = true
	self.curCharmRankIsToday = true


	self.firstShowFlag = true;	
	self:clickTopBtn();  --默认加载今日巅峰榜


    DebugLog('Profile clicked rank stop:'..os.clock(),LTMap.Profile)

end

RankWindow.on_exit = function (self)
    GlobalDataManager.getInstance():updateScene();
end


RankWindow.tab_click = function (self, index)
    --1:今日巅峰榜，2:本周魅力榜，3:超级富豪榜，4:超级战神榜
    if index == 1 then
        self:clickTopBtn();
    elseif index == 2 then
        self:clickCharmBtn();
    elseif index == 3 then
        self:clickPaiJuBtn();
    elseif index == 4 then
        self:clickWinBtn();
    end
end 

--创建自己信息(富豪)
RankWindow.creatMyselfNode2 = function ( self )
	-- body
	--创建自己信息(富豪)
	self.myListItem2 = SceneLoader.load(rankListItem2);
	publ_getItemFromTree(self.m_rankMoneySubView, {"bottom_view"}):addChild(self.myListItem2);
	self.myListItem2:setAlign(kAlignCenter);
    --self.myListItem2:setPos(0, -12);
	publ_getItemFromTree(self.myListItem2, {"item_view","img_line"}):setVisible(false);

	publ_getItemFromTree(self.myListItem2, {"item_view","view_place","text_place"}):setText("未上榜");
	--publ_getItemFromTree(self.myListItem2, {"item_view","view_place","img_place"}):setVisible(false);
	publ_getItemFromTree(self.myListItem2, {"item_view","text_name"}):setText("",nil,nil,255,255,255)
	publ_getItemFromTree(self.myListItem2, {"item_view","text_score"}):setText("",nil,nil,255,220,0)

	local btn_photo2 = publ_getItemFromTree(self.myListItem2, {"item_view","btn_image"});
	local img_photo2  = publ_getItemFromTree(self.myListItem2, {"item_view","btn_image","img_photo"});

	--设置头像
	self:setHeadPhoto(btn_photo2, img_photo2); 

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then  
		publ_getItemFromTree(self.myListItem2, {"item_view","img_line"}):setFile("Login/wdj/Hall/rank/item_bg.png");
	end
end

--创建自己信息(战神)
RankWindow.creatMyselfNode3 = function ( self )
	self.myListItem3 = SceneLoader.load(rankListItem1);
	publ_getItemFromTree(self.m_rankWinSubView, {"bottom_view"}):addChild(self.myListItem3);
	self.myListItem3:setAlign(kAlignCenter);
    --self.myListItem3:setPos(0, -12);
	publ_getItemFromTree(self.myListItem3, {"item_view","img_line"}):setVisible(false);

	publ_getItemFromTree(self.myListItem3, {"item_view","view_place","text_place"}):setText("未上榜");
	--publ_getItemFromTree(self.myListItem3, {"item_view","view_place","img_place"}):setVisible(false);
	publ_getItemFromTree(self.myListItem3, {"item_view","text_name"}):setText("",nil,nil,255,255,255)
	publ_getItemFromTree(self.myListItem3, {"item_view","text_score"}):setText("",nil,nil,255,220,0)
	publ_getItemFromTree(self.myListItem3, {"item_view","text_lv"}):setText("",nil,nil,255,255,255)

	local btn_photo3 = publ_getItemFromTree(self.myListItem3, {"item_view","btn_image"});
	local img_photo3  = publ_getItemFromTree(self.myListItem3, {"item_view","btn_image","img_photo"});

	--设置头像
	self:setHeadPhoto(btn_photo3, img_photo3); 
	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then   
		publ_getItemFromTree(self.myListItem3, {"item_view","img_line"}):setFile("Login/wdj/Hall/rank/item_bg.png");
	end
end

--创建自己信息(魅力)
RankWindow.creatMyselfNode4 = function ( self )
	self.myListItem4 = SceneLoader.load(rankListItem4);
	publ_getItemFromTree(self.m_rankCharmSubView, {"bottom_view"}):addChild(self.myListItem4);
	self.myListItem4:setAlign(kAlignCenter);
    --self.myListItem4:setPos(0, -12);
	publ_getItemFromTree(self.myListItem4, {"item_view","img_line"}):setVisible(false);

	publ_getItemFromTree(self.myListItem4, {"item_view","view_place","text_place"}):setText("未上榜");
	--publ_getItemFromTree(self.myListItem4, {"item_view","view_place","img_place"}):setVisible(false);

	publ_getItemFromTree(self.myListItem4, {"item_view","text_name"}):setText("",nil,nil,255,255,255)
	publ_getItemFromTree(self.myListItem4, {"item_view","text_score"}):setText("",nil,nil,255,220,0)

	local btn_photo4 = publ_getItemFromTree(self.myListItem4, {"item_view","btn_image"});
	local img_photo4  = publ_getItemFromTree(self.myListItem4, {"item_view","btn_image","img_photo"});

	--设置头像
	self:setHeadPhoto(btn_photo4, img_photo4); 

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then  
		publ_getItemFromTree(self.myListItem4, {"item_view","img_line"}):setFile("Login/wdj/Hall/rank/item_bg.png");
	end
end

RankWindow.creatMyselfNode= function (self)
	
	--创建自己信息(今日)
	self.myListItem = SceneLoader.load(rankListItem1);
	publ_getItemFromTree(self.m_rankTopSubView, {"bottom_view"}):addChild(self.myListItem);
	self.myListItem:setAlign(kAlignCenter);

	publ_getItemFromTree(self.myListItem, {"item_view","img_line"}):setVisible(false);

	--设置名次
	publ_getItemFromTree(self.myListItem, {"item_view","view_place","text_place"}):setText("未上榜");
	
	publ_getItemFromTree(self.myListItem, {"item_view","text_name"}):setText("",nil,nil,255,255,255)
	publ_getItemFromTree(self.myListItem, {"item_view","text_score"}):setText("",nil,nil,255,220,0)
	publ_getItemFromTree(self.myListItem, {"item_view","text_lv"}):setText("",nil,nil,255,255,255)
	--publ_getItemFromTree(self.myListItem, {"item_view","view_place","img_place"}):setVisible(true);
	
	--设置头像
	local btn_photo = publ_getItemFromTree(self.myListItem, {"item_view","btn_image"});
	local img_photo  = publ_getItemFromTree(self.myListItem, {"item_view","btn_image","img_photo"});

	--设置头像
	self:setHeadPhoto(btn_photo, img_photo);
	
  	 --设置昵称
	 publ_getItemFromTree(self.myListItem, {"item_view","text_name"}):setText(stringFormatWithString(self.myself.nickName,GameConstant.rankListItemNameLimit,true));
	 --设置胜负信息
	 publ_getItemFromTree(self.myListItem, {"item_view","text_score"}):setText("");

	 --设置等级
	 publ_getItemFromTree(self.myListItem, {"item_view","text_lv"}):setText("");

	 if PlatformConfig.platformWDJ == GameConstant.platformType or
	    PlatformConfig.platformWDJNet == GameConstant.platformType then  
		publ_getItemFromTree(self.myListItem, {"item_view","img_line"}):setFile("Login/wdj/Hall/rank/item_bg.png");
	end

end

--设置头像并设置头像点击事件
RankWindow.setHeadPhoto = function ( self, btn_photo, img_photo)
	local params = PlayerManager.getInstance():myself()

	local isExist = false;
	local localDir = nil;
	if GameConstant.uploadHeadIconName and GameConstant.uploadHeadIconName ~= "" then
		isExist = true;
		localDir = GameConstant.uploadHeadIconName;
	else
		isExist , localDir = NativeManager.getInstance():downloadImage(params.large_image);
	end
	if not isExist then
		if tonumber(params.sex) == kSexMan then
			localDir = "Commonx/default_man.png";
			if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_man.png";
			end
		else
			localDir = "Commonx/default_woman.png";
			if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_woman.png";
			end
		end
	end


    setMaskImg(img_photo,"Hall/hallRank/head_mask.png",localDir)

	--设置点击头像事件
	 btn_photo:setOnClick(self, function(self)
			self:getUserInfo();
		end);

end

RankWindow.getUserInfo = function( self )
	FriendDataManager.getInstance():QueryUserInfo(PHP_CMD_QUERY_USER_INFO_POP,{self.myself.mid})
	Loading.showLoadingAnim("正在努力为您加载...");
end

RankWindow.dtor = function (self)
	DebugLog("RankWindow dtor");

    self.super.dtor(self);
	self:removeAllChildren();
	EventDispatcher.getInstance():unregister(self.m_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	self.currentShowID = nil;
end

RankWindow.clickReturnBtn = function (self)
	self:hide();
end

RankWindow.clickTopBtn = function(self)
	if self.currentShowID == 1 and not self.firstShowFlag then
		return;
	end
	self.firstShowFlag = false;
	if self.currentShowID == 2 then
		self.m_rankMoneySubView:setVisible(false)
		self.m_rankMoneyImg:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview2);
	elseif self.currentShowID == 3 then 
		self.m_rankWinSubView:setVisible(false)
		self.m_rankWinImg:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview3);	
	elseif self.currentShowID == 4 then
		self.m_rankCharmSubView:setVisible(false)
		self.m_rankCharmImg:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview4);
	end
	--self.m_rankTopBtn:setFile("Commonx/tab_right.png")
	self.m_rankCharmBtn:setFile("Commonx/tab_right.png")
	self.m_rankMoneyBtn:setFile("Commonx/tab_right.png")
	self.m_rankWinBtn:setFile("Commonx/tab_right.png")

	if not self.myListItem then
		self:creatMyselfNode();
	end
	
	self:setAwardBtnCanClick( self.m_topRewardBtn,false );

	if self.localTopData then
		self:updateMyDataInfoView(1);
		self:createTopRankView(self.localTopData.data,self.localTopData.msg or "");
	end
		
	self.m_state = STATE_TOP;
    self:set_light_tab(1);
	self.m_rankTopImg:setVisible(true)

	self.currentShowID = 1;
	self.m_rankTopSubView:setVisible(true);

	if not self.m_topListCreated then
		Loading.showLoadingAnim("正在努力为您加载...");
		self:requestRankList(1);
	end
end

RankWindow.clickPaiJuBtn = function (self)
	if self.currentShowID == 2 then
		return;
	end

	if self.currentShowID == 1 then
		self.m_rankTopImg:setVisible(false)
		self.m_rankTopSubView:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview2);
	elseif self.currentShowID == 3 then 
		self.m_rankWinSubView:setVisible(false)
		self.m_rankWinImg:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview3);	
	elseif self.currentShowID == 4 then
		self.m_rankCharmSubView:setVisible(false)
		self.m_rankCharmImg:setVisible(false)
		--self:remveChildItemByViewId(self.rankSubview4);
	end
	self.m_rankTopBtn:setFile("Commonx/tab_left.png")
	self.m_rankCharmBtn:setFile("Commonx/tab_left.png")
	--self.m_rankMoneyBtn:setFile("Commonx/tab_right.png")
	self.m_rankWinBtn:setFile("Commonx/tab_right.png")

	if not self.myListItem2 then
		self:creatMyselfNode2();
	end
	

	if self.localPaiJuData then
		self:updateMyDataInfoView(2);
		self:creatPaiJuRankListView(self.localPaiJuData.data);
	end
	

	self.m_state = STATE_MONEY;
    self:set_light_tab(3);
	self.m_rankMoneyImg:setVisible(true)
	self.m_rankMoneySubView:setVisible(true);
	self.currentShowID = 2;

	if not self.m_moneyListCreated then
		Loading.showLoadingAnim("正在努力为您加载...");
		self:requestRankList(2);
	end
end

RankWindow.clickWinBtn = function (self)
	if self.currentShowID == 3 then
		return;
	end
	if self.currentShowID == 1 then
		self.m_rankTopImg:setVisible(false)
		self.m_rankTopSubView:setVisible(false)
	elseif self.currentShowID == 2 then 
		self.m_rankMoneySubView:setVisible(false)
		self.m_rankMoneyImg:setVisible(false)
	elseif self.currentShowID == 4 then
		self.m_rankCharmSubView:setVisible(false)
		self.m_rankCharmImg:setVisible(false)
	end
	self.m_rankTopBtn:setFile("Commonx/tab_left.png")
	self.m_rankCharmBtn:setFile("Commonx/tab_left.png")
	self.m_rankMoneyBtn:setFile("Commonx/tab_left.png")
	--self.m_rankWinBtn:setFile("Commonx/tab_right.png")


	if not self.myListItem3 then
		self:creatMyselfNode3();
	end	

	if self.localWinData then
		self:updateMyDataInfoView(3);
		self:creatWinRankListView(self.localWinData.data);
	end


	self.m_state = STATE_WIN;
    self:set_light_tab(4);
	self.m_rankWinSubView:setVisible(true)
	self.m_rankWinImg:setVisible(true)

	self.currentShowID = 3;

	if not self.m_winListCreated then
		Loading.showLoadingAnim("正在努力为您加载...");
		self:requestRankList(3);
	end
end

RankWindow.clickCharmBtn = function (self)
	if self.currentShowID == 4 then
		return;
	end
	if self.currentShowID == 1 then
		self.m_rankTopImg:setVisible(false)
		self.m_rankTopSubView:setVisible(false)
	elseif self.currentShowID == 2 then 
		self.m_rankMoneySubView:setVisible(false)
		self.m_rankMoneyImg:setVisible(false)
	elseif self.currentShowID == 3 then
		self.m_rankWinSubView:setVisible(false)
		self.m_rankWinImg:setVisible(false)
	end
	self.m_rankTopBtn:setFile("Commonx/tab_left.png")
	--self.m_rankCharmBtn:setFile("Commonx/tab_right.png")
	self.m_rankMoneyBtn:setFile("Commonx/tab_right.png")
	self.m_rankWinBtn:setFile("Commonx/tab_right.png")

	if not self.myListItem4 then
		self:creatMyselfNode4();
	end

	--self.m_rewardBtn = publ_getItemFromTree(self.rankSubview4, {"sub_part","sub_view","sub_view_2","button"});
	self:setAwardBtnCanClick( self.m_charmRewardBtn,false );

	if self.localCharmData then
		self:updateMyDataInfoView(4);
		self:creatCharmRankListView(self.localCharmData.data, self.localCharmData.msg);
	end

	self.m_state = STATE_CHARM;
    self:set_light_tab(2);
	self.m_rankCharmSubView:setVisible(true)
	self.m_rankCharmImg:setVisible(true);
	self.currentShowID = 4;

	if not self.m_charmListCreated then
		Loading.showLoadingAnim("正在努力为您加载...");
		self:requestRankList(4);
	end
end

RankWindow.setAwardBtnCanClick = function( self, btn ,enable )
	if not btn then
		return;
	end
	btn:setEnable( enable );
	btn:setIsGray( not enable );
end

--移除某一项目
RankWindow.remveChildItemByViewId = function ( self, currentItemView )
	self:removeChild(currentItemView);
	delete(currentItemView);
	currentView =  nil;
end

-- 更新自己的信息
RankWindow.updateMyDataInfoView = function (self, typeNum)
	if typeNum == 1 then
		self:setMyTopInfoView();
	elseif typeNum == 2 then
		self:setMyMoneyInfoView();
	elseif typeNum == 3 then
		self:setMyWinInfoView();
	elseif typeNum == 4 then
		self:setMyCharmInfoView();
	end
end

RankWindow.getNameImgPath = function( self, str )
	-- 8;//"神马都是浮云";   7;//"富可敌国";   6;//"富甲天下";
	-- 5;//"千万富翁";   4;//"百万富翁";   3;//"家财万贯";
	-- 2;//"略有钱财";   1;//"一贫如洗";
	str = str or 1;
	local pathStr = "newHall/rank/name" .. str .. ".png";
	return pathStr;
end

-- 设置自己的巅峰榜信息
RankWindow.setMyTopInfoView = function ( self )
	
	if not self.localTopData then
		return;
	end

	local rank = self:getIndexOfRankData(self.localTopData.data.content) or 0;

	--设置名次
	if rank > 0 then
		local img_place_path = "";
		local img_place_text = "";
		if rank <= 3 then
			img_place_path = string.format("Hall/hallRank/place_%d.png",rank);
		else
			img_place_path = "Hall/hallRank/place_other.png";
			img_place_text = "" .. rank;
		end		

		publ_getItemFromTree(self.myListItem, {"item_view","view_place","text_place"}):setText(img_place_text);

		local img_place = publ_getItemFromTree(self.myListItem, {"item_view","view_place","img_place"});
		img_place:setFile(img_place_path);
		img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);
		img_place:setVisible(true);

	end
	local vipTag = self:getSelfVipImgTag()
	if vipTag then 
		self.myListItem:addChild(vipTag)
	end 
	 --设置昵称
	publ_getItemFromTree(self.myListItem, {"item_view","text_name"}):setText(stringFormatWithString(self.myself.nickName,GameConstant.rankListItemNameLimit,true));

	 --设置胜负信息
	publ_getItemFromTree(self.myListItem, {"item_view","text_score"}):setText(trunNumberIntoThreeOneFormWithInt(self.m_top_moneyStr,false) .. "金币");

	 --设置等级
	publ_getItemFromTree(self.myListItem, {"item_view","text_lv"}):setText(self.m_top_levelStr);

end
-- 设置自己的土豪榜信息
RankWindow.setMyMoneyInfoView = function (self)
	
	if not self.localPaiJuData then
		return;
	end

	local rank = self:getIndexOfRankData(self.localPaiJuData.data.content) or 0;

	--设置名次
	if rank > 0 then
		local img_place_path = "";
		local img_place_text = "";
		if rank <= 3 then
			img_place_path = string.format("Hall/hallRank/place_%d.png",rank);
		else
			img_place_path = "Hall/hallRank/place_other.png";
			img_place_text = "" .. rank;
		end
		publ_getItemFromTree(self.myListItem2, {"item_view","view_place","text_place"}):setText(img_place_text);
		local img_place = publ_getItemFromTree(self.myListItem2, {"item_view","view_place","img_place"});
		img_place:setFile(img_place_path);
		img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);
		img_place:setVisible(true);
	end
	 --设置昵称
	publ_getItemFromTree(self.myListItem2, {"item_view","text_name"}):setText(stringFormatWithString(self.myself.nickName,GameConstant.rankListItemNameLimit,true));

	 --设置得分信息
	publ_getItemFromTree(self.myListItem2, {"item_view","text_score"}):setText(trunNumberIntoThreeOneFormWithInt(self.m_moneyStr,false) .. "金币");

	 --设置等级
	publ_getItemFromTree(self.myListItem2, {"item_view","img_wealth_lv"}):setFile("Hall/hallRank/wealth_level_" .. self.m_titleStr .. ".png");

	local vipTag = self:getSelfVipImgTag()
	if vipTag then 
		self.myListItem2:addChild(vipTag)
	end 
end

-- 设置自己的战神榜信息
RankWindow.setMyWinInfoView = function (self)
	
	if not self.localWinData then
		return;
	end

	local rank = self:getIndexOfRankData(self.localWinData.data.content) or 0;
	--设置名次
	if rank > 0 then
		local img_place_path = "";
		local img_place_text = "";
		if rank <= 3 then
			img_place_path = string.format("Hall/hallRank/place_%d.png",rank);
		else
			img_place_path = "Hall/hallRank/place_other.png";
			img_place_text = "" .. rank;
		end

		publ_getItemFromTree(self.myListItem3, {"item_view","view_place","text_place"}):setText(img_place_text);
		local img_place = publ_getItemFromTree(self.myListItem3, {"item_view","view_place","img_place"});
		img_place:setFile(img_place_path);
		img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);
		img_place:setVisible(true);

	end
	 --设置昵称
	publ_getItemFromTree(self.myListItem3, {"item_view","text_name"}):setText(stringFormatWithString(self.myself.nickName,GameConstant.rankListItemNameLimit,true));

	 --设置胜负信息
	local score_info = "";
	if self.m_top_wintimeStr ~= "" then
		score_info = self.m_top_wintimeStr .. "胜 " .. self.m_top_losttimeStr .. "负 " .. self.m_top_drawtimeStr .. "平";
	end
	publ_getItemFromTree(self.myListItem3, {"item_view","text_score"}):setText(score_info);

	 --设置等级
	publ_getItemFromTree(self.myListItem3, {"item_view","text_lv"}):setText(self.m_top_levelStr);

	local vipTag = self:getSelfVipImgTag()
	if vipTag then 
		self.myListItem3:addChild(vipTag)
	end 
end

function RankWindow.getSelfVipImgTag( self )
	local vip_level = PlayerManager.getInstance():myself().vipLevel 

    if vip_level and vip_level > 0 then 
        if vip_level > 10 then 
            vip_level = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..vip_level..".png"])
        m_vipImg:setPos(175,15)
        return m_vipImg
    end 
    return nil
end

RankWindow.setMyCharmInfoView = function (self)
	if not self.localCharmData then
		return;
	end

	local rank = self:getIndexOfRankData(self.localCharmData.data.content) or 0;
	--设置名次
	if rank > 0 then
		local img_place_path = "";
		local img_place_text = "";
		if rank <= 3 then
			img_place_path = string.format("Hall/hallRank/place_%d.png",rank);
		else
			img_place_path = "Hall/hallRank/place_other.png";
			img_place_text = "" .. rank;
		end

		publ_getItemFromTree(self.myListItem4, {"item_view","view_place","text_place"}):setText(img_place_text);
		local img_place = publ_getItemFromTree(self.myListItem4, {"item_view","view_place","img_place"});
		img_place:setFile(img_place_path);
		img_place:setSize(img_place.m_res.m_width, img_place.m_res.m_height);
		img_place:setVisible(true);
	end
	 --设置昵称
	publ_getItemFromTree(self.myListItem4, {"item_view","text_name"}):setText(stringFormatWithString(self.myself.nickName,GameConstant.rankListItemNameLimit,true));

	 --设置胜负信息
	local charm_info = "";
	if self.m_charm then
		charm_info = "本周获得魅力值"..self.m_charm;
	end
	publ_getItemFromTree(self.myListItem4, {"item_view","text_score"}):setText(charm_info);
	local vipTag = self:getSelfVipImgTag()
	if vipTag then 
		self.myListItem4:addChild(vipTag)
	end 
	local img_charm_lv = publ_getItemFromTree(self.myListItem4, {"item_view","img_charm_lv"});
	 --设置等级
	 if self.m_charmLevel then
		if self.m_charmLevel >= 7 and self.m_charmLevel <= 9 then
			local player = PlayerManager.getInstance():myself();
			if kSexMan == tonumber(player.sex) then
				img_charm_lv:setFile("Hall/hallRank/charm_level_"..self.m_charmLevel.."_0.png");
			else
				img_charm_lv:setFile("Hall/hallRank/charm_level_"..self.m_charmLevel.."_1.png");
			end
		else
			img_charm_lv:setFile("Hall/hallRank/charm_level_"..self.m_charmLevel..".png");
		end
	end
	-- if self.m_charmLevel and self.m_charmLevel >= 7 then
	-- 	if kSexMan == tonumber(self.myself.sex) then
	-- 		publ_getItemFromTree(self.myListItem4, {"item_view","img_charm_lv"}):setFile("Hall/hallRank/charm_level_7_0.png");--魅力等级
	-- 	else
	-- 		publ_getItemFromTree(self.myListItem4, {"item_view","img_charm_lv"}):setFile("Hall/hallRank/charm_level_7_1.png");
	-- 	end
	-- else
	-- 	publ_getItemFromTree(self.myListItem4, {"item_view","img_charm_lv"}):setFile("Hall/hallRank/charm_level_"..self.m_charmLevel..".png");
	-- end
end

-- 查找自己是否处于可领奖的范围
RankWindow.getIndexOfRankData = function (self , data)
	for k , v in pairs(data) do
		if not v or v == false or v == true then
			return 0;
		end
		if tonumber(v.mid) == tonumber(self.myself.mid) then
			return v.rank;
		end
	end
	return 0;
end


-- 取得缓存中的今日排行
RankWindow.getTopRankLocal = function (self)
	return g_DiskDataMgr:getFileKeyValue('RankFileInfo','rtop',nil)
end

-- 取得缓存中的金钱排行
RankWindow.getMoneyRankLocal = function (self)
	return g_DiskDataMgr:getFileKeyValue('RankFileInfo','rmoney',nil)
end

-- 取得缓存中的战局排行
RankWindow.getWinRankLocal = function (self)
	return g_DiskDataMgr:getFileKeyValue('RankFileInfo','rwin',nil)
end  

RankWindow.getCharmRankLocal = function (self)
	return g_DiskDataMgr:getFileKeyValue('RankFileInfo','rcharm',nil)
end

-- function: 拉取排行榜信息
-- typeNum [number] :  1:今日巅峰榜
--					2:超级土豪榜
--					3:超级战神榜
RankWindow.requestRankList = function (self, typeNum)
DebugLog("ttt RankWindow.requestRankList");
	local lastTime = 0;
	if typeNum == 1 and self.localTopData then
		lastTime = self.localTopData.data.time
	elseif typeNum == 2 and self.localPaiJuData then
		lastTime = self.localPaiJuData.data.time
	elseif typeNum == 3 and self.localWinData then
		lastTime = self.localWinData.data.time
	elseif typeNum == 4 and self.localCharmData then
		lastTime = self.localCharmData.data.time
	end

	local t = {};
	t.mid = self.myself.mid;
	t.lasttime = lastTime or 0;
	t.type = typeNum;
	if typeNum == 4 then 
		t.lastW = 1
	end 
    SocketManager.getInstance():sendPack(PHP_CMD_REQEUST_GET_RANK_LIST, t);
	--HttpModule.getInstance():execute(HttpModule.s_cmds.getRankList, t,self.m_event);
end

-- 请求获取奖励
RankWindow.requestRankReward = function (self)
	local prama = {};
	prama.mid = self.myself.mid;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_CHARM_RANK, prama);
end

-- 请求今日巅峰榜获取奖励
RankWindow.requestRankTopReward = function (self)
	local prama = {};
	prama.mid = self.myself.mid;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_TOP_RANK_REWARD, prama);
end

-- 排行榜的php获取到数据
RankWindow.onHttpRequestsCallBack = function (self ,command, isSuccess, data , jsonData)
	if HttpModule.s_cmds.getRankList == command then
		self:getRankCallBack(isSuccess ,data ,jsonData);
	end
end

RankWindow.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param,...)
	end
end

RankWindow.getRankCallBack = function(self, isSuccess, data, jsonData)
	Loading.hideLoadingAnim();
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		local callbackType = tonumber(data.data.type) or 0;
		local updateState = tonumber(data.status) or -2;
		if callbackType == 1 then
			self:getTopRank(data, jsonData, data.msg or "", updateState);
		elseif callbackType == 2 then
			self:getPaiJuRank(data, jsonData, updateState);
		elseif callbackType == 3 then
			self:getWinRank(data, jsonData, updateState);
		elseif callbackType == 4 then
			self:getCharmRank(data, jsonData, updateState);
		end
	end
end

-- 获得巅峰榜数据
RankWindow.getTopRank = function(self, data, jsonData, msg, updateState)
	DebugLog("RankWindow.getTopRank")
	if updateState == 1 then
		-- 更新本地缓存数据
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rtop',data)
		self.paiJuData = data;
		self.localTopData = data;
	end

	msg = self.localTopData.msg or msg;
	self.m_top_levelStr = self.localTopData.data.info.level or "";
	self.m_top_moneyStr = self.localTopData.data.info.money or "";
	if tonumber(self.m_top_moneyStr) and tonumber(self.m_top_moneyStr) < 0 then 
		self.m_top_moneyStr = 0 .. "";
	end
	self.m_top_wintimeStr  = self.localTopData.data.info.wintimes or "";
	self.m_top_drawtimeStr = self.localTopData.data.info.drawtimes or "";
	self.m_top_losttimeStr = self.localTopData.data.info.losetimes or "";
	self:updateMyDataInfoView(1);


	--mahjongPrint(self.localTopData)

	self:createTopRankView(self.localTopData.data, msg);  --创建榜单
	self.m_topListCreated = true;
end

-- 获得土豪榜数据
RankWindow.getPaiJuRank = function(self, data, jsonData, updateState)
	if updateState == 1 then
		-- 更新本地缓存数据
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rmoney',data)
		self.paiJuData = data;
		self.localPaiJuData = data;
	end

	self.m_nameStr  = self.localPaiJuData.data.name or "";
	self.m_moneyStr = self.localPaiJuData.data.money or "";
	self.m_titleStr = self.localPaiJuData.data.title or "";
	self:setMyMoneyInfoView();

	self:creatPaiJuRankListView(self.localPaiJuData.data);  --创建榜单
	self.m_moneyListCreated = true;
end

-- 获得战神榜数据
RankWindow.getWinRank = function(self, data, jsonData, updateState)
	if updateState == 1 then
		--更新本地缓存数据
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rwin',data)
		self.winData = data;
		self.localWinData = data;
	end
	
	self.m_nameStr   = self.localWinData.data.name or "";
	self.m_recordStr = self.localWinData.data.record or "";
	self.m_levelStr  = self.localWinData.data.level or "";
	self:setMyWinInfoView();

	self:creatWinRankListView(self.localWinData.data);  --创建榜单
	self.m_winListCreated = true;
end

--获得 魅力榜 数据
RankWindow.getCharmRank = function(self, data, jsonData, updateState)
	if updateState == 1 then
		--更新本地缓存数据
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rcharm',data)
		local award = tonumber(data.data.award);
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rcharmAward',award)
		self.winData = data;
		self.localCharmData = data;
	end
	-- = data;
	
	self.m_nameStr = self.localCharmData.data.name or "";
	self.m_charm   = self.localCharmData.data.meili_week or 0;
	self.m_charmLevel = tonumber(self.localCharmData.data.charm_level) or 0;
	self:setMyCharmInfoView();
	self:creatCharmRankListView(self.localCharmData.data, self.localCharmData.msg);  --创建榜单
	self.m_charmListCreated = true;
end


-- 获得排行榜奖励
RankWindow.getRankReward = function (self, isSuccess, data)
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rcharmAward',0)
		AnimationAwardTips.play(tostring(data.msg));
		showGoldDropAnimation();
		self:setAwardBtnCanClick(self.m_charmRewardBtn, false );
	end
end

-- 获得巅峰榜奖励
RankWindow.getRankTopReward = function (self, isSuccess, data)
	DebugLog("RankWindow.getRankTopReward")
	if not isSuccess or not data then
        return;
    end
	if isSuccess then
		g_DiskDataMgr:setFileKeyValue('RankFileInfo','rtopAward',1)
		AnimationAwardTips.play(tostring(data.msg
			));
		showGoldDropAnimation();
		self:setAwardBtnCanClick(self.m_topRewardBtn, false );
	end
end

----获取排行榜
--RankWindow.request_rank_list = function (self)
--	local prama = {};
--	prama.mid = self.myself.mid;
--	SocketManager.getInstance():sendPack(PHP_CMD_REQUIRE_CHARM_RANK, prama);
--end

--获取排行榜-回调
RankWindow.get_rank_list = function (self,  isSuccess, data, jsonData)
    self:getRankCallBack(isSuccess ,data ,jsonData );
end

RankWindow.createTopRankContent = function ( self, data , istoday)

	local content

	if istoday then 
		content = self:praseRankContent(data.content);
	else 
		content = self:praseRankContent(data.ytop);
	end 	

	if content and #content > 0 then
		table.sort(content, rankSort);

		local adapter = new(CacheAdapter, TopRankItem, content);

		publ_getItemFromTree(self.m_rankTopSubView, {"top_view","listview"}):setAdapter(adapter);

		publ_getItemFromTree(self.m_rankTopSubView, {"top_view","text_nodate"}):setVisible(false);
	else
		publ_getItemFromTree(self.m_rankTopSubView, {"top_view","listview"}):setAdapter(nil);		
		publ_getItemFromTree(self.m_rankTopSubView, {"top_view","text_nodate"}):setVisible(true);
	end
end

RankWindow.createCharmRankContent = function ( self, data , istoday)
	local content

	if istoday then 
		content = self:praseRankContent(data.content);
	else 
		content = self:praseRankContent(data.ytop);
	end 	

	if content and #content > 0 then
		table.sort(content, rankSort);

		local adapter = new(CacheAdapter, CharmRankListItem, content);

		publ_getItemFromTree(self.m_rankCharmSubView, {"top_view","listview"}):setAdapter(adapter);
		publ_getItemFromTree(self.m_rankCharmSubView, {"top_view","text_nodate"}):setVisible(false);
	else
		publ_getItemFromTree(self.m_rankCharmSubView, {"top_view","listview"}):setAdapter(nil);		
		publ_getItemFromTree(self.m_rankCharmSubView, {"top_view","text_nodate"}):setVisible(true);
	end
end

--创建巅峰榜页面
RankWindow.createTopRankView = function(self, data , msg)
	DebugLog("RankWindow.createTopRankView...")
	self.curTopRankIsToday = true
	--mahjongPrint(data)
	self:createTopRankContent(data,true)

	local awardTag = tonumber(data.award) or 0;
	--领奖文字
	publ_getItemFromTree(self.m_rankTopSubView, {"mid_view","Text1"}):setText(msg);
	
	--领奖按钮
	self:setAwardBtnCanClick( self.m_topRewardBtn,false );
	self.m_topRewardBtn:setOnClick(self, function (self)
		self:requestRankTopReward();
	end);

	local hasAward = g_DiskDataMgr:getFileKeyValue('RankFileInfo','rtopAward',0)
	--已经领过奖或者不能领奖
	DebugLog("awardTag: ".. awardTag)
	DebugLog("hasAward: ".. hasAward)

	if awardTag == 1 and hasAward ~= 1 then
		self:setAwardBtnCanClick( self.m_topRewardBtn,true );
	else
		self:setAwardBtnCanClick( self.m_topRewardBtn,false );
	end

	Loading.hideLoadingAnim();
end

--创建土豪榜列表
RankWindow.creatPaiJuRankListView = function (self , data)
	--self.nodePaiJuList:removeAllChildren();
	local content = self:praseRankContent(data.content);
	if content and #content > 0 then
		table.sort(content, rankSort);
		local adapter = new(CacheAdapter, PaiJuRankListItem, content);

		publ_getItemFromTree(self.m_rankMoneySubView, {"top_view","listview"}):setAdapter(adapter);

		publ_getItemFromTree(self.m_rankMoneySubView, {"top_view","text_nodate"}):setVisible(false);
	else
		publ_getItemFromTree(self.m_rankMoneySubView, {"top_view","text_nodate"}):setVisible(true);
	end
	Loading.hideLoadingAnim();
end

--创建战神榜列表
RankWindow.creatWinRankListView = function (self , data)
	--self.nodeWinList:removeAllChildren();
	local content = self:praseRankContent(data.content);

	if content and #content > 0 then
		table.sort(content, rankSort);
		local adapter = new(CacheAdapter, WinRankListItem, content);
		publ_getItemFromTree(self.m_rankWinSubView, {"top_view","listview"}):setAdapter(adapter);

		publ_getItemFromTree(self.m_rankWinSubView, {"top_view","text_nodate"}):setVisible(false);
	else
		publ_getItemFromTree(self.m_rankWinSubView, {"top_view","text_nodate"}):setVisible(true);
	end
	Loading.hideLoadingAnim();
end

--创建魅力榜列表
RankWindow.creatCharmRankListView = function (self , data, str)

	local awardTag = tonumber(data.award) or 0;
	local msg = str
	self.curCharmRankIsToday = true
	self:createCharmRankContent(data,true)

	--领奖文字
	publ_getItemFromTree(self.m_rankCharmSubView, {"mid_view","Text1"}):setText(msg);
	
	--领奖按钮
	self:setAwardBtnCanClick( self.m_charmRewardBtn,false );
	self.m_charmRewardBtn:setOnClick(self, function (self)
		self:requestRankReward();
	end);

	local hasAward = g_DiskDataMgr:getFileKeyValue('RankFileInfo','rcharmAward',0)
	--已经领过奖或者不能领奖

	if awardTag ~= 1 or hasAward ~= 1 then
		self:setAwardBtnCanClick( self.m_charmRewardBtn,false );
	else
		self:setAwardBtnCanClick( self.m_charmRewardBtn,true );
	end

	Loading.hideLoadingAnim();
end

RankWindow.praseRankContent = function (self , data)
	local content = {};

	if not data or (data and data == nil) then 
		return content
	end 

	for k , v in pairs(data) do
		if not v or v == false or v == true then
			return content;
		end
		v.rankRef = self;
		table.insert(content , v);
	end
	return content;
end

function rankSort(s1 , s2)
	return s1.rank < s2.rank
end


RankWindow.onClickSwitchTopRank = function ( self )
	--self:createTopRankView(self.localTopData.data,self.localTopData.msg or "");
	self.curTopRankIsToday = not self.curTopRankIsToday
	self:createTopRankContent(self.localTopData.data,self.curTopRankIsToday)

	--	self.m_switchTopRankBtn         = publ_getItemFromTree(self.tabView, {"topInfo" , "mid_view", "Button2"});
	if self.curTopRankIsToday then 
		publ_getItemFromTree(self.m_switchTopRankBtn,{"Text2"}):setText("昨日榜单")--
	else 
		publ_getItemFromTree(self.m_switchTopRankBtn,{"Text2"}):setText("今日榜单")--"今日榜单"
	end 
end

RankWindow.onClickSwitchCharmRank = function ( self )
	self.curCharmRankIsToday = not self.curCharmRankIsToday
	self:createCharmRankContent(self.localCharmData.data,self.curCharmRankIsToday)
	if self.curCharmRankIsToday then 
		publ_getItemFromTree(self.m_switchCharmRankBtn,{"Text2"}):setText("上周榜单")--
	else 
		publ_getItemFromTree(self.m_switchCharmRankBtn,{"Text2"}):setText("本周榜单")--"今日榜单"
	end 	
end


RankWindow.phpMsgResponseCallBackFuncMap = {
	[PHP_CMD_REQUIRE_CHARM_RANK]					= RankWindow.getRankReward,
	[PHP_CMD_REQUIRE_TOP_RANK_REWARD]				= RankWindow.getRankTopReward,
    [PHP_CMD_REQEUST_GET_RANK_LIST] = RankWindow.get_rank_list,
}