local VipIcon_map = require("qnPlist/VipIcon")

--[[
	className    	     :  InviteFriendItem
	Description  	     :  To wrap the Listview of the inviting friends.
	last-modified-date   :  Dec. 6 2013
	create-time 	   	 :  Oct.31 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
InviteFriendItem = class(Node);

--[[
	function name	   : InviteFriendItem.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 data    -- list数据
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.ctor = function(self, data)
    if not data then
        return;
    end
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    --local coord = 83--CreatingViewUsingData.inviteFriendListView.bg;
    -- self:setPos(0,coord.y1);
    self.mw = 800
    self.mh = 110
    self:setSize(self.mw, self.mh);
    data.h = 83--coord.h;



    self.btnId = data.btnId;
    self.mid = data.mid;
    self.name = data.name;
    self.money = data.money;
    self.sex = data.sex;
    self.smallImg = data.smallImg;
    self.bigImg = data.bigImg;
    self.inviteRef = data.inviteRef;

    local rowNode = new(Node);

    local bigImg = self.bigImg;
    local pic_str = CreatingViewUsingData.commonData.regularJudge;
    local tempImgPic = string.find(bigImg, pic_str);
    local imgpic_name = CreatingViewUsingData.commonData.girlPicLocate;

    if tempImgPic ~= nil then
        imgpic_name = string.sub(bigImg, string.find(bigImg, pic_str));
    end
    self.m_ImgFile = nil;
    if imgpic_name == CreatingViewUsingData.commonData.boyPic or imgpic_name == CreatingViewUsingData.commonData.girlPicLocate then
        if tonumber(self.sex) == kNumZero then
            self.m_ImgFile = CreatingViewUsingData.commonData.boyPicLocate;
        else
            self.m_ImgFile = CreatingViewUsingData.commonData.girlPicLocate;
        end
    else
        local isExist, localDir = NativeManager.getInstance():downloadImage(bigImg);
        self.localDir = localDir;
        if not isExist then
            if tonumber(self.sex) == kNumZero then
                localDir = CreatingViewUsingData.commonData.boyPicLocate;
            else
                localDir = CreatingViewUsingData.commonData.girlPicLocate;
            end
        end
        self.m_ImgFile = localDir;
    end
    
    --
    self.m_headEdge = UICreator.createImg("Hall/hallRank/head_bg.png",10,10)
    setMaskImg(self.m_headEdge,"Hall/hallRank/head_mask.png",self.m_ImgFile)


    local m_SexImg;
    if tonumber(self.sex) == kNumZero then
        m_SexImg = UICreator.createImg("Commonx/male.png");
    else
        m_SexImg = UICreator.createImg("Commonx/female.png");
    end
    m_SexImg:setPos(110, self.mh/2 - 25);
    m_SexImg:setAlign(kAlignLeft)

    local m_coinImg = UICreator.createImg("Commonx/coin.png");
    m_coinImg:setPos(110, self.mh/2 + 25);
    m_coinImg:setAlign(kAlignLeft)

    local m_coinText = UICreator.createText(trunNumberIntoThreeOneFormWithInt(self.money), 160, self.mh/2 , 200, 50, kAlignLeft, 30, 0x94, 0x32, 0x00);

    local m_Name = UICreator.createText(stringFormatWithString(self.name, kMaxNameLength), 160, self.mh/2 - 50, 200, 50, kAlignLeft, 30, 0x4b, 0x2b, 0x1c);

    coord = CreatingViewUsingData.inviteFriendListView.inviteBtn;
    self.inviteBtn = UICreator.createBtn("Commonx/green_small_btn.png");
    self.inviteBtn:setFile("Commonx/green_small_btn.png", kRGBGray);

    local text = UICreator.createText("邀请", 0, -4, 60, 32, kAlignCenter, 30, 255, 255, 255);
    self.inviteBtn:addChild(text);
    text:setAlign(kAlignCenter);
    self.inviteBtn:setOnClick(self, self.onInviteClick);
    --self.inviteBtn:setSize(150, 51);
    self.inviteBtn:setPos(620, self.mh/2 - 31);

    coord = CreatingViewUsingData.inviteFriendListView.inviteAnim;
    local time = os.time();
    if GameConstant.inviteTime[self.mid .. ""] and GameConstant.inviteTime[self.mid .. ""].time then
        if time - GameConstant.inviteTime[self.mid .. ""].time > coord.time then
            self.inviteBtn:setPickable(true);
            self.inviteBtn:setGray(false);
            GameConstant.inviteTime[self.mid .. ""] = { };
        else
            self.inviteBtn:setPickable(false);
            self.inviteBtn:setGray(true);
            DebugLog(time - GameConstant.inviteTime[self.mid .. ""].time);
            self.animIndex = new(AnimInt, kAnimNormal, coord.from, coord.to,(time - GameConstant.inviteTime[self.mid .. ""].time) * kNumThousand, coord.delay);
            self.animIndex:setEvent(self, self.changeEnabled);
        end
    else
        self.inviteBtn:setPickable(true);
        self.inviteBtn:setGray(false);
        GameConstant.inviteTime[self.mid .. ""] = { };
    end
    
    local m_splitImg = UICreator.createImg("Commonx/split_hori.png")
    m_splitImg:setSize(self.mw,2)
    m_splitImg:setPos(0,self.mh -2)
    rowNode:addChild(m_splitImg)

    rowNode:addChild(self.m_headEdge);
    rowNode:addChild(m_SexImg);
    rowNode:addChild(m_Name);
    rowNode:addChild(m_coinImg);
    rowNode:addChild(m_coinText);
    rowNode:addChild(self.inviteBtn);

    if data.vip_level and data.vip_level > 0 then 
        local validLevel = data.vip_level
        if validLevel > 10 then 
            validLevel = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..validLevel..".png"])
        m_vipImg:setPos(65,15)
        rowNode:addChild(m_vipImg)
    end 

    --rowNode:setPos(CreatingViewUsingData.inviteFriendListView.bg.x2, CreatingViewUsingData.inviteFriendListView.bg.y2);

    self:addChild(rowNode);
end

--[[
	function name	   : InviteFriendItem.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.dtor = function(self)
    FriendDataManager.getInstance():removeListener(self, self.onCallingFunc);
    EventDispatcher.getInstance():unregister(NativeManager._Event , self , self.nativeCallEvent);
    self:removeAllChildren();
    delete(self.animIndex);
    self.animIndex = nil;
end

---------------------------------------------------------------------------回调函数------------------------------------------------------------------------------
--[[
	function name	   : InviteFriendItem.callEvent
	description  	   : The callBack of java.To download images.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            --self.m_Img:setFile(self.localDir);
            setMaskImg(self.m_headEdge,"Hall/hallRank/head_mask.png",self.localDir)
        end
    end
end

--[[
	function name	   : InviteFriendItem.onCallBackFunc
	description  	   : PHP或者socket请求返回.根据行为指令调用不同方法.
	param 	 	 	   : self
						 actionType  -- 行为指令
	last-modified-date : Dec. 11 2013
	create-time  	   : Dec. 11 2013
]]
InviteFriendItem.onCallingFunc = function(self, actionType)
    if kInvitingResultNoLine == actionType then
        self:changeColor();
    end
end

--[[
	function name	   : InviteFriendItem.changeColor
	description  	   : 回调事件，响应邀请时玩家退出游戏.
	param 	 	 	   : self
	last-modified-date : Dec. 6 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.changeColor = function(self)
    self.inviteBtn:setFile(CreatingViewUsingData.inviteFriendListView.inviteBtn.fileDarkName);
    self.inviteBtn:setPickable(false);
end

--------------------------------------------------------------------按键监听-------------------------------------------------------------------------------------
--[[
	function name	   : InviteFriendItem.onInviteClick
	description  	   : The  click event of inviting a friend.
	param 	 	 	   : self
	last-modified-date : Dec. 11 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.onInviteClick = function(self)
    umengStatics_lua(kUmengInviteFriend);
    
    --先判断该好友是不是已经在房间中
    local plist = PlayerManager.getInstance().playerList
    for k,v in pairs(plist) do
        if tonumber(v.mid) == tonumber(self.mid) then 
            Banner.getInstance():showMsg("该好友已经在此房间中!");
            return
        end 
    end
    --

    -- if self.active then
    self.inviteBtn:setPickable(false);
    self.inviteBtn:setGray(true);
    local coord = CreatingViewUsingData.inviteFriendListView.inviteAnim;
    self.animIndex = new(AnimInt, kAnimNormal, coord.from, coord.to, coord.time * kNumThousand, coord.delay);
    GameConstant.inviteTime[self.mid .. ""] = { };
    GameConstant.inviteTime[self.mid .. ""].time = os.time();
    self.animIndex:setEvent(self, self.changeEnabled);
    FriendDataManager.getInstance():addListener(self, self.onCallingFunc);
    FriendDataManager.getInstance():inviteFriendByIdSocket(self.mid, self.name);
    self.active = true;
    -- end
end

--[[
	function name	   : InviteFriendItem.changeEnabled
	description  	   : 邀请好友按键动画.(10秒压下效果)
	param 	 	 	   : self
	last-modified-date : Dec. 11 2013
	create-time  	   : Oct.31 2013
]]
InviteFriendItem.changeEnabled = function(self)
    self.inviteBtn:setPickable(true);
    self.inviteBtn:setGray(false);
    GameConstant.inviteTime[self.mid .. ""] = { };
    delete(self.animIndex);
    self.animIndex = nil;
end

