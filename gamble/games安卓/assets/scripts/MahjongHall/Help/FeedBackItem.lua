require("MahjongHall/Rank/RankUserInfo");
local helpEvaluate = require(ViewLuaPath.."helpEvaluate");

FeedBackItem = class(Node)

FeedBackItem.ctor = function(self, width, height, service, obj, updateFunc, obj, solveFunc, obj, voteFunc)
	
	self.service     = service;
	self.obj         = obj;
	self.updateFunc  = updateFunc;

	self.solveObj    = obj;
	self.solveFunc   = solveFunc;

	self.voteObj     = obj;
	self.voteFunc    = voteFunc;

	self.voteH       = 0;
	self.animHeight  = 0;

	local x, y, w, h = 0, 0, 0, 0;
	h = h + 25 --起始間隔20

	if service.question and string.len(service.question) > 0 then
		local node = self:createDist(width,"您的反馈：",255, 255,255 ,service.question,255, 255, 255);
		self:addChild(node);
		node:setPos(x, y);
		local _w, _h = node:getSize();
		h = h + _h;
		y = y + _h;
	end
--    if true then
--    self.service.id = 1234;
--    service.answer = "hello"
--    service.votescore = 0;
	if service.answer and string.len(service.answer) > 0 then
		local node = self:createDist(width,"客服回复：", 0xff , 0xc5, 0x87, service.answer, 0xff, 0xc5, 0x87);
		self:addChild(node);
		node:setPos(x, y);
		local _w, _h = node:getSize();
		h = h + _h;
		y = y + _h;

		--创建打分界面

		--尚未解决--新需求去掉尚未解决的操作只保留打分
		--沿未打分
		local notReaded = service.readed and tonumber(service.readed) == 0;
		local notVote   = service.votescore and tonumber(service.votescore) == 0;
		--if notReaded or 
        if notVote then

			y = y + 10;
			h = h + 10;
			local evaluateView = SceneLoader.load(helpEvaluate);
			local evaluateW, evaluateH = evaluateView:getSize();
			evaluateView:setPos(x, y);
			h = h + evaluateH;
			y = y + evaluateH;
			self:addChild(evaluateView);

			self.voteH = 10 + evaluateH;

			self.closedView = evaluateView:getChildByName("view_closed");
			self.voteView   = evaluateView:getChildByName("view_vote");

			--初始化 解决
			local btnSolve      = self.closedView:getChildByName("btn_solve");
			local btnNotSolve   = self.closedView:getChildByName("btn_notsolve");

			btnSolve:setOnClick(self,function()
				self:onClickSolve(self.service.id, true);
			end);

			btnNotSolve:setOnClick(self,function()
				self:onClickSolve(self.service.id, false);
			end);

			-- 初始化提交按钮
			self.btnSubmit = self.voteView:getChildByName("btn_commit");
--			self.btnSubmit:setEnable( false );
--			self.btnSubmit:setGray( true );
			self.btnSubmit:setOnClick( self, function( self )
				self:onClickVote(self.service.id, self.score );
			end);

			--self.score = 5;
            
			self:initVoteScoreBtn();
			
            --新需求去掉显示是否解决的操作
			--if notReaded then
				self.closedView:setVisible(false);
			--else
            if notVote then
				self.voteView:setVisible(true);
			end
		end
	end

	y = y + 25
	h = h + 25

	self.lastImgLine = self:createSpliteLine();

	self.lastImgLine:setSize(width,2);
	self.lastImgLine:setPos(x, y-2);
	self:addChild(self.lastImgLine);

	--y = y + 10;
	--h = h + 10;

	self:setSize(width, h); -- 比实际大小多出10个逻辑像素
end

FeedBackItem.initVoteScoreBtn = function( self )
	--初始化 打分
	self.btnVote = {};
	self.btnVote[1]   = self.voteView:getChildByName("btn_bad");
	self.btnVote[2]   = self.voteView:getChildByName("btn_dissatisfied");
	self.btnVote[3]   = self.voteView:getChildByName("btn_soso");
	self.btnVote[4]   = self.voteView:getChildByName("btn_good");
	self.btnVote[5]   = self.voteView:getChildByName("btn_verygood");

	for i = 1, #self.btnVote do
		self.btnVote[i]:setOnClick(self,function()
			local x,y = self.btnVote[i]:getPos();
			self:setScorePerform( i );
			self.btnSubmit:setEnable( true );
			self.btnSubmit:setGray( false );
		end);
	end
    --新需求 默认5星评价
    self:setScorePerform( 5 );
end

FeedBackItem.setScorePerform = function( self, index )
	if not index then
		return;
	end
	self.score = index;
	local filename = "newHall/help/unstart.png";
	for i = 1, #self.btnVote do
		if i <= index then
			filename = "newHall/help/start.png";
		else
			filename = "newHall/help/unstart.png";
		end
		self.btnVote[i]:setFile( filename );
	end
end

FeedBackItem.dtor = function(self)
end

FeedBackItem.onClickSolve = function ( self, id, isSolve )
	-- body
	self.service.readed = 1;

	if self.solveFunc then
		self.solveFunc(self.solveObj, id, isSolve);
	end

	self.closedView:setVisible(false);
	local notVote   = self.service.votescore and tonumber(self.service.votescore) == 0;
	if notVote then
		self.voteView:setVisible(true);
	else
		self:createCloseAnim();
	end
end

FeedBackItem.onClickVote = function ( self, id, vote )
	-- body
	self.service.votescore = vote;
	if self.voteFunc then
		 self.voteFunc(self.voteObj, id, vote);
	end
	self.voteView:setVisible(false);
	self:createCloseAnim();
end
FeedBackItem.invalidItem = function ( self, deltaH )
	if self.updateFunc then
		local w, h = self:getSize();
		h = h - deltaH;
		self:setSize(w, h);

		local x, y = self.lastImgLine:getPos();
		self.lastImgLine:setPos(x, y - deltaH);
		self.updateFunc(self.obj);
	end
end

FeedBackItem.createCloseAnim = function ( self )
	-- body
	local step  = 20;
	
	self.closeAnim = self:addPropTransparency(1, kAnimRepeat, 100, 0, 1, 1);
	self.closeAnim:setDebugName("FeedBackItem || anim");
	self.closeAnim:setEvent(self, function ( self )
		-- body
		self.animHeight = self.animHeight + step;

		if self.animHeight >= self.voteH then
			self:removeProp(1);
			self:invalidItem(self.animHeight - self.voteH);
			return;
		end

		self:invalidItem(step);

	end);

end

FeedBackItem.createDist = function ( self, width, name, r, g, b, desc, dr, dg, db)
	-- body

	local node = new(Node);

	local nameText = UICreator.createText(name,0,0,0,0,kAlignTopLeft, 26, r, g, b);
	nameText:setSize(nameText.m_res.m_width, nameText.m_res.m_height);
	node:addChild(nameText);

	local tvDesc = new(TextView,desc, width - nameText.m_res.m_width, 0, kAlignTopLeft, "", 26, dr, dg, db);
	tvDesc:setPos(nameText.m_res.m_width,0);
	tvDesc:setSize(tvDesc.m_drawing:getSize());
	node:addChild(tvDesc);

	local dW, dH = tvDesc:getSize();
	node:setSize(width, math.max(nameText.m_res.m_height,dH));

	return node;

end

FeedBackItem.createSpliteLine = function ( self)
	-- body
	local image = UICreator.createImg("Commonx/split_hori.png", 0, 0);

	return image;

end

FeedBackItem.createHelpEvaluate = function ( self)
	-- body
	-- local evaluateView = SceneLoader.load(helpEvaluate);
	-- return evaluateView;
end

