local friendListItem = require(ViewLuaPath.."friendListItem");
local VipIcon_map = require("qnPlist/VipIcon")

FriendListItem = class(Node);

--好友 元素
FriendListItem.ctor = function ( self, data)
	DebugLog("FriendListItem.ctor")

    self:init(data)

end

FriendListItem.dtor = function ( self )
	DebugLog("FriendListItem.dtor")
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

FriendListItem.init = function (self,data)
    self.mFriendItem = SceneLoader.load(friendListItem);
    self:getContrls()

    self:setAlign(kAlignTopLeft);
    self:setPos(0,0);
    self:setSize(self.mFriendItem:getSize());
    self:addChild(self.mFriendItem);


    self.m_head:addPropScaleSolid(0,0.9,0.9,kCenterDrawing)
    self.mOnClickEvent = {};
    self.mOnClickFreeEvent = {};
    self.mHeadIconDir = "";

    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);




	local namestr = data.alias;
	if not namestr or string.len(namestr) <= 0 then
		namestr = data.mnick;
	end
    --设置头像
    self:setHeadIcon(data.small_image,data.sex)
    --设置名字
    self:setName(namestr)
    --设置money
    self:setMoney(data.money)
    self.mid = tostring(data.mid) 


    if data.vip_level and data.vip_level > 0 then 
        local validLevel = data.vip_level
        if validLevel > 10 then 
            validLevel = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..validLevel..".png"])
        m_vipImg:setPos(65,15)
        self.mFriendItem:addChild(m_vipImg)
    end 

    self:setOnline(data.online)
    self:setFreeIcon(data.gift_status)
end

--设置 点击 回调
FriendListItem.setOnClick = function ( self, obj, id, func)
	-- body
	self.mOnClickEvent.obj = obj;
	self.mOnClickEvent.id  = id;
	self.mOnClickEvent.func= func;
end

--设置 点击免费 回调
FriendListItem.setOnFreeClick = function ( self, obj,  id, func)
	-- body
	self.mOnClickFreeEvent.obj = obj;
	self.mOnClickFreeEvent.id  = id;
	self.mOnClickFreeEvent.func= func;
end

FriendListItem.setName =  function ( self, name)
    if not name then
        return;
    end
	-- body
	self.m_nameText:setText(stringFormatWithString(name, 10, true))
end

FriendListItem.setMoney =  function ( self, money)
    if not tonumber(money) then
        return;
    end
	DebugLog("FriendListItem.setMoney: "..tostring(money))
	self.m_moneyText:setText(trunNumberIntoThreeOneFormWithInt(money or 0, true))
end



FriendListItem.setHeadIcon =  function ( self, url, sex)
    local isExist, localDir = NativeManager.getInstance():downloadImage(url);
	self.mHeadIconDir = localDir;
    if not isExist then -- 图片已下载
    	if tonumber(sex) == 0 then
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
    setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",localDir)

    --self.m_headImg:setFile(localDir);
    --self.m_headImg:setSize(84,84);
end

FriendListItem.setOnline =  function ( self, online)
	-- body
	if online then
		self.m_headImg:setColor(255,255,255);
	else
		self.m_headImg:setColor(128,128,128);
	end
end

FriendListItem.updateIcon = function( self, url )
	local isExist , localDir = NativeManager.getInstance():downloadImage(url);
	if isExist and localDir then
        setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",localDir)
	end
end

FriendListItem.setBg = function (self, bg)
    if not bg then
        return;
    end
    self.m_bgBtn:setFile(bg);
end

--private
FriendListItem.onClick = function ( self )
	-- body
	if self.mOnClickEvent.func then
		self.mOnClickEvent.func(self.mOnClickEvent.obj, self.mOnClickEvent.id);
	end
end

FriendListItem.onFreeClick = function ( self )
	-- body
	if self.mOnClickFreeEvent.func then
		self.mOnClickFreeEvent.func(self.mOnClickFreeEvent.obj, self.mOnClickFreeEvent.id);
	end
end

FriendListItem.setFreeIcon = function ( self, status)
	-- body
	if status ~= 0 then
		self.m_sendBtn:setFile("Hall/HallSocial/coined.png");
		--self.m_sendBtn:setGray(true)
		self.m_sendBtn:setPickable(false);
	end
end


FriendListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.mHeadIconDir then
	        --self.m_headImg:setFile(self.mHeadIconDir);
        	setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",self.mHeadIconDir)
        end
    end
end


FriendListItem.getContrls = function ( self )
	self.m_bgBtn 	 = publ_getItemFromTree(self.mFriendItem, {"bg_btn"})
	self.m_headImg   = publ_getItemFromTree(self.mFriendItem, {"bg_btn","bg","head_img"})
	self.m_head      = publ_getItemFromTree(self.mFriendItem, {"bg_btn","bg"})
	--self.m_crownImg  = publ_getItemFromTree(self.mFriendItem, {"bg_btn","head_img","crown_img"})
	self.m_nameText  = publ_getItemFromTree(self.mFriendItem, {"bg_btn","name_text"})
	self.m_moneyText = publ_getItemFromTree(self.mFriendItem, {"bg_btn","money_text"})
	self.m_sendBtn   = publ_getItemFromTree(self.mFriendItem, {"bg_btn","send_btn"})

	--self.m_bgBtn:setType(Button.White_Type)
	self.m_bgBtn:setOnClick(self,self.onClick)
	self.m_sendBtn:setOnClick(self,self.onFreeClick)

--	if PlatformConfig.platformWDJ == GameConstant.platformType or 
--	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
--    	self.m_bgBtn:setFile("Login/wdj/Hall/HallSocial/itemBg.png");
--    end
end