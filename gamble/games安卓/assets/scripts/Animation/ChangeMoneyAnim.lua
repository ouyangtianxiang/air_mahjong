--/**
-- 钱改变的数字飘起动画 包括输钱和赢钱
--**/
local resultAnimPin_map = require("qnPlist/resultAnimPin")

ChangeMoneyAnim = class(Node);


ChangeMoneyAnim.ctor = function ( self, money, x, y, img ,delay, bAni)
	self:setPos(x, y);
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

ChangeMoneyAnim.show = function ( self )
	self:setVisible(true);
	if self.img then
		self.moneyNode:addChild(self.img);
	else
		self:parseMoney(self.money);
	end
	self:addProp();
end

ChangeMoneyAnim.parseMoney = function ( self, money )
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
		if c == "-" then
			url = "money10.png";
		elseif c == "+" then
			url = "money11.png";
		else
			url =  "money" ..c..numfix.. ".png";
		end
		local img = UICreator.createImg( resultAnimPin_map[url], x, y );
		x = x + img.m_res.m_width;
		moneyImgWidth = moneyImgWidth + img.m_res.m_width;
		if img.m_res.m_height > moneyImgHeight then
			moneyImgHeight = img.m_res.m_height;
		end
		self.moneyNode:addChild(img);
	end

	self.height = moneyImgHeight;
	self.moneyNode:setSize(x,y);
	self:setSize(x,y);
end

ChangeMoneyAnim.addProp = function ( self )

	if not self.bAni then
		return;
	end
	self.moneyNode:addPropTranslate(1, kAnimNormal, self.moveTimeInMillisec, 0, 0, 0, self.moveDistan, -self.height / 2);
	self.moneyNode:addPropTransparency( 2, kAnimNormal, self.moveTimeInMillisec, 0, 0.5, 1.0);

	if self.delay then
		local delayAnim = self.moneyNode:addPropScale(3,kAnimNormal,self.delay and self.moveTimeInMillisec * 2 or self.moveTimeInMillisec,0,1.0,1.0,1.0,1.0,kNotCenter);
		delayAnim:setDebugName(" ChangeMoneyAnim.addProp ");
		delayAnim:setEvent(self, function ( self )
			if self.m_parent then
				self.m_parent:removeChild(self, true);
			end
		end);
	end
end

ChangeMoneyAnim.dtor = function ( self )
	self:removeAllChildren();
end

