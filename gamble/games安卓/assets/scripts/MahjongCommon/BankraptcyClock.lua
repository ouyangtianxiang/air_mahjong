BankraptcyClock = {};

BankraptcyClock.ctor = function ( self , timerNode)
	-- body
	self.timeImage 	= {};
	self.time		= 0;

	self.sysTime = 0;

	self.timerNode = timerNode;


	self:update();

end

BankraptcyClock.dtor = function ( self )
	-- body
end

BankraptcyClock.start = function ( self, time ,arg , timeOutListener)
	-- body
	self.time = time;
	self.arg  = arg;
	self.timeOutListener = timeOutListener;

	self.sysTime = os.time();

	self:update();
	local timer = self.timerNode:addPropTranslate(1, kAnimRepeat, 1000, 0, 0, 0, 0, 0);
	timer:setDebugName(" BankraptcyClock||timer ");
	timer:setEvent(self, self.run);
end

BankraptcyClock.run = function ( self )
	local deltaSysTime = os.time() - self.sysTime ;
	--校正时间
	if deltaSysTime >= 3 then
		self.time 	 = self.time - deltaSysTime;
	end

	self.sysTime = self.sysTime + deltaSysTime;

	if self.time <= 0 then

		self.time = 0;
		self:update();
		--remove timer...
		self.timerNode:removeProp(1);
		--call back
		if self.timeOutListener then
			self.timeOutListener(self.arg);
		end
		return ;
	end

	self:update();
	self.time = self.time - 1;
end

BankraptcyClock.update = function ( self )
	local mm = math.floor(self.time / 600);
	local m  = math.floor((self.time - mm * 600) / 60);
	local ss = math.floor((self.time - mm * 600 - m * 60 ) / 10);
	local s  = math.floor((self.time - mm * 600 - m * 60 - ss * 10));

	publ_getItemFromTree(self.timerNode,{"img_mm_bg", "img_num"}):setFile("bankraptcy/br_" .. mm ..".png");
	publ_getItemFromTree(self.timerNode,{"img_m_bg", "img_num"}):setFile("bankraptcy/br_" .. m ..".png");
	publ_getItemFromTree(self.timerNode,{"img_ss_bg", "img_num"}):setFile("bankraptcy/br_" .. ss ..".png");
	publ_getItemFromTree(self.timerNode,{"img_s_bg", "img_num"}):setFile("bankraptcy/br_" .. s ..".png");

end

