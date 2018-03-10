-- 飞信积分弹窗

local fetionScorePop = require(ViewLuaPath.."fetionScorePop");

FetionScorePop = class(CustomNode);

FetionScorePop.ctor = function ( self, root )
	self.root  = root;
	self.appear = false;

	self:load();
end

FetionScorePop.load = function ( self )
	self.layout = SceneLoader.load(fetionScorePop);
	self.root:addChild(self.scorePop);
	self.scorePop = publ_getItemFromTree(self.layout, {"bg"});

	self.score = {};
	self.img   = {};
	for i=1,4 do
		table.insert(self.score, publ_getItemFromTree(self.layout, {"bg", string.format("score%d", i)}));
		table.insert(self.img, publ_getItemFromTree(self.layout, {"bg", string.format("img%d", i)}));
	end

	self.windowW,self.windowH = self.scorePop:getSize();
	self.scorePop:setPos(-self.windowW+32, 50);

	self.scorePop:setEventTouch(self, function ( self )
		if not self.appear then
			self:updateScoreView();
			self:popWindowAppear();
		else
			self:popWindowDisappear();
		end
	end);
end

FetionScorePop.popWindowAppear = function (self)
	if not self.isUpdataScore then
		local data = {};
		for i =1, 4 do
			player = PlayerManager.getInstance():getPlayerBySeat(i-1);
			if player then
				table.insert(data, player.mid);
			end
		end
		FriendDataManager.getInstance():requestFetionScore(data);
		self.appear = false;
		return;
	end

	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self.anim_tmp = self.scorePop:addPropTranslate(1, kAnimNormal, 200, 0, 0, self.windowW-32, 0, 0);
	self.anim_tmp:setEvent(self, function (self)
		self.isPlaying = false;
		self.scorePop:removeProp(1);
		self.scorePop:setPos(0, 50);
		self.appear = true;
	end);	
end


FetionScorePop.popWindowDisappear = function ( self )
	if self.isPlaying then
		return;
	end
	self.isPlaying = true;

	self.anim = self.scorePop:addPropTranslate(2, kAnimNormal, 200, 0, 0, -self.windowW+32, 0, 0);		
	self.anim:setEvent(self, function (self)
		self.isPlaying = false;
		self.scorePop:removeProp(2);
		self.scorePop:setPos(-self.windowW+32, 50);
		self.appear = false;
	end);
end

FetionScorePop.updateScoreView = function ( self )
	if not FriendDataManager.getInstance().score then
		local data = {};
		for i =1, 4 do
			player = PlayerManager.getInstance():getPlayerBySeat(i-1);
			if player then
				table.insert(data, player.mid);
			end
		end
		-- data = {12636027,12636029,12636027,12636029};  -- debug
		FriendDataManager.getInstance():requestFetionScore(data);
		self.isUpdataScore = false;
		return;
	end
	self.isUpdataScore = true;

	local pic = nil;
	local player = nil;

	for i = 1,4 do
		self.score[i]:setText("");
		player = PlayerManager.getInstance():getPlayerBySeat(i-1);
		if player then
			if publ_isFileExsit_lua(player.localIconDir) then -- 图片已下载
				pic = player.localIconDir;
			else -- 图片下载启动
				player:downloadIconImg(); -- 下载并返回sd保存名称
			end

			pic = publ_downloadImg(player.localIconDir);
		    if publ_isFileExsit_lua(pic) then -- 图片已下载
		        self.img[i]:setFile(pic);
		    end
			self.score[i]:setText(FriendDataManager.getInstance().score[i]);
		end
	end
end




