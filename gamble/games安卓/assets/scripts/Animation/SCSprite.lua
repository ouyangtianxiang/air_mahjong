require("Animation/SpriteConfig");

-- 精灵类，使用前先在SpriteConfig中配置精灵的配置文件
SCSprite = class(Node);

SCSprite.ctor = function(self, spriteType)

  	self.drawing = nil; -- 图片资源
  	self.frameCount = 0; -- 帧数
  	self.roundTime = 0; -- 一个动画周期时长
  	self.playMode = kAnimNormal; -- 播放形式
  	self.animIndex = nil;
  	self.propImageIndex = nil;
	self.playing = false;

	-- 加载资源
	local config = SpriteConfig.configMap[spriteType];
	if not config then
		error(" create SCSprite failed ! sprite "..spriteType.." config info is nil on SpriteConfig file.");
	end
	if type(config) == "function" then
		config = config(); -- 函数生成配置表
	end

  	self:load(config);
  	-- self:addToRoot();
end

SCSprite.load = function ( self, config )
	local imgDirs = config.imgDirs;
	self.imgDirs = imgDirs;
	self.frameCount = #imgDirs;
	self.roundTime = config.roundTime;
	self.res = new(ResImage, imgDirs[1]);
	self.resArray = {};
	if type(self.roundTime) ~= "table" then
		self.drawing = new(DrawingImage, self.res);
	else
		self.drawing = new(Image, imgDirs[1]);
	end
	if config.w and config.h then
		self.drawing:setSize(config.w, config.h);
	end
	if type(self.roundTime) ~= "table" then
	    for i=2, self.frameCount do
	      local res_1 = new(ResImage, imgDirs[i]);
	      table.insert(self.resArray, res_1);
	      self.drawing:addImage(res_1, i-1);
		end
	end
  	self:addChild(self.drawing);
end

SCSprite.setSize = function ( self, w, h )
	Node.setSize(self, w, h);
	self.drawing:setSize(w, h);
end

-- 设置动画回调函数，playMode 3 种情况的回调说明：
-- kAnimNormal：动画播放一次，结束会掉，这种情况下如果不设回调，默认回调时释放动画
-- kAnimRepeat：动画循环播放，每次播放前回调
-- kAnimLoop：动画往复播放，每次开始前回调
SCSprite.setSCSpriteCallback = function ( self, obj, callback )
	self.obj = obj;
	self.callback = callback;
end

-- 设置播放模式，如下3种方式
-- kAnimNormal	= 0;
-- kAnimRepeat	= 1;
-- kAnimLoop	= 2;
SCSprite.setPlayMode = function ( self, mode )
	self.playMode = mode;
end

SCSprite.timeCaluFun = function ( self, index )

	-- 0 到 self.frameCount - 1
	local time = self.roundTime[index] or 0;
	self.timerAnim = new(AnimInt , kAnimNormal , 0, 1, time, -1);
	self.timerAnim:setDebugName("SCSprite|self.timerAnim");
	self.timerAnim:setEvent(self, function ( self )
		delete(self.timerAnim);
		self.timerAnim = nil;
		local imgIndex = index + 1;
		if imgIndex > self.frameCount then
			if self.playMode == kAnimNormal then -- 结束播放
				self:stop();
				self.m_parent:removeChild(self);
				delete(self);
				return;
			else -- 循环
				imgIndex = 1;
				index = 0;
			end
		end
		self.drawing:setFile(self.imgDirs[imgIndex]);
		self:timeCaluFun(index + 1);
	end);
end

SCSprite.play = function(self)
	if self.playing then 
		return 
	end 
	
	self.curIndex = 0;
	-- self:stop();
	self.playing = true;
	self.drawing:setVisible(true);
	if type(self.roundTime) == "table" then -- 指定每一帧的间隔
		self:timeCaluFun(1);
	else
		-- 创建一个可变值
		self.animIndex = new(AnimInt, self.playMode, 0, self.frameCount - 1, self.roundTime, 0);
		self.animIndex:setDebugName("SCSprite|self.animIndex");

		-- 创建一个ImageIndex prop
		self.propImageIndex = new(PropImageIndex, self.animIndex);
		-- 赋给drawing
		self.drawing:addProp(self.propImageIndex, 0);
		-- 动画完后 删除赋给drawing的prop
		self.animIndex:setEvent(self, self.onTimer);
	end
end

SCSprite.stop = function(self)
	if self.playing then
	    delete(self.timerAnim);
	    self.timerAnim = nil;
		delete(self.res);
		self.res= nil;
		delete(self.drawing);
		self.drawing = nil;
		for k,v in pairs(self.resArray) do
			delete(v);
		end
		self.resArray = {};
		self.playing = false;

	    delete(self.animIndex);
	    self.animIndex = nil;
	    delete(self.propImageIndex);
	    self.propImageIndex = nil;
	end
end

SCSprite.onTimer = function (self,anim_type, anim_id, repeat_or_loop_num)

	if self.obj and self.callback then
		self.callback( self.obj );
		return;
	end
	if self.playMode == kAnimNormal then
		self:stop();
		self:removeFromSuper();
	end
end


SCSprite.dtor = function(self)

	self:stop();
	delete(self.timerAnim);
	self.timerAnim = nil;
    self:removeAllChildren();
end


