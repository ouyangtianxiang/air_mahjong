--require("MahjongHall/HongBao/HongBaoModel")
require("MahjongHall/HongBao/HongBaoSendView")



HongBaoViewManager = class()
HongBaoViewManager.m_Instance = nil 

function HongBaoViewManager.ctor( self )
	-- body
	self.sendView = nil
	self.openningView = nil
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
end

function HongBaoViewManager.dtor( self )
	-- body
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
end

function HongBaoViewManager.getInstance( self )
	if not HongBaoViewManager.m_Instance then
		HongBaoViewManager.m_Instance = new(HongBaoViewManager)
	end
	return HongBaoViewManager.m_Instance
end

--
function HongBaoViewManager.showHongBaoSendView( self )
	-- body
	if self.sendView then 
		self.sendView:hideWnd(true)--without anim
	end

	self.sendView = new(HongBaoSendView)
	self.sendView:addToRoot()	
	self.sendView:setOnWindowHideListener(self,function ( self )
		self.sendView = nil
	end)

end

function HongBaoViewManager.showHongBaoOpenningView( self, hongbaoId)
	if self.openningView then 
		self.openningView:hideWnd(true)--without anim
	end

	if self.sendView then 
		self.sendView:hideWnd(true)
	end 

	if self.shareWindow then 
		self.shareWindow:exitAction()
	end


	local HongBaoViewOpenning = require("MahjongHall/HongBao/HongBaoViewOpenning")

	self.openningView = new(HongBaoViewOpenning,hongbaoId)
	self.openningView:addToRoot()	
	self.openningView:setOnWindowHideListener(self,function ( self )
		self.openningView = nil
	end)
end

function HongBaoViewManager.showShareWindowView( self, obj ,func )

	local data = {};
	data.title = PlatformFactory.curPlatform:getApplicationShareName();
	data.content = "天天拆红包，天天赢大奖!"
	data.username = PlayerManager.getInstance():myself().nickName or "川麻小王子";
	data.url = GameConstant.shareMessage.url or ""
	
    local shareData = {d = nil, share = data , t = GameConstant.shareConfig.hongbao, b = false};
    global_screen_shot(shareData); 
end


HongBaoViewManager.callEvent = function ( self, param, data )
	-------房间内的RoomScene处理
	if RoomScene_instance then 
		if kScreenShot == param then 
			
		end 
		return
	end

	if kScreenShot == param then -- 显示分享窗口
	end
end

