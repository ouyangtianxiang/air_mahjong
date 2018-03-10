MatchRoomSceneRank = class(Node)

MatchRoomSceneRank.ctor = function(self)

	self.backGroundImg 	= UICreator.createImg(Seat.rootDir.."matchRoomRankBg.png", 0, 0, 10, 10, 0, 0);
	self.leftImg 		= UICreator.createImg(Seat.rootDir.."roomInfo/logoLeft.png");
	self.rightImg  		= UICreator.createImg(Seat.rootDir.."roomInfo/logoRight.png");
	self:addChild(self.leftImg);
	self:addChild(self.rightImg);
	self:addChild(self.backGroundImg);

	self.backGroundImg:setAlign(kAlignCenter);
	self.leftImg:setAlign(kAlignLeft);
	self.rightImg:setAlign(kAlignRight);

	local w, h = self.backGroundImg:getSize();
	self.backGroundImg:setSize(20, h);

	local w, h = self.backGroundImg:getSize();
	local wl, hl = self.leftImg:getSize();
	local wr, hr = self.rightImg:getSize();
	self:setSize(wl + 10 + w + 10 + wr, h);	
end

MatchRoomSceneRank.dtor = function(self)
end

MatchRoomSceneRank.setMatchInfo = function ( self, matchInfo )
	-- self.matchInfo = matchInfo;
	-- self.time = matchInfo.times;

	-- if 8 == matchInfo.stage then
	-- 	if not self.time then
	-- 		self.time = matchInfo.times;
	-- 	end
	-- 	self:timer();
	-- end


	local PRELIMINARIES = 2; -- 人满赛预赛
	local KNOCKOUT 		= 3; -- 淘汰赛
	local FINALS 		= 4; -- 决赛
	local PRELIMINARIES_TIME = 8 -- 定时赛预赛
	--MahjongPrint(matchInfo);

	if matchInfo then
		if matchInfo.stage == PRELIMINARIES or matchInfo.stage == PRELIMINARIES_TIME then
			self:setPreliminaries(matchInfo.jvshu, matchInfo.rank, matchInfo.total_player_num, matchInfo.now_jifen, matchInfo.stage, matchInfo.times);
		elseif matchInfo.stage == KNOCKOUT then
			self:setKnockout(matchInfo.jvshu, matchInfo.rank, matchInfo.total_player_num, matchInfo.next_stage_num);
		elseif matchInfo.stage == FINALS then
			self:setFinals(matchInfo.finalJvshu, matchInfo.totalJvshu, matchInfo.rank, matchInfo.total_player_num);
		end	
	end	
end

--预赛
MatchRoomSceneRank.setPreliminaries = function ( self, round, place, total, limit, matchStage, time)
	self:clearNode();

	local textInfor = {};
	local text = {};
	text.t = "预赛";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "第"..round.."局";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "排名:";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(place);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = "/";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(total);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	if 2 == matchStage then

		local textInfor = {};
		local text = {};
		text.t = "淘汰:低于";
		text.r = 110;
		text.g = 230;
		text.b = 100;
		text.s = 24;
		textInfor[#textInfor + 1] = text;

		local text = {};
		text.t = tostring(limit);
		text.r = 255;
		text.g = 210;
		text.b = 34;
		text.s = 24;

		textInfor[#textInfor + 1] = text;

		local text = {};
		text.t = "分";
		text.r = 110;
		text.g = 230;
		text.b = 100;
		text.s = 24;
		textInfor[#textInfor + 1] = text;
		local node = self:createTextEx(textInfor);
		self:addNode(node);
	elseif 8 == matchStage then
		local textInfor = {};
		local text = {};
		-- local str1, str2 = self:getTime(self.time);
		text.t = string.sub(os.date("%X", time), 0, 5);
		text.r = 255;
		text.g = 210;
		text.b = 34;
		text.s = 24;
		textInfor[#textInfor + 1] = text;

		-- local text = {};
		-- text.t = str2;
		-- text.r = 110;
		-- text.g = 230;
		-- text.b = 100;
		-- text.s = 24;

		-- textInfor[#textInfor + 1] = text;

		local text = {};
		text.t = "预赛结束";
		text.r = 110;
		text.g = 230;
		text.b = 100;
		text.s = 24;
		textInfor[#textInfor + 1] = text;
		local node = self:createTextEx(textInfor);
		self:addNode(node);
	end

	self:updateNode();
end

--淘汰赛
MatchRoomSceneRank.setKnockout = function ( self, round, place, total, limit)
	-- body
	self:clearNode();
	local textInfor = {};

	local text = {};
	text.t = "淘汰赛";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "第"..round.."局";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "排名:";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(place);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = "/";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(total);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "前";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(limit);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = "名晋级下一轮";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	self:updateNode();
end
--决赛
MatchRoomSceneRank.setFinals = function ( self, round, rounds, place, total)
	-- body
	self:clearNode();
	local textInfor = {};

	local text = {};
	text.t = "决赛";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "第"..round .. "/" .. rounds .."局";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	local spliteNode = self:createSplite();
	self:addNode(spliteNode);

	local textInfor = {};
	local text = {};
	text.t = "排名:";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(place);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = "/";
	text.r = 110;
	text.g = 230;
	text.b = 100;
	text.s = 24;
	textInfor[#textInfor + 1] = text;

	local text = {};
	text.t = tostring(total);
	text.r = 255;
	text.g = 210;
	text.b = 34;
	text.s = 24;

	textInfor[#textInfor + 1] = text;

	local node = self:createTextEx(textInfor);
	self:addNode(node);

	self:updateNode();

end
------------------------------------------------private function------------------------------------------------
MatchRoomSceneRank.addNode = function(self, child)
	local pos 		= 10;
	local children = self.backGroundImg:getChildren();
	for i = 1, #children do
		local w, h = children[i]:getSize();
		pos = pos + w + 5; -- 两节点之间相距 5 逻辑像素
	end
	
	child:setAlign(kAlignLeft);
	child:setPos(pos , 0); 
	self.backGroundImg:addChild(child);

end

MatchRoomSceneRank.clearNode = function(self, child)
	self.backGroundImg:removeAllChildren();
end

MatchRoomSceneRank.updateNode = function(self)
	local width 		= 0;
	local children = self.backGroundImg:getChildren();
	for i = 1, #children do
		local w, h = children[i]:getSize();
		width = width + w;
	end

	if #children > 0 then
		width = width + (#children - 1) * 5;
	end

	local w, h = self.backGroundImg:getSize();
	self.backGroundImg:setSize(width + 20, h);

	local w, h = width + 20, h;
	local wl, hl = self.leftImg:getSize();
	local wr, hr = self.rightImg:getSize();
	self:setSize(wl + 10 + w + 10 + wr, h);
end

MatchRoomSceneRank.createSplite = function(self)
	return UICreator.createImg(Seat.rootDir.."matchRoomRankSplite.png");
end

-- -- 1秒定时器
-- MatchRoomSceneRank.timer = function (self)
--     if self.kickTimeAnim then
--         return;
--     end
--     self.kickTimeAnim = self:addPropTranslate(100, kAnimRepeat, 1000, 0, 0, 0, 0, 0);
--     self.kickTimeAnim:setDebugName("MatchRoomSceneRank|self.kickTimeAnim");
--     self.kickTimeAnim:setEvent(self, self.updateTime);
-- end

-- MatchRoomSceneRank.updateTime = function ( self )
--     self.time = self.time - 1;
--     if self.time >= 0 then
-- 		self:clearNode();
-- 		self:setPreliminaries(self.matchInfo.jvshu, self.matchInfo.rank, self.matchInfo.total_player_num, self.matchInfo.now_jifen, self.matchInfo.stage);
-- 	else
-- 		if self.kickTimeAnim then
-- 			delete(self.kickTimeAnim);
-- 			self.kickTimeAnim = nil;
-- 		end
-- 	end
-- end


-- MatchRoomSceneRank.getTime = function ( self, time )
--     local str1 = "";
--     local str2 = "";
--     local num = math.floor(time / 3600);
--     if num > 0 then
--         str1 = "" .. num;
--         str2 = "小时";
--     else
--         num = math.floor(time / 60);
--         if num > 0 then
--             str1 = "" .. num;
--             str2 = "分钟";
--         else
--             str1 = "" .. time;
--             str2 = "秒";
--         end
--     end
--     return str1,str2;
-- end

MatchRoomSceneRank.createTextEx = function ( self, textInfor )
	-- body
	local node = new(Node);
	local x, y = 0, 0;
	local w, h = 0, 0;
	for i = 1, #textInfor do
		local n = UICreator.createText(textInfor[i].t, 0, 0, 0, 0, kAlignLeft , textInfor[i].s, textInfor[i].r, textInfor[i].g, textInfor[i].b );
		node:addChild(n);
		n:setAlign(kAlignLeft);
		n:setPos(x, y);
		w, h = n:getSize();
		x = x + w;
	end
	node:setSize(x, h);

	return node;
end