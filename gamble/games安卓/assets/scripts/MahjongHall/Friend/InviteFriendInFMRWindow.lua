
local inviteFriendInFRoom = require(ViewLuaPath.."inviteFriendInFRoom");
require("MahjongHall/Friend/InviteOnlineFriendItem")
require("MahjongHall/Friend/InviteSocialFriendItem")

InviteFriendInFMRWindow = class(SCWindow);


--[Comment]
--fid 5.30之前房间邀请好友用的字段
--match_invite_data  5.30后 比赛邀请好友的数据
function InviteFriendInFMRWindow:ctor( fid , match_invite_data)
	-- body
	self._fid = fid
    self.m_match_invite_data = match_invite_data;
    --设置是否是在比赛中邀请
    GlobalDataManager.getInstance().m_b_invite_match = self.m_match_invite_data and true or false;


	self:initView()
	FriendDataManager.getInstance():addListener(self, self.onCallBackFunc);
end

function InviteFriendInFMRWindow:dtor(  )
	-- body
	FriendDataManager.getInstance():removeListener(self, self.onCallBackFunc);
end

function InviteFriendInFMRWindow:initOnlineView( )
	-- body
	self._onlineListView = publ_getItemFromTree(self._layout,{"bg","left","onlineFriendList"})

	FriendDataManager.getInstance():requestFriendsIsOnlineSocket()--请求在线好友

end

function InviteFriendInFMRWindow:initSocialView( )
	-- body
	self._socialListView = publ_getItemFromTree(self._layout,{"bg","right","socialFriendList"})

	local adapterData    = self:GetSocialData()
	local adpater = new(CacheAdapter, InviteSocialFriendItem, adapterData);
	self._socialListView:setAdapter(adpater)	
end



function InviteFriendInFMRWindow:initView()
	self._layout = SceneLoader.load(inviteFriendInFRoom);
	self:addChild(self._layout)

	-- RadioButton.s_defaultImages = origin
	local winBg = publ_getItemFromTree(self._layout, {"bg"});
	self:setWindowNode( winBg );
	self:setCoverEnable( true );-- 允许点击cover

	publ_getItemFromTree(self._layout,{"bg","closeBtn"}):setOnClick(self,function ( self )
		self:hideWnd()
	end)

	self:initOnlineView()
	self:initSocialView()
	
end


function InviteFriendInFMRWindow:onCallBackFunc(actionType,actionParam)
	if kFriendAllOnlineFriendsBySocket == actionType then 
		self:onRequestInvitingFriends();
	end
end

function InviteFriendInFMRWindow:filterAlreadyInRoom( data )
	local filterData = {}
	local roomPlayers = PlayerManager.getInstance().playerList

	for k,v in pairs(data) do 
		local isInRoom = false
		for k1,v1 in pairs(roomPlayers) do
			if tonumber(v.mid) == tonumber(v1.mid) then 
				isInRoom = true
				break
			end 
		end
		if not isInRoom then 
			table.insert(filterData, v)
		end 
	end
	return filterData
end

function InviteFriendInFMRWindow:onRequestInvitingFriends()
	-- body
	local data = FriendDataManager.getInstance():getOnlineFriends()
	--过滤掉已经在房间里的
	local filterData = self:filterAlreadyInRoom(data)

	local adapterData = {}
	for i=1,#filterData do
		adapterData[i] = {}
        if self.m_match_invite_data then
            adapterData[i].mid  		= filterData[i].mid
		    adapterData[i].alias  		= filterData[i].alias
		    adapterData[i].mnick  		= filterData[i].mnick
		    adapterData[i].vip_level    = filterData[i].vip_level
		    adapterData[i].smallImg  	= filterData[i].smallImg
		    adapterData[i].sex          = filterData[i].sex;
--            adapterData[i].obj = self;
--            adapterData[i].match_func = self.invite;
             adapterData[i].d = self.m_match_invite_data;
        else
        	adapterData[i].mid  		= filterData[i].mid
		    adapterData[i].alias  		= filterData[i].alias
		    adapterData[i].mnick  		= filterData[i].mnick
		    adapterData[i].vip_level    = filterData[i].vip_level
		    adapterData[i].smallImg  	= filterData[i].smallImg
		    adapterData[i].sex          = filterData[i].sex;
        end
	end
	if #adapterData <= 0 then 
		publ_getItemFromTree(self._layout,{"bg","left","noFriend"}):setVisible(true)
		return 
	end 

	local adpater = new(CacheAdapter, InviteOnlineFriendItem, adapterData);
	self._onlineListView:setAdapter(adpater)
end

InviteFriendInFMRWindow.invite = function (self)
    DebugLog("[InviteFriendInFMRWindow] invite");
    if not  self.m_match_invite_data or not self.m_match_invite_data.match_type or not self.m_match_invite_data.match_level then
        DebugLog("[InviteFriendInFMRWindow] invite data is nil");
        return;
    end

    local param = {};
    param.a_uid = 0;
    param.b_uid = 0;
    param.a_name = "";
    param.b_name = "";
    param.match_level = self.m_match_invite_data.match_level;
    param.match_type = self.m_match_invite_data.match_type;
    SocketManager.getInstance():sendPack(FRIEND_CMD_FORWARD,param);
end

function InviteFriendInFMRWindow:GetSocialData( )
	-- body
	local data = {}--GameConstant.hasWechatPackage and GameConstant.isQQInstalled--
	
	local function setItemCommonValue( item )
		item.obj   = self
		item.func  = self.onSocialInviteCallback	
		item.fid   = self._fid
	end
	--通讯录好友
	local item = {}
	item.text  = "邀请通讯录好友"
	item.icon  = "Hall/friend/item_1.png"
	item.type  = 2
	setItemCommonValue(item)
	table.insert(data,item)
	
	--易信处理
	if PlatformConfig.platformYiXin == GameConstant.platformType then 
		local item = {}
		item.text  = "邀请易信好友"
		item.icon  = "Login/yx/Login/yixin_addFriend.png"
		item.type  = 5
		setItemCommonValue(item)	
		table.insert(data,item)

		local item = {}
		item.text  = "邀请易信朋友圈"
		item.icon  = "Login/yx/Login/yixin_addFriend.png"
		item.type  = 6
		setItemCommonValue(item)	
		table.insert(data,item)

		return data
	end

	--qq安装了
	if GameConstant.isQQInstalled then 
		local item = {}
		item.text  = "邀请QQ好友"
		item.icon  = "Hall/friend/item_3.png"
		item.type  = 4
		setItemCommonValue(item)	
		table.insert(data,item)
	end 
	--微信安装了
	if GameConstant.hasWechatPackage then 
		local item = {}
		item.text  = "邀请微信好友"
		item.icon  = "Hall/friend/item_2.png"
		item.type  = 3
		setItemCommonValue(item)	
		table.insert(data,item)

		if not PlatformFactory.curPlatform:isLianYunNotChannel() then 
			local item = {}
			item.text = "邀请朋友圈好友"
			item.icon  = "Hall/friend/item_4.png"
			item.type  = 1		
			setItemCommonValue(item)
			table.insert(data,item)
		end 
	end 
	return data
end

function InviteFriendInFMRWindow:onSocialInviteCallback( )
	self:hideWnd()
end
-------兼容InviteFriendWindow----------------------
function InviteFriendInFMRWindow:updateFriend( ... )
	--do nothing
end

