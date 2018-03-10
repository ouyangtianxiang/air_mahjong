local TeachPin_map = require("qnPlist/TeachPin")

local shaiziPin_map = require("qnPlist/shaiziPin")


ShaiziAnimation = {};
ShaiziAnimation.x = 0;
ShaiziAnimation.y = 0;
ShaiziAnimation.w = 0;
ShaiziAnimation.h = 0;

ShaiziAnimation.audio = false;
ShaiziAnimation.step = -1;
ShaiziAnimation.idx = 0;


ShaiziAnimation.Delegate =
{
	onShaiziAnimEnd 	= "onShaiziAnimEnd",
}

local ShaiziAnimationNum = 16;

ShaiziAnimation.play = function(aniX, aniY, aniW, aniH)
	ShaiziAnimation.x = aniX;
	ShaiziAnimation.y = aniY;
	ShaiziAnimation.w = aniW;
	ShaiziAnimation.h = aniH;

	ShaiziAnimation.stop();

	ShaiziAnimation.load();

	ShaiziAnimation.root:setVisible(true);

	ShaiziAnimation.animIndex = new(AnimInt,kAnimRepeat,0,1,50,0);
	ShaiziAnimation.animIndex:setDebugName("ShaiziAnimation|ShaiziAnimation.animIndex");
	ShaiziAnimation.animIndex:setEvent(ShaiziAnimation,ShaiziAnimation.OnTimer);
	ShaiziAnimation.audioId = GameEffect.getInstance():play("BUTTON_CLICK");
	return ShaiziAnimation.root;
end

ShaiziAnimation.load = function()
	if ShaiziAnimation.loaded then
		return;
	end

	ShaiziAnimation.root = new(Node);
	ShaiziAnimation.root:setPos(ShaiziAnimation.x,ShaiziAnimation.y);
	ShaiziAnimation.root:setSize(ShaiziAnimation.w,ShaiziAnimation.h);

	local rotateImgs = {};  --shaizi_anmi1.png
	for i=1,ShaiziAnimationNum do
		table.insert(rotateImgs, shaiziPin_map[string.format("shaizi_anmi%d.png",i)]);
	end
	ShaiziAnimation.rotateImg = new(Images,rotateImgs);
	ShaiziAnimation.rotateImg:setPos(0,0);

	ShaiziAnimation.resultView = new(Node);
	ShaiziAnimation.resultView:setPos(0,0);
	ShaiziAnimation.resultView:setSize(ShaiziAnimation.rotateImg:getSize());

	local resultImgs = {};
	for i=1,6 do
		table.insert(resultImgs, TeachPin_map[string.format("shaizi%d.png",i)]);
	end
	ShaiziAnimation.resultImgs = {};
	for i = 1,2 do
		ShaiziAnimation.resultImgs[i] = new(Images,resultImgs);
		local w,h = ShaiziAnimation.resultImgs[i]:getSize();
		ShaiziAnimation.resultImgs[i]:setPos(90+(i-1)*(w+20),230);
		ShaiziAnimation.resultImgs[i]:setVisible(true);
		ShaiziAnimation.resultView:addChild(ShaiziAnimation.resultImgs[i]);
	end

	ShaiziAnimation.loaded = true;

	ShaiziAnimation.root:addChild(ShaiziAnimation.rotateImg);
	ShaiziAnimation.root:addChild(ShaiziAnimation.resultView);

	ShaiziAnimation.root:setVisible(false);
	ShaiziAnimation.rotateImg:setVisible(true);
	ShaiziAnimation.resultView:setVisible(false);
end


ShaiziAnimation.OnTimer = function(self, amim_type, anim_id, repeat_or_loop_num)
	ShaiziAnimation.step = ShaiziAnimation.step + 1;
	idx = ShaiziAnimation.step;
	--DebugLog("####@@@@1~2:"..idx)
	if idx < ShaiziAnimationNum then
		ShaiziAnimation.rotateImg:setImageIndex(idx);
	elseif idx <= 24 then
		if not ShaiziAnimation.result then
			ShaiziAnimation.result = {}
			ShaiziAnimation.result[1] = math.random(0,5);
			ShaiziAnimation.result[2] = math.random(0,5);
		end
		if(ShaiziAnimation.resultImgs[1]) then
			ShaiziAnimation.resultImgs[1]:setImageIndex(ShaiziAnimation.result[1]);
		end
		if(ShaiziAnimation.resultImgs[2]) then
			ShaiziAnimation.resultImgs[2]:setImageIndex(ShaiziAnimation.result[2]);
		end

		ShaiziAnimation.rotateImg:setVisible(false);
		ShaiziAnimation.resultView:setVisible(true);
	else
		if ShaiziAnimation.audioId then
			GameEffect.getInstance():stop(ShaiziAnimation.audioId)
			ShaiziAnimation.audioId = nil
		end 
		ShaiziAnimation.release();
		ShaiziAnimation.execDelegate(ShaiziAnimation.Delegate.onShaiziAnimEnd);
	end
end

ShaiziAnimation.stop = function()
	if ShaiziAnimation.root then
		ShaiziAnimation.root:setVisible(false);
		ShaiziAnimation.rotateImg:setVisible(true);
		ShaiziAnimation.resultView:setVisible(false);
	end

	ShaiziAnimation.result = nil;

	delete(ShaiziAnimation.animIndex);
	ShaiziAnimation.animIndex = nil;
	ShaiziAnimation.step = 0;
end


ShaiziAnimation.release = function ()
	DebugLog("ShaiziAnimation.release");
	ShaiziAnimation.stop();

	if ShaiziAnimation.root then
		local parent = ShaiziAnimation.root:getParent();
		if parent then
			parent:removeChild(ShaiziAnimation.root);
		end
		delete(ShaiziAnimation.root);
		ShaiziAnimation.root = nil;

		ShaiziAnimation.rotateImg = nil;
		ShaiziAnimation.resultView = nil;
		ShaiziAnimation.resultImgs = nil;
	end
	ShaiziAnimation.setDelegate()
	ShaiziAnimation.loaded = false;
end


ShaiziAnimation.setDelegate = function(dele , param)
	ShaiziAnimation.m_delegate = dele;
	ShaiziAnimation.param = param;
end;

ShaiziAnimation.execDelegate=function (func,...)
    if ShaiziAnimation.m_delegate and ShaiziAnimation.m_delegate[func] then
        ShaiziAnimation.m_delegate[func](ShaiziAnimation.m_delegate,ShaiziAnimation.param,...);
    end
end
