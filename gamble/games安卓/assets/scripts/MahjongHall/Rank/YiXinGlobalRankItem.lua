--[[ 
	YiXinGlobalRankItem.lua
	Author: YifanHe
	Date: 2014-02-18
	Last modification : 2014-02-18
	Description:今日巅峰榜中玩家展示节点类
]]--
local yiglobalItem = require(ViewLuaPath.."yiglobalItem");

YiXinGlobalRankItem = class(Node)

YiXinGlobalRankItem.ctor = function(self, data)
	if not data then
		return;
	end

	mahjongPrint(data)

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.listItem = SceneLoader.load(yiglobalItem);
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

	if data.isFriend == 0 then 
		self.m_addBtn:setVisible(true);
		self.m_addBtn:setOnClick(self,self.onAddFriendBtn);
	elseif data.isFriend == 1 then 
		self.m_addBtn:setVisible(true);
		self.m_addBtn:setFile("Commonx/gray_small_btn.png");
		self.m_addBtn:setPickable(false);
		self.m_addBtn:setGray(true);
	else
		self.m_addBtn:setVisible(false);
	end
end

YiXinGlobalRankItem.getAllControls = function(self)
	self.m_placeImg = publ_getItemFromTree(self.listItem,{"item_view","place_img"});
	self.m_placeBg = publ_getItemFromTree(self.listItem,{"item_view","view_place"});
	self.m_placeText = publ_getItemFromTree(self.listItem,{"item_view","view_place","Text2"});
	self.m_headBg = publ_getItemFromTree(self.listItem,{"item_view","head_bg"});
	self.m_nick = publ_getItemFromTree(self.listItem,{"item_view","nick"})
	self.m_coin = publ_getItemFromTree(self.listItem,{"item_view","coin"});
	self.m_addBtn = publ_getItemFromTree(self.listItem,{"item_view","addBtn"});
end

YiXinGlobalRankItem.onAddFriendBtn = function(self)
	if not self.data then 
		return ;
	end

	self.m_addBtn:setFile("Commonx/gray_small_btn.png");
	self.m_addBtn:setPickable(false);
	self.m_addBtn:setGray(true);

	local date = os.date("%x");
	g_DiskDataMgr:setAppData("yixin_date_global" .. self.data.accountId,date);

	local param_data = {};
	param_data.accountId = self.data.accountId;
	local dataStr = json.encode(param_data);
	native_to_java(kyixinAddFriend,dataStr);

	--去添加
	local param = {};
	param.account = self.data.accountId;
	HttpModule.getInstance():execute(HttpModule.s_cmds.shareAddFriend, param, self.m_event);

end

YiXinGlobalRankItem.dtor = function(self)
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():unregister(self.m_event,self,self.onHttpRequestsCallBack);
	self:removeAllChildren();
end


YiXinGlobalRankItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	self.m_headBg:setFile(self.localDir);
            setMaskImg(self.m_headBg,"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end


