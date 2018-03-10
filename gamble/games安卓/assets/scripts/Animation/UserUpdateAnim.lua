local UpdateScorePin_map = require("qnPlist/UpdateScorePin")


UserUpdateAnim = class(Node);

UserUpdateAnim.ctor = function( self, parent, money )
	-- self.m_pos = pos;
	self.m_money = money;
	self:load( parent );
end

UserUpdateAnim.load = function( self, parent )
	local starPath = "update/userUpdate/star.png";
	local updateTipsPath = "update/userUpdate/update_tips.png";
	local bgLightPath = "update/userUpdate/bg_light.png";
	local bgPath = "Commonx/zhezhao.png";
	local tempPos = {};
	-- tempPos.x = self.m_pos[1];
	-- tempPos.y = self.m_pos[2];
	local scale = System.getLayoutScale();
	local sw = SCREEN_WIDTH / scale;
	local sh = SCREEN_HEIGHT / scale;
	tempPos.x = sw/2;
	tempPos.y = sh/2;

	self.m_stars = {};
	self.m_starNum = 18;
	self.m_updateTimes = 160/2;
	self.m_delayTime = 100;

	self.m_bg = UICreator.createImg( bgPath );
	self.m_bg:setSize( sw, sh );
	self.m_bg:setEventTouch( self, function( self )
	end);
	self:addChild( self.m_bg );

	self.bgLight = new( ShineBGState, self, bgLightPath, tempPos, 1, self.m_updateTimes + self.m_delayTime );
	for i=1,self.m_starNum do
		local rand = math.random(90, 100);
		local randLength = math.random(200, 300);
		self.m_stars[i] = new( StarState, starPath, self, tempPos, randLength, 20*i*rand/100, 10*((-1)^i), self.m_updateTimes);
	end
	self.updateTips = new( UpdateImgState, self, updateTipsPath, self.m_money, tempPos, self.m_updateTimes, self.m_delayTime );
	
	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end
end

UserUpdateAnim.play = function( self, func )
	local counter = 0;
	self.anim = new(AnimInt, kAnimRepeat, 0, 10, 10, 0 );
	self.anim:setDebugName("UserUpdateAnim || anim");
	self.anim:setEvent( self, function( self )

		-- fresh all component
		if self.m_stars then
			for i=1,self.m_starNum do
				if self.m_stars[i] then
					if self.m_stars[i].isFinished then
						delete( self.m_stars[i] );
						self.m_stars[i] = nil;
						counter = counter + 1;
					else
						self.m_stars[i]:update();
					end
				end
			end
		end

		if self.updateTips and self.updateTips.m_isFinished == false then
			self.updateTips:update();
		end

		if self.bgLight and self.bgLight.m_isFinished == false then
			self.bgLight:update();
		end


		if self.updateTips and self.updateTips.m_isFinished then
			delete( self.anim );
			self.anim = nil;
			self:removeAllChildren();
			if func then
				func();
			end
		end

		--加此处理是为了以防self.updateTips创建失败的情况 动画永远也不会结束
		if not self.updateTips then 
			delete( self.anim );
			self.anim = nil;
			self:removeAllChildren();
			if func then
				func();
			end
		end 
		--add end 

	end);
end

UserUpdateAnim.dtor = function( self )
end

UpdateImgState = class(Node);

UpdateImgState.ctor = function( self, parent, imgPath, money, pos, updateTimes, delayTimes )
	self.m_pos = pos;
	self.m_imgPath = imgPath;
	self.m_updateTimes = updateTimes;
	self.m_delayTime = delayTimes;
	self.m_counter = 0;
	self.m_isFinished = false;
	self.m_id = 1;
	self.m_scaleCount = 0;
	self.m_lastScale = 0;
	self.m_scoreNode = nil;
	self.m_money = money;

	parent:addChild( self );

	self:load();
end

UpdateImgState.load = function( self )
	self.m_bg = UICreator.createImg( self.m_imgPath );
	self.m_width, self.m_height = self.m_bg:getSize();
	self.m_bg:setPos( self.m_pos.x - self.m_width/2, self.m_pos.y - self.m_height/2 );
	self.m_bg:addPropScaleSolid( self.m_id, 1.1, 1.1, kCenterDrawing );
	self.m_lastScale = 1.1;
	self.m_bg:setTransparency( 0.1 );
	self:addChild( self.m_bg );
end

UpdateImgState.update = function( self )
	self.m_counter = self.m_counter + 1;
	self.m_id = self.m_id + 1;
	local scale = 1 + ( self.m_counter / self.m_updateTimes * 0.04 );
	-- self.m_bg:setSize( self.m_width*scale, self.m_height*scale );
	if self.m_counter <= 10 then
		if self.m_lastScale >= 0.9 then
			self.m_lastScale = self.m_lastScale*0.97;
			self.m_bg:addPropScaleSolid( self.m_id, self.m_lastScale, self.m_lastScale, kCenterDrawing );
		end
		self.m_bg:setTransparency( 0.1+(self.m_counter/10)*0.9 );
	elseif self.m_counter > 10 then
		if self.m_lastScale <= 1.11 then
			self.m_lastScale = self.m_lastScale*1.01;
			self.m_bg:addPropScaleSolid( self.m_id, self.m_lastScale, self.m_lastScale, kCenterDrawing );
		else
			if not self.m_scoreNode then
				self.m_scoreNode = new(ScoreState, self, self.m_money, self.m_pos);
			end
		end
	end

	if self.m_counter >= self.m_updateTimes + self.m_delayTime then
		self.m_isFinished = true;
		self.m_counter = 0;
		self.m_id = 0;
	end
end

UpdateImgState.calScale = function( self, from, to, process )
	if self.m_lastScale == 0 then
		self.m_lastScale = from;
		return 1;
	else
		self.m_lastScale = (1 + process * self.m_lastScale) * self.m_lastScale;
		return 1 + process * self.m_lastScale;
	end
end

UpdateImgState.dtor = function( self )
end


ScoreState = class(Node);

ScoreState.ctor = function( self, parent, score, pos )
	self.m_score = score;
	self.m_pos = pos;
	self.m_moneyNode = new(Node);

	self.scroeNum = nil;
	-- self:getScoreNum( score );
	self:parseMoney( score, pos );

	parent:addChild( self );
end

ScoreState.parseMoney = function ( self, money, pos )
	local moneyImgWidth = 0;
	local moneyImgHeight = 0;

	local mt = money.."";

	local len = string.len(mt);
	local x,y = 0,0;
	for i = 1,len do
		local c = string.sub(mt, i, i);
		local url = nil;
		url =  c.. ".png";
		local img = UICreator.createImg( UpdateScorePin_map[url], x, y );
		x = x + img.m_res.m_width;
		moneyImgWidth = moneyImgWidth + img.m_res.m_width;
		if img.m_res.m_height > moneyImgHeight then
			moneyImgHeight = img.m_res.m_height;
		end
		self.m_moneyNode:addChild(img);
	end

	self.height = moneyImgHeight;
	self.m_moneyNode:setSize(x,y);

	local imgAward = UICreator.createImg( "update/userUpdate/award.png" );
	local w,h = imgAward:getSize();
	self:addChild( imgAward );

	self.m_moneyNode:setPos( w );
	self:addChild( self.m_moneyNode );

	local imgCoin = UICreator.createImg( "update/userUpdate/coin.png" );
	local w1,h1 = imgCoin:getSize();
	imgCoin:setPos( x + w , 0 );
	self:addChild( imgCoin );

	local totalWith = w + x + w1;
	self:setPos( pos.x - totalWith/2 , pos.y + moneyImgHeight + 30 );
end

ScoreState.dtor = function( self )
end


ShineBGState = class(Node);

ShineBGState.ctor = function( self, parent, imgPath, pos, rotateAngle, updateTimes )
	self.m_pos = pos;
	self.m_imgPath = imgPath;
	self.m_updateTimes = updateTimes;
	self.m_rotateAngle = rotateAngle;
	self.m_startAngle = 0;
	self.m_counter = 0;
	self.m_isFinished = false;

	parent:addChild( self );
	self:load();
end

ShineBGState.load = function( self )
	self.m_shine = UICreator.createImg( self.m_imgPath );
	self.m_width, self.m_height = self.m_shine:getSize();
	self.m_shine:setPos( self.m_pos.x-self.m_width/2, self.m_pos.y-self.m_height/2 );
	self:addChild( self.m_shine );
end

ShineBGState.update = function( self )
	self.m_counter = self.m_counter + 1;
	self.m_startAngle = self.m_startAngle + self.m_rotateAngle;
	self.m_shine:setRotate( self.m_startAngle );

	if self.m_counter >= self.m_updateTimes then
		self.m_isFinished = true;
	end
end

ShineBGState.dtor = function( self )
end


StarState = class();

StarState.ctor = function( self, imgSrc, parent, startPos, length, angle, rotateAngle, updateTimes )
	self.m_imgSrc = imgSrc;
	self.m_startPos = startPos;
	self.m_length = length;
	self.m_rotateAngle = rotateAngle;
	self.m_angle = angle/180*3.1415926;

	self.isFinished = false;

	self.m_counter = 0;
	self.m_updateTimes = updateTimes;
	self:calEndPos();
	self.m_startAngle = 0;

	self.m_star = UICreator.createImg(self.m_imgSrc);
	self.m_star:setPos( self.m_startPos.x, self.m_startPos.y );
	parent:addChild( self.m_star );
	local width,height = self.m_star:getSize();
	local rand = math.random(30, 100);
	self.m_star:setSize( width*rand/100, height*rand/100 );
end

StarState.calEndPos = function( self )
	self.m_centerPos = self:calCurPos( 1 );
end

StarState.calCurPos = function( self, process )
	local width = self.m_length * math.sin( self.m_angle ) * process; -- 移动过程中前20%透明
	local height = self.m_length * math.cos( self.m_angle ) * process;
	local x = self.m_startPos.x + width;
	local y = self.m_startPos.y + height;
	local pos = {};
	pos.x = x;
	pos.y = y;

	return pos;
end

StarState.update = function( self )
	self.m_counter = self.m_counter + 1;
	self.m_startAngle = self.m_startAngle + self.m_rotateAngle;
	local pos = self:calCurPos( self.m_counter/self.m_updateTimes );
	self.m_star:setPos( pos.x, pos.y );
	self.m_star:setRotate( self.m_startAngle );

	local startHide = 0.8;
	if self.m_counter/self.m_updateTimes >= startHide then
		self.m_star:setTransparency( 1-(self.m_counter/self.m_updateTimes - startHide )/(1-startHide) );
	end

	if self.m_counter >= self.m_updateTimes then
		self.isFinished = true;
	end
end

StarState.dtor = function( self )
	delete( self.m_star );
end
