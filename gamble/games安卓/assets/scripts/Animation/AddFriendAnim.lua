local addFriendPin_map = require("qnPlist/addFriendPin")


AddFriendAnim = class(Node);

-- startPos = {};
-- startPos.x = xxx;
-- startPos.y = xxx;
function AddFriendAnim:ctor( startPos, endPos, parent )
	self.startPos = startPos;
	self.endPos = endPos;

	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end

	if startPos then
		self:setPos( startPos.x, startPos.y );
	else
		self:setPos( 100, 100 );
	end
	self:load();
end

function AddFriendAnim:load()
	self.imgs = addFriendPin_map;
	self.imgMessenger = UICreator.createImg( self.imgs["messenger1.png"], 0, 0);
	self:addChild( self.imgMessenger );
end

function AddFriendAnim:play()
	self:playMessengerAnim();
	self:playMoveAnim();
end

function AddFriendAnim:playMessengerAnim()
	local index = 0;
	self.animFrame = new(AnimInt, kAnimRepeat, 0, 4, 80, 0 );
	self.animFrame:setDebugName( "AddFriendAnim.playMessengerAnim" );
	self.animFrame:setEvent( self, function( self )
		index = index + 1;
		self.imgMessenger:setFile( self.imgs["messenger"..index..".png"] );
		if index >= 4 then
			index = 0;
		end
	end);
end

function AddFriendAnim:playMoveAnim()
	if not self.startPos or not self.endPos then
		return;
	end

	local deltaX = self.endPos.x - self.startPos.x;
	local deltaY = self.endPos.y - self.startPos.y;
	local frame = 100;
	local updateTime = 10;
	local delayTime = frame * updateTime; -- 总共计算10次，每次计算间隔50毫秒
	local speedX = deltaX / frame;
	local speedY = deltaY / frame;

	local x,y = self:getPos();
	local curX = x;
	local curY = y;

	local index = 0;
	self.animMove = new(AnimInt, kAnimRepeat, 1, frame, updateTime, 0 );
	self.animMove:setDebugName("AddFriendAnim:playMoveAnim");
	self.animMove:setEvent( self, function( self )
		if index >= frame then
			self:stop();
		end
		index = index + 1;
		curX = curX + speedX;
		curY = curY + speedY;
		self:setPos( curX, curY );
	end);
end

function AddFriendAnim:stop()
	self:setVisible( false );
	delete( self.animFrame );
	self.animFrame = nil;
	delete( self.animMove );
	self.animMove = nil;
	-- self:removeFromSuper();
	-- delete( self.imgMessenger );
	-- delete( self );
	self:removeAllChildren();
	-- self:removeFromSuper();
	if self.onStopFunc and self.onStopObj then
		self.onStopFunc( self.onStopObj );
	end
	self = nil;
end

function AddFriendAnim:setOnStopListener( obj, func )
	self.onStopObj = obj;
	self.onStopFunc = func;
end