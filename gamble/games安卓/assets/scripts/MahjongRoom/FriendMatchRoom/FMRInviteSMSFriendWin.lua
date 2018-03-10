--local fmrFinalResultView = require(ViewLuaPath.."fmrFinalResultView");
require("MahjongRoom/FriendMatchRoom/FMRInviteSMSFriendItem")
--------好友对战 邀请短信好友
FMRInviteSMSFriendWin = class(SCWindow)

function FMRInviteSMSFriendWin:ctor( )
 	--self:initView(data)
 	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);

 	self._allPhoneNums = {}
 	self:initView()
end

function FMRInviteSMSFriendWin:dtor( )
	self._allPhoneNums = nil
	self.bg = nil
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
end


function FMRInviteSMSFriendWin:initView()
	--self.player = PlayerManager:getInstance():myself();
	self.bg = UICreator.createImg("Commonx/pop_window_mid.png", 0, 0);
	self.bg:setEventTouch(self, function(self)  end);
	self.bg:setAlign(kAlignCenter);
	self:addChild(self.bg);

	self:setWindowNode( self.bg );
	self:setCoverEnable( true );-- 允许点击cover

	local title = UICreator.createText("邀请好友", 0, 30, 160, 40, kAlignCenter, 40, 0xff, 0xff, 0xff);
	title:setAlign(kAlignTop);
	self.bg:addChild(title);

	self.cover:setEventTouch(self , function (self)
		self:hideWnd();
	end);
	self:setCoverTransparent()

	local closeBtn = UICreator.createBtn2( "Commonx/close_btn.png", "Commonx/close_btn_disable.png", -25, -25, self, function ( self )
		self:hideWnd()
	end)
	closeBtn:setAlign(kAlignTopRight)
	self.bg:addChild(closeBtn)

	self.listView = new(ListView,0,30,775,420)
	self.listView:setAlign(kAlignCenter)
	self.listView:setDirection(kVertical);
	self.bg:addChild(self.listView)

	self.noFriendsText = UICreator.createText("暂无可邀请好友", 0, 0,0,0,kAlignCenter, 30, 0x4b, 0x2b, 0x1c)
	self.noFriendsText:setAlign(kAlignCenter)
	self.bg:addChild(self.noFriendsText)
	self.noFriendsText:setVisible(true)

	self:getNativePhoneNumbers()
end

FMRInviteSMSFriendWin.callEvent = function(self, param, json_data)
    DebugLog("FMRInviteSMSFriendWin.callEvent-----:param:"..param or "-1");
    DebugLog("FMRInviteSMSFriendWin.callEvent-----:json_data:"..(json_data and tostring(json_data) or "-1`"));
    if not json_data then
        return;
    end

    if kGetAllPhoneNumbers == param then -- 显示分享窗口
    	self.isGetting = false
        self._allPhoneNums = {}
        if GameConstant.iosDeviceType>0 then
           local status = json_data.status;
           DebugLog("kGetAllPhoneNumbers:"..status);
           if json_data.list then
             json_data = json_data.list;
           else
             json_data = {};
           end
         end
        for k,v in pairs(json_data) do
            --DebugLog(""..k..tostring(v.name)..tostring(v.number));
            local number = tonumber(v.number);
            local item   = {}
            if number then
            	item.number = number
            	item.name   = tostring(v.name)
            	table.insert(self._allPhoneNums, item)
                -------self.m_data.allPhoneNumbers[number].name = tostring(v.name);
            end
        end

        if #self._allPhoneNums > 0 then
			local adapter = new(CacheAdapter, FMRInviteSMSFriendItem, self._allPhoneNums)
			self.listView:setAdapter(adapter)
			self.noFriendsText:setVisible(false)
		else
			self.listView:setAdapter(nil)
			self.noFriendsText:setVisible(true)
        end
	end
end

--获取通讯录
FMRInviteSMSFriendWin.getNativePhoneNumbers = function (self)
	if not isPlatform_Win32() then

		if not self.isGetting then
			self.isGetting = true
	    	native_to_java(kGetAllPhoneNumbers , "");
	    end
	else
		self._allPhoneNums = {
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
			{["name"] = "xxxx",["number"] = "18675643221"},
		}
        if #self._allPhoneNums > 0 then
			local adapter = new(CacheAdapter, FMRInviteSMSFriendItem, self._allPhoneNums)
			self.listView:setAdapter(adapter)
			self.noFriendsText:setVisible(false)
		else
			self.listView:setAdapter(nil)
			self.noFriendsText:setVisible(true)
        end
	end
end
