Banner = class(Node);
Banner.instance = nil;
Banner.getInstance = function ()
	if not Banner.instance then
		Banner.instance = new(Banner);
	end
	return Banner.instance;
end

Banner.releaseInstance = function ()
	if Banner.instance then
		delete(Banner.instance);
		Banner.instance = nil;
	end
end

Banner.light = 0;

Banner.ctor = function(self , isLong)
	self:setLevel(10000);
	self.showTxtList = {};
	self.isFadeout = false;
	self.showing = false;
  	
  	self.r_width = 909--1017;
  	self.r_height = 86--105;
  	self.r_x = (System.getScreenWidth() - self.r_width * System.getLayoutScale())/2;
  	self.r_y = -self.r_height * System.getLayoutScale();-- -105 * System.getLayoutScale();
 	self.ms = 2000;
 	self.light = 0;
 	self.m_tips_bg = nil;
 	self.m_msg = nil;
	if isLong == true then
		self.ms = 2500;
	end
	self:create();
end

Banner.create = function(self)
	self.m_tips_bg = new(Image,"banner_bg.png");
	self.m_tips_bg:setPos(0, 0);
	self:addChild(self.m_tips_bg);
	self.m_msg = UICreator.createText("", 0, -11, self.r_width - 180, self.r_height, kAlignCenter, 30, 0x94, 0x32, 0x00);
	self.m_msg:setClip(90 , 0 , self.r_width - 180 , self.r_height);
	self:addChild(self.m_msg);
	self:setVisible(true);
	self:addToRoot();
end

Banner.showMsg = function (self, msg)
	msg = publ_trim(msg);
	if self.showTxtList and #self.showTxtList > 0 then
		if self.showTxtList[#self.showTxtList] == msg then
			return;
		end
	end
	-- local array = stringFormatWithString( msg , 28, false)
	if msg and msg ~= "" and msg ~= "nil" then
		table.insert(self.showTxtList, msg);
	end
	if self.showing then
		if self.isFadeout then -- 当前字符串正在消失
			self:disappear(); -- 移除属性
			self:showText(self.showTxtList[1]);
			table.remove(self.showTxtList, 1);
		end
	else
		self:showText(self.showTxtList[1]);
		table.remove(self.showTxtList, 1);
	end
end

Banner.dtor = function(self)
	self.showTxtList = {};
	self.isFadeout = false;
	self.showing = false;
	self:removeAllChildren();
end

------------------------------------private function--------------------------------------
Banner.fadeOut = function(self)
	-- 当前缓冲池中有字符串要显示，切换显示字符串，并且重新设置时间
	if #self.showTxtList > 0 then
		local txt = self.showTxtList[1];
		table.remove(self.showTxtList, 1);
		self:showText(txt);
	else 
		-- 当前缓冲池中已经没有字符串要显示，隐藏
		self.isFadeout = true;
		--设置Banner消失效果
		self.hasProp = true;
		local animTimer = self:addPropTranslate(1,kAnimNormal,600,0,0,0,0,-self.r_height);
	    animTimer:setEvent(self , self.disappear);
	end
end

Banner.showText = function ( self, text )
	-- DebugLog(tostring(text.."%"));
	self:setVisible(true);
	self.showing = true;
	self:setPos(self.r_x/ System.getLayoutScale(), self.r_y/System.getLayoutScale());
	self.m_msg:setText(tostring(text) , 0 , 0 , 0x94, 0x32, 0x00);
	local dist = self.m_msg.m_width - self.r_width + 180;
	local msgMoveTime = math.abs(dist / 20) * 100;
	if dist > 0 then
		self.m_msg:setPos(90 , 10);--23);
	else
		self.m_msg:setPos(90 + math.abs(dist)/2, 10);--23);
	end
	local timer = self:addPropTranslate(1,kAnimNormal,600,0,0,0,0,self.r_height);
	timer:setEvent(self , function ( self )
		self:removeProp(1);
		self:setPos(self.r_x/ System.getLayoutScale(), 0);
		if dist > 0 then
			-- dist = dist + 5;
			local timer_1 = self:addPropTranslate(2,kAnimNormal,self.ms or 500,0,0,0,0,0);
			timer_1:setEvent(self , function ( self )
				local timer_2 = self.m_msg:addPropTranslate(1, kAnimNormal, msgMoveTime, 0, 0, -dist, 0, 0);
				self:removeProp(2);
				timer_2:setEvent(self,function ( self )
					self.m_msg:removeProp(1);
					local msgX = self.m_msg.m_x /System.getLayoutScale() - dist;
					local msgY = self.m_msg.m_y /System.getLayoutScale();
					self.m_msg:setPos(msgX , msgY);
					local timer_3 = self:addPropTranslate(2,kAnimNormal,self.ms or 1000,0,0,0,0,0);
					timer_3:setEvent(self , function ( self )
						self:removeProp(2);
						self:fadeOut();
					end)
				end)
			end)
		else
			local timer_1 = self:addPropTranslate(2,kAnimNormal,self.ms or 1000,0,0,0,0,0);
			timer_1:setEvent(self , function ( self )
				self:removeProp(2);
				self:fadeOut();
			end)
		end
	end);
end

Banner.disappear = function(self)
	self:removeProp(1);
	self:setPos(self.r_x/ System.getLayoutScale() , self.r_y / System.getLayoutScale() );
	self.isFadeout = false;
	self.showing = false;
	self.hasProp = false;
	self:setVisible(false);
end

