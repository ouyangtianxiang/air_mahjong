-- 托管动画
TuoGuanAni = class(Node);
TuoGuanAni.propSqu = 1;
TuoGuanAni.ctor = function ( self )
	self.isShow = false;
	self.rect = { 97, 222, 276 - 97, 279 - 222 }; -- 触摸区域
	self.img = UICreator.createImg( "Room/tuoguan_cancel.png", 0, 0 );
	self:setSize(310, 316);
	self:setEventDrag(self, TuoGuanAni.onEventDrag);
	self:setEventTouch(self, function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
		if finger_action == kFingerUp and not (x > 72 and x < 733 and y > 12 and y < 452 ) then
			-- 屏蔽点击事件
		end
	end);
	self:addChild(self.img);

	self:setPos(System.getScreenWidth() / System.getLayoutScale(), RoomCoor.tuoGuanAniPos[2]);

end

TuoGuanAni.show = function ( self )
	self.isShow = true;
	self:move(true);
end

TuoGuanAni.disapper = function ( self )
	self.isShow = false;
	self:move(false);
end

TuoGuanAni.setDisapperCallback = function ( self, obj, fun )
	self.obj = obj;
	self.callback = fun;
end

TuoGuanAni.disapperRequire = function ( self )
	if self.callback then
		self.callback(self.obj);
	end
end

TuoGuanAni.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if finger_action == kFingerUp then -- 点击即取消托管
		self:disapperRequire();
	end
end

TuoGuanAni.move = function ( self, bleft )

	if self.anim then
		self:removeProp(TuoGuanAni.propSqu);
		self.anim = nil;
	end

	local screeW = System.getScreenWidth() / System.getLayoutScale();

	local x, y = self:getPos();

	local offX;

	if bleft then 
		offX = RoomCoor.tuoGuanAniPos[1] - x;
	else
		offX = screeW - x;
	end

	self.anim = self:addPropTranslate(TuoGuanAni.propSqu, kAnimNormal, 350, 0, 0, offX, 0, 0);

	self.anim:setEvent(self, function ( self )
		self.anim = nil;
		self:removeProp(TuoGuanAni.propSqu);
		self:setPos(x + offX, RoomCoor.tuoGuanAniPos[2]);
	end);
end

TuoGuanAni.dtor = function ( self )
	self:removeAllChildren();
	delete(self.anim);
	self.anim = nil;
	self.img = nil;
end

