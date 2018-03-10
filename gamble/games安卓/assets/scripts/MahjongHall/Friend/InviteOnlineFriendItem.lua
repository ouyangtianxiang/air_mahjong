local onlineFriendListItem = require(ViewLuaPath.."onlineFriendListItem");
local VipIcon_map = require("qnPlist/VipIcon")

InviteOnlineFriendItem = class(Node);

--好友 元素
InviteOnlineFriendItem.ctor = function ( self, data)
	DebugLog("InviteOnlineFriendItem.ctor")
	self._layout = SceneLoader.load(onlineFriendListItem);
    self:addChild(self._layout);	


    self:getContrls()

    self.mHeadIconDir = "";
    self:init(data)
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    self:setAlign(kAlignTopLeft);
    self:setPos(0,0);
    self:setSize(self._layout:getSize());
end

InviteOnlineFriendItem.dtor = function ( self )
	DebugLog("InviteOnlineFriendItem.dtor")
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

	delete(self._anim)
	self._anim = nil
end

InviteOnlineFriendItem.init = function (self,data)

    self.m_data = data ;
	---name
	local namestr = data.alias;
	if not namestr or string.len(namestr) <= 0 then
		namestr = data.mnick;
	end
    self._name  = data.mnick
    self:setName(namestr)

    ---head
    self:setHeadIcon(data.small_image,data.sex)


    self.mid = data.mid 
    if data.vip_level and data.vip_level > 0 then 
        local validLevel = data.vip_level
        if validLevel > 10 then 
            validLevel = 10
        end 
        local m_vipImg = UICreator.createImg(VipIcon_map["V"..validLevel..".png"])
        m_vipImg:setPos(65+12,15+12)
        self._layout:addChild(m_vipImg)
    end 

end

InviteOnlineFriendItem.setName =  function ( self, name)
	self.m_nameText:setText(stringFormatWithString(name, 10, true))
end



InviteOnlineFriendItem.setHeadIcon =  function ( self, url, sex)
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
end



--private
InviteOnlineFriendItem.onClickInvite = function ( self )
	self.m_inviteBtn:setPickable(false);
    self.m_inviteBtn:setGray(true);

    self._anim = new(AnimInt,kAnimNormal,0,1,10000);
    self._anim:setEvent(self, function ( self )
		self.m_inviteBtn:setPickable(true);
	    self.m_inviteBtn:setGray(false);

	    delete(self._anim)
	    self._anim = nil
    end);

    self:sendInviteRequest()
end

function InviteOnlineFriendItem:sendInviteRequest( )
    --比赛中邀请
--    if self.m_data.match_func and self.m_data.obj then
--        self.m_data.match_func(self.m_data.obj);
--        return;
--    end
    --比赛中邀请
    if self.m_data.d then
        local myself = PlayerManager.getInstance():myself();
        local param = {};
        param.a_uid = tonumber(myself.mid) or -1;
        param.b_uid = self.m_data.mid;
        param.a_name = myself.nickName;
        param.b_name = self.m_data.mnick;
        param.match_level = self.m_data.d.match_level;
        param.match_type = self.m_data.d.match_type;
        param.match_name = self.m_data.d.match_name;
        param.cmd2     = FRIEND_CMD_INVITE_MATCH
        SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
        return;
    end

    local params = {}
    params.friends = {}
    local item  = {}
    item.name   = self._name
    item.mid    = tonumber(self.mid) or 0
    table.insert(params.friends, item )

    params.mid  = tonumber(PlayerManager.getInstance():myself().mid) 
    params.name = PlayerManager.getInstance():myself().nickName 
    
    params.fid      = 0 
    params.roundNum = 0
    params.wanfa    = 0
    
    if FriendMatchRoomScene_instance then 
       params.roundNum,params.fid,params.wanfa = FriendMatchRoomScene_instance:getInviteRequestData()
    end 
    
    params.cmd2     = FRIEND_CMD_BATTLE_INVITE
    SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD, params);
end



InviteOnlineFriendItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.mHeadIconDir then
	        --self.m_headImg:setFile(self.mHeadIconDir);
        	setMaskImg(self.m_headImg,"Hall/hallRank/head_mask.png",self.mHeadIconDir)
        end
    end
end


InviteOnlineFriendItem.getContrls = function ( self )

	self.m_headBg      = publ_getItemFromTree(self._layout, {"head_bg"})
	self.m_headImg     = publ_getItemFromTree(self._layout, {"head_bg","head"})
	self.m_nameText    = publ_getItemFromTree(self._layout, {"name"})
	self.m_inviteBtn   = publ_getItemFromTree(self._layout, {"invite"})

	self.m_inviteBtn:setOnClick(self,self.onClickInvite)
end