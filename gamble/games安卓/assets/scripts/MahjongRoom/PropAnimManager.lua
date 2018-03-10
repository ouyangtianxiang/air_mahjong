
PropAnimManager = class();

PropAnimManager.ctor = function( self, animList, managerIndex )
	self.animList = animList;
	self.managerIndex = managerIndex;
end

PropAnimManager.play = function( self )
	if not self.animList then
		log( "PropAnimManager.play 动画列表为空无法播放" );
		return;
	end

	local index = 0;
	local num = #self.animList;
	self.timer = new(AnimInt, kAnimRepeat, 0, 10, 100, 0 );
	self.timer:setDebugName( "PropAnimManager.play.timer" );
	self.timer:setEvent( self, function( self )
		if index >= num then
			self:stop();
			return;
		end
		index = index + 1;
		self.animList[index]:play();
	end);
end

PropAnimManager.stop = function( self )
	delete( self.timer );
	self.timer = nil;
	self.animList = {};
end

PropAnimManager.setOnPlayFinishListener = function( self, obj, func )
	self.finishObj = obj;
	self.finishFunc = func;
end
