
local resultAnimPin_map = require("qnPlist/resultAnimPin")


GameResultScoreAnim = class(Node);

GameResultScoreAnim.ctor = function ( self , num ,bAnim)

	self.Number = math.floor(num or 0);
	self.startN = 0;
	self.steps  = 30;
	self.setp   = 0;
	self.stop 	= true;
	self.bAnim	= bAnim;
	self:setVisible(true);
	self.numNode = new(Node);
	self:addChild(self.numNode);
end


GameResultScoreAnim.dtor = function ( self )
	if self.timerAnim then
		delete(self.timerAnim);
		self.timerAnim = nil;
	end
	self:removeAllChildren();
end


GameResultScoreAnim.show = function (self, scoreX,scoreY)
	if self.stop then
		self.stop = false;

		if self.bAnim then
			self:starTimer();
		else
			self:loadNumber(math.floor(self.Number));
		end
	end
end

GameResultScoreAnim.starTimer = function (self)
	-- body
	-- animType, startValue, endValue, duration, delay
	self.timerAnim = new(AnimInt, kAnimRepeat, 0, 1, 60, -1);
	self.timerAnim:setDebugName(" GameResultScoreAnim.starTimer ");
	self.timerAnim:setEvent(self, self.ontimer);
end

GameResultScoreAnim.ontimer = function ( self )
	self.setp 	= self.setp + 1;
	self.startN = interpolator(0,self.Number,self.steps,self.setp);

	if math.abs(math.floor(self.startN)) >= math.abs(self.Number) then
		self.startN = self.Number;
	end

	if  not self.stop then
		self.numNode:removeAllChildren();
		self:loadNumber(math.floor(self.startN));
	end

	self.stop = (self.startN == self.Number);

	if self.stop then
		delete(self.timerAnim);
		self.timerAnim = nil;
	end
end

GameResultScoreAnim.loadNumber = function( self , number )

	local signImg ;
	local plus;
	local x , y = 0 , 0;

	signImg = UICreator.createImg( resultAnimPin_map["matchScore10.png"], x, y );
	signImg:setPos(x,y);

	if signImg then
		self.numNode:addChild(signImg);
		x = x + signImg.m_res.m_width;
	end

	local numberStr = "" .. math.abs(number);
	local targetStr = "" .. math.abs(self.Number);
	local numLen 	= string.len(numberStr);
	local targetLen = string.len(targetStr);
	local offsetX   = (targetLen - numLen) * signImg:getSize();


	for i=1,numLen do

		local n = string.sub(numberStr, i, i);
		local path = "matchScore" .. n .. ".png";
		local img = UICreator.createImg( resultAnimPin_map[path], offsetX + x,y );
		if img then
			self.numNode:addChild(img);
			x = x + img:getSize();
		end
	end

	local wordImg = UICreator.createImg( resultAnimPin_map["matchScore11.png"], offsetX + x, y );
	self.numNode:addChild(wordImg);


	self.numNode:setSize(offsetX + x + wordImg:getSize(),y);
	self:setSize(offsetX + x + wordImg:getSize(),y);
end

