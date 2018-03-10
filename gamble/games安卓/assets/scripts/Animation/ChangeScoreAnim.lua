--/**
-- 分数改变的数字飘起动画
--**/
local resultAnimPin_map = require("qnPlist/resultAnimPin")

ChangeScoreAnim = class(Node);

ChangeScoreAnim.ctor = function ( self, money, x, y, img ,delay, bAni)
	-- self:setPos(x, y);
	self.money = money;
	self.img = img;
	self.moneyNode = new(Node);
	self:addChild(self.moneyNode);
	self.moveTimeInMillisec = 1400;
	self.moveDistan = 20;
	if delay ~= nil then
		self.delay = delay;
	else
		self.delay = true;
	end
	self.height= 0;
	if bAni ~= nil then
		self.bAni = bAni;
	else
		self.bAni = true;
	end
	
end

ChangeScoreAnim.show = function ( self )
	self:setVisible(true);
	if self.img then
		self.moneyNode:addChild(self.img);
	else
		self:parseMoney(self.money);
	end
	self:addProp();
end

ChangeScoreAnim.parseMoney = function ( self, money )
	local moneyImgWidth = 0;
	local moneyImgHeight = 0;

	local numfix = "_G";

	local mt = money.."";
	if money >= 0 then
		mt = "+"..mt;
		numfix = "";
	end

	local len = string.len(mt);
	local x,y = 0,0;
	for i = 1,len do
		local c = string.sub(mt, i, i);
		local url = nil;
		-- if c == "-" then
		-- 	url = "money10.png";
		if c == "+" then
			url = "matchScore10.png";
		else
			url =  "matchScore" ..c..numfix.. ".png";
		end
		local img = UICreator.createImg( resultAnimPin_map[url], x, y );
		x = x + img.m_res.m_width;
		moneyImgWidth = moneyImgWidth + img.m_res.m_width;
		if img.m_res.m_height > moneyImgHeight then
			moneyImgHeight = img.m_res.m_height;
		end
		self.moneyNode:addChild(img);
	end
	local wordImg = UICreator.createImg( resultAnimPin_map["matchScore11.png"], x, y );
	self.moneyNode:addChild(wordImg);

	self.height = moneyImgHeight;

	self.moneyNode:setSize(x+ wordImg:getSize(),y);
	self:setSize(x+ wordImg:getSize(),y);
end

ChangeScoreAnim.addProp = function ( self )

	if not self.bAni then
		return;
	end
	self.moneyNode:addPropTranslate(1, kAnimNormal, self.moveTimeInMillisec, 0, 0, 0, self.moveDistan, -self.height / 2);
	self.moneyNode:addPropTransparency( 2, kAnimNormal, self.moveTimeInMillisec, 0, 0.5, 1.0);

	if self.delay then
		local delayAnim = self.moneyNode:addPropScale(3,kAnimNormal,self.delay and self.moveTimeInMillisec * 2 or self.moveTimeInMillisec,0,1.0,1.0,1.0,1.0,kNotCenter);
		delayAnim:setDebugName(" ChangeScoreAnim.addProp ");
		delayAnim:setEvent(self, function ( self )
			if self.m_parent then
				self.m_parent:removeChild(self, true);
			end
		end);
	end
end

ChangeScoreAnim.dtor = function ( self )
	self:removeAllChildren();
end

