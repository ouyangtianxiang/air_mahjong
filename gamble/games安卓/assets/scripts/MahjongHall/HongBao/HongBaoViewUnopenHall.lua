--local friendAddWindow = require(ViewLuaPath.."friendAddWindow");
require("MahjongHall/HongBao/HongBaoModel")
--require("MahjongHall/HongBao/HongBaoViewManager")
HongBaoViewUnopenHall = class(SCWindow);


HongBaoViewUnopenHall.ctor = function ( self,hongbaoId)

	self.hongbaoId = hongbaoId
	EventDispatcher.getInstance():register(HongBaoModel.DissmissHongbao, self, self.onHongbaoMsgEvent);
	self.lightBg = UICreator.createImg("Room/light.png",0,0);
	self.lightBg:setAlign(kAlignCenter)
	self:addChild(self.lightBg)

	self.lightBg:addPropScaleSolid(0,3.0,3.0,kCenterDrawing)
	self.lightBg:addPropRotate(1,kAnimRepeat,4500,0,0,360,kCenterDrawing)

	----------------
	self.bg = UICreator.createImg("Hall/hongbao/entry_hall.png",0,0);
	self.bg:setAlign(kAlignCenter)
	self:addChild(self.bg)

	self:setWindowNode( self.bg );
	self.cover:setEventTouch(self , function (self)
	end);
	self.bg:setEventTouch(self , function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerUp == finger_action then
			--self.m_bgBtn:removeProp(1);
			GameEffect.getInstance():play( self.mAudioEffectName or "BUTTON_CLICK");
			HongBaoViewManager.getInstance():showHongBaoOpenningView(self.hongbaoId)
			self:hideWnd(true)
		end
	end);

	self.liveTime = HongBaoModel.getInstance():getLimitTime() or 120--
	self.liveTime = self.liveTime * 1000

	self:startTimer()

	self:showWnd();
end

HongBaoViewUnopenHall.startTimer = function ( self )
	if not self:checkAddProp(0) then
		self:removeProp(0)
	end
    local anim = self:addPropTranslate(0,kAnimNormal,self.liveTime,0,0,0,0,0)
    anim:setDebugName("hongbao alive time anim");
    anim:setEvent(self,function ( self )
    	if not self:checkAddProp(0) then
    		self:removeProp(0)
    	end
    	self:hideWnd()
    end)
end

HongBaoViewUnopenHall.updateId = function ( self, id )
	self.hongbaoId = id
	--重新计时
	self:startTimer()
end

HongBaoViewUnopenHall.dtor = function( self )
	DebugLog("NewHongBaoEntryView.dtor")
	if not self:checkAddProp(0) then
		self:removeProp(0)
	end

	if not self:checkAddProp(1) then
		self:removeProp(1)
	end

	if not self.lightBg:checkAddProp(1) then
		self.lightBg:removeProp(1)
	end
	if not self.lightBg:checkAddProp(0) then
		self.lightBg:removeProp(0)
	end
	self:removeAllChildren();
	EventDispatcher.getInstance():unregister(HongBaoModel.DissmissHongbao, self, self.onHongbaoMsgEvent);
end


HongBaoViewUnopenHall.onHongbaoMsgEvent = function ( self,hongbaoid )
	if tonumber(hongbaoid) == tonumber(self.hongbaoId) then
		DebugLog("NewHongBaoEntryView will disappear after 1 second")
		if not self:checkAddProp(1) then
			self:removeProp(1)
		end
		local anim = self:addPropTranslate(1,kAnimNormal,1000,0,0,0,0,0)
		anim:setDebugName("hongbao server kill 1s")
		anim:setEvent(self, function ( self )
			if not self:checkAddProp(1) then
				self:removeProp(1)
			end
			self:hideWnd(true)
		end)
	end
end
