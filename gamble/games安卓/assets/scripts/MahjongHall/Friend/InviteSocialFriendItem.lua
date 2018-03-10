local socialFriendListItem = require(ViewLuaPath.."socialFriendListItem");


InviteSocialFriendItem = class(Node);

--好友 元素
InviteSocialFriendItem.ctor = function ( self, data)
	DebugLog("InviteOnlineFriendItem.ctor")
	self._layout = SceneLoader.load(socialFriendListItem);
    self:addChild(self._layout);	


    self:getContrls()
    self.m_data = data;
    self:init(data)

    self:setAlign(kAlignTopLeft);
    self:setPos(0,0);
    self:setSize(self._layout:getSize());
end

InviteSocialFriendItem.dtor = function ( self )
	self._obj  = nil 
	self._func = nil 
end

InviteSocialFriendItem.init = function (self,data)

	---name
	self.m_text:setText(data.text)
    ---head
    self.m_icon:setFile(data.icon)

    self._fid  = data.fid
    self._obj  = data.obj
    self._func = data.func
    self._type = data.type
end


--private
InviteSocialFriendItem.onClickInvite = function ( self )
	if self._type == 1 then 
		self:onClickedFriendCircleBtn()
	elseif self._type == 2 then 
		self:onClickedPhoneBtn()
	elseif self._type == 3 then 
		if PlatformFactory.curPlatform:isLianYunNotChannel() then --联运
			self:onClickedWechatBtnForLianYun()
		else 
			self:onClickedWebchatBtn()
		end 
	elseif self._type == 5 then --易信好友
		self:onClickYixinFriend()
	elseif self._type == 6 then --易信朋友圈
		self:onClickYixinCircle()
	else 
		if PlatformFactory.curPlatform:isLianYunNotChannel() then --联运
			self:onClickedQQBtnForLianYun()
		else 
			self:onClickedQQBtn()
		end 		
	end 
end

--易信好友
function InviteSocialFriendItem:onClickYixinFriend(  )
	self:share(self:getShareContentByType("qq"), 6,"yixinFriend")
	self._func(self._obj)
end

--易信朋友圈
function InviteSocialFriendItem:onClickYixinCircle(  )
	self:share(self:getShareContentByType("weixin"), 7,"yixinCircle")
	self._func(self._obj)
end

InviteSocialFriendItem.getContrls = function ( self )

	self.m_icon        = publ_getItemFromTree(self._layout, {"Button4","icon"})
	self.m_text        = publ_getItemFromTree(self._layout, {"Button4","name"})

	self.m_inviteBtn   = publ_getItemFromTree(self._layout, {"Button4"})
	self.m_inviteBtn:setOnClick(self,self.onClickInvite)
end


function InviteSocialFriendItem:getShareContentByType( key )
	local msg = nil

	local ref = GlobalDataManager.getInstance().m_b_invite_match and GlobalDataManager.getInstance().fm_match_invite_data 
                or GlobalDataManager.getInstance().fmInviteInfo
	if ref and key then 
		msg = ref[key]
	end 
	return msg
end

function InviteSocialFriendItem:onClickedWebchatBtn( )
	-- body
	self:share(self:getShareContentByType("weixin"), 3,"weixin")
	self._func(self._obj)
end


function InviteSocialFriendItem:onClickedWechatBtnForLianYun()
	local data = self:getShareContentByType("weixin");
	mahjongPrint(data);

	local param = {}
	local appName = "【" .. GameConstant.appName .. "】";
	local title = data.title or "";
	local fid = "房间号码【" .. (self._fid or "").. "】";
	local url = "可以打开链接地址" .. (data.url or "") .. "或者长按复制打开游戏即可进入房间!";

	param.message = appName .. title .. "，" .. fid .. "，" .. url;
	native_to_get_value(kCopyClipBoard, json.encode(param));

	self._func(self._obj)

	local text = "我们已经帮你【复制了房间信息】，直接打开微信选择好友进行【粘贴】即可邀请好友对战啦！";
							
	local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"打开微信","取消");
	view:setConfirmCallback(self, function ( self )
		local param = {};
		param.style = 2;
		native_to_java(kGoToQQOrWechat,json.encode(param));
		
	end);
	view:setCallback(view, function ( view, isShow )
		if not isShow then
			
		end
	end);


end

function InviteSocialFriendItem:onClickedQQBtnForLianYun()
	local data = self:getShareContentByType("qq");
	mahjongPrint(data);

	local param = {}
	local appName = "【" .. GameConstant.appName .. "】";
	local title = data.title or "";
	local fid = "房间号码【" .. (self._fid or "").. "】";
	local url = "可以打开链接地址" .. (data.url or "") .. "或者长按复制打开游戏即可进入房间!";

	param.message = appName .. title .. "，" .. fid .. "，" .. url;
	native_to_get_value(kCopyClipBoard, json.encode(param));

	self._func(self._obj)

	local text = "我们已经帮你【复制了房间信息】，直接打开QQ选择好友进行【粘贴】即可邀请好友对战啦！";
							
	local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"打开QQ","取消");
	view:setConfirmCallback(self, function ( self )
		local param = {};
		param.style = 1;
		native_to_java(kGoToQQOrWechat,json.encode(param));
	end);
	view:setCallback(view, function ( view, isShow )
		if not isShow then
			
		end
	end);
end


function InviteSocialFriendItem:onClickedFriendCircleBtn( )
	-- body
--    if self.m_data.d then
--    else
        self:share(self:getShareContentByType("pyq"), 1,"pyq")
--    end
	

	self._func(self._obj)
end

--短信是php发
function InviteSocialFriendItem:onClickedPhoneBtn( ... )

	self._func(self._obj)
	require("MahjongRoom/FriendMatchRoom/FMRInviteSMSFriendWin")
	local smsWin = new(FMRInviteSMSFriendWin)
	GameConstant.curGameSceneRef:addChild(smsWin)
	smsWin:showWnd()
end

function InviteSocialFriendItem:onClickedQQBtn( ... )
	-- body
	self:share(self:getShareContentByType("qq"), 4,"qq")
	self._func(self._obj)
end

function InviteSocialFriendItem:share( msg, style, key )
	DebugLog("msg:"..tostring(msg).." style:"..tostring(style).." key:"..tostring(key))
	if msg and style then 
		local param =  {}
		param.style = style
		param.title = msg.title
		param.url   = msg.url 
		param.logo  = msg.icon
		param.message = msg.desc
		native_to_java("shareOnlyMessage",json.encode(param))
		--------------提交统计数据
		--PHP_CMD_STATISTICS_BATTLE_INVITE
		local statistics = {}
		statistics.mid   = PlayerManager.getInstance():myself().mid
		statistics.fid   = self._fid or 0--
		statistics.type  = key or "weixin"
		SocketManager.getInstance():sendPack(PHP_CMD_STATISTICS_BATTLE_INVITE, statistics);	
		--------------
	end 
end