local friendNewsItem = require(ViewLuaPath.."friendNewsItem");
local hall_user_infoPin_map = require("qnPlist/hall_user_infoPin")

FriendNewsListItem = class(Node);

--好友 元素
FriendNewsListItem.ctor = function ( self, width, height, friendWindow, index, data)
	
	self.mIndex 	  = index;
	self.mFriendWindow= friendWindow;
	self.mFriendItem  = SceneLoader.load(friendNewsItem);

	publ_getItemFromTree(self.mFriendItem, {"view_item"}):setSize(width, height);

    self:addChild(self.mFriendItem);
    self:setSize(width, height);


    self.mHeadBtn = publ_getItemFromTree(self.mFriendItem, {"view_item","view_infor","img_headBtn"});
    self.mHeadBtn:setPickable(false)

    self.mHeadImg = publ_getItemFromTree(self.mHeadBtn,{"img_headicon"})

    local sex = data.sex or 0;  
    local imageUrl = data.photo or "";  -- 头像地址

    local isExist , localDir = NativeManager.getInstance():downloadImage(imageUrl);
    self.localDir = localDir; -- 下载图片
    if not isExist then
        if tonumber(kSexMan) == tonumber(sex) then
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
    setMaskImg(self.mHeadImg,"Hall/hallRank/head_mask.png",localDir)
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);    

    self.nameText = publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "text_name"})
    self.btn1 = publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_1"})--
    self.btn2 = publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_2"})--  
 
    ---设置
    if tonumber(data.type) == 1 then
    	self.nameText:setText(data.mnick);
    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "text_name1"}):setText("申请成为你的好友");

    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_1", "text_name"}):setText("同 意");
    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_2", "text_name"}):setText("忽 略");

    	self.btn1:setOnClick(self, function ( self )
    		-- body
    		if self.mOnClick then
    			self.mOnClick(self.mFriendWindow, self.mIndex, 1);
    		end
    	end);

    	self.btn2:setOnClick(self, function ( self )
    		-- body
    		if self.mOnClick then
    			self.mOnClick(self.mFriendWindow, self.mIndex, 2);
    		end
    	end);
    	
    elseif tonumber(data.type) == 2 then

    	local name = FriendDataManager.getInstance():getFriendNameById( data.mid );
    	if not name or string.len(name) then
    		name = data.mnick;
    	end
    	self.nameText:setText(name);
    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "text_name1"}):setText("赠送给你"..data.money.."金币");
        publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_1", "text_name"}):setText("收 取");
    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_2", "text_name"}):setText("回 赠");
    	self.btn1:setOnClick(self,  function ( self )
            -- body
            if self.mOnClick then
                self.mOnClick(self.mFriendWindow, self.mIndex, 1);
            end
        end);
    	self.btn2:setOnClick(self,  function ( self )
    		-- body
    		if self.mOnClick then
    			self.mOnClick(self.mFriendWindow, self.mIndex, 2);
    		end
    	end);

        self.btn2:setPos(self.btn1:getPos())

        self:setFeedbackState(data.needFeedback)

    elseif tonumber(data.type) == 3 then
    	local name = FriendDataManager.getInstance():getFriendNameById( data.mid );
    	if not name or string.len(name) then
    		name = data.mnick;
    	end
    	self.nameText:setText(name);
    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "text_name1"}):setText("给你发送了消息");

    	publ_getItemFromTree(self.mFriendItem, {"view_item", "view_operator", "btn_1", "text_name"}):setText("查 看");
    	self.btn2:setVisible(false);

    	self.btn1:setOnClick(self,  function ( self )
    		-- body
    		if self.mOnClick then
    			self.mOnClick(self.mFriendWindow, self.mIndex, 1);
    		end
    	end);
    end
    self.vipImg   = publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "vip_img"})
    self.charmImg = publ_getItemFromTree(self.mFriendItem, {"view_item", "view_infor", "charm_img"})

    self.vipImg:addPropScaleSolid(1, 0.8, 0.8, kCenterDrawing);
    self.charmImg:addPropScaleSolid(1, 0.76, 0.76, kCenterDrawing);

    local vipLevel   = self:setSuitableValue(data.vip,0,10)
    local charmLevel = self:setSuitableValue(data.charms,0,9)

    local charmFileName = nil 
    if charmLevel < 7 then 
        charmFileName = "Hall/hallRank/charm_level_"..charmLevel..".png"
    else 
        charmFileName = "Hall/hallRank/charm_level_"..charmLevel.."_"..sex..".png"
    end 
    self.charmImg:setFile(charmFileName)


    local x,y = self.nameText:getPos()
    local w,h = self.nameText:getSize()
    self.vipImg:setPos(x+w+5,y)    
    local cx,cy = x+w+5,y
    if vipLevel < 1 then 
        self.vipImg:setVisible(false)
    else
        self.vipImg:setFile(hall_user_infoPin_map["VIP"..vipLevel..".png"])
        local w,h = self.vipImg:getSize()
        cx = cx + w*0.8
    end 
    self.charmImg:setPos(cx,cy)

    self.mOnClick = nil;


end

FriendNewsListItem.setFeedbackState = function ( self, bvalue )
--1收取,2回赠
    if bvalue then 
        self.btn1:setVisible(false)
        self.btn2:setVisible(true)
    else 
        self.btn1:setVisible(true)
        self.btn2:setVisible(false)
    end 
end

FriendNewsListItem.setSuitableValue = function ( self, value, min , max )
    local result = 0
    if value then 
        result = math.min(max,value)
        result = math.max(min,result)
    end 
    return result
end

FriendNewsListItem.setOnClick = function (self, func )
	self.mOnClick = func;
end
FriendNewsListItem.setIndex = function (self, index )
	self.mIndex = index;
end

FriendNewsListItem.dtor = function ( self )
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

FriendNewsListItem.scaleNodePos = function ( self, ndoe, scaleW, scaleH )
	-- body
	local x ,y = ndoe:getPos();
	ndoe:setPos(x * scaleW, y * scaleH );
end
FriendNewsListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            setMaskImg(self.mHeadImg,"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end

