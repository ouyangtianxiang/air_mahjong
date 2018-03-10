
local resultAnimPin_map = require("qnPlist/resultAnimPin")


GameResultNumberAnim = class(Node);

GameResultNumberAnim.ctor = function ( self , num ,bAnim)
	self.Number = math.floor(num);
	self.startN = 0;
	self.steps  = 30;
	self.setp   = 0;
	self.stop 	= true;
	self.bAnim	= bAnim;
	self:setVisible(true);
	self.numNode = new(Node);
	self:addChild(self.numNode);
end


GameResultNumberAnim.dtor = function ( self )
	if self.timerAnim then
		delete(self.timerAnim);
		self.timerAnim = nil;
	end
	self:removeAllChildren();
end


GameResultNumberAnim.show = function (self)
	if self.stop then
		self.stop = false;

		if self.bAnim then
			
			self:starTimer();
		else
			self:loadNumber(math.floor(self.Number));
		end
	end
end

GameResultNumberAnim.starTimer = function (self)
	-- animType, startValue, endValue, duration, delay
	self.timerAnim = new(AnimInt, kAnimRepeat, 0, 1, 60, -1);
	self.timerAnim:setDebugName(" GameResultNumberAnim.starTimer ");
	self.timerAnim:setEvent(self, self.ontimer);
end

GameResultNumberAnim.ontimer = function ( self )
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

GameResultNumberAnim.loadNumber = function( self , number )

	local signImg ;
	local plus;
	local x , y = 0 , 0;

	if number >= 0 then
		signImg = UICreator.createImg( resultAnimPin_map["money11.png"], x, y );
		plus = true;
	else
		signImg = UICreator.createImg( resultAnimPin_map["money10.png"], x, y );
		plus = false;
	end
	signImg:setPos(x,y);

	if signImg then
		self.numNode:addChild(signImg);
		x = x + signImg.m_res.m_width;
		_, self.numberH = signImg:getSize();
	end

	local numberStr = "" .. math.abs(number);
	local targetStr = "" .. math.abs(self.Number);
	local numLen 	= string.len(numberStr);
	local targetLen = string.len(targetStr);
	local offsetX   = (targetLen - numLen) * signImg:getSize();


	for i=1,numLen do

		local n = string.sub(numberStr, i, i);
		local path;
		if plus then
			path = "money" .. n .. ".png";
		else
			path = "money" .. n .. "_G.png";
		end
		local img = UICreator.createImg( resultAnimPin_map[path], offsetX + x,y );
		if img then
			self.numNode:addChild(img);
			x = x + img:getSize();
		end
	end
	self.numNode:setSize(offsetX + x,y);
	self:setSize(offsetX + x,y);
end

