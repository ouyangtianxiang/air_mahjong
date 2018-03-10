
local l_parse_str = function (str)
    if not str then
        return {},0;
    end

    local str_table = {};
    local tmp = string.split(str, "|")
    if tmp then
        return tmp, #tmp;
    end
    return {},0;
end


--获得金币特殊banner
AnimationAwardTips = {};

AnimationAwardTips.tipsTable = {};

AnimationAwardTips.ctor = function()
	
end

AnimationAwardTips.load = function(str, moveFlag)
	-- if AnimationAwardTips.root then
	-- 	AnimationAwardTips.stop();
	-- end
    local t,n = l_parse_str(str);
    if not t then
        return;
    end

	local root = new(Node);
	root:addToRoot();
	root:setLevel(60);
	local tipBg = UICreator.createImg("Commonx/coinBanner.png");
    root:addChild(tipBg);
	local w , h = tipBg:getSize();
    if n > 1 then
        h = h*n*0.7;
    end
    tipBg:setSize(w , h);
	root:setSize(w , h);
    root:setAlign(kAlignCenter);
    local orign_y = 35
    if n > 2 then
        orign_y = orign_y + 15*(n-2);
    end

    local font_size = 40;
    if n == 1 then
        local tipText = UICreator.createText(t[1], 0, 0, 0, 0, kAlignCenter, font_size, 150, 40, 40);
        tipText:setAlign(kAlignCenter)
        root:addChild(tipText);
    else
        for i = 1, n do
            local tipText = UICreator.createText(t[i], 0, 0, 0, 0, kAlignCenter, font_size, 150, 40, 40);
            tipText:setAlign(kAlignTop)
            local y = orign_y+ (font_size+10)*(i-1);
           
            tipText:setPos(0, y);
            root:addChild(tipText);
        end
    end


    

	if moveFlag then
		root:setPos(0, h);
	end
	-- 渐显
	root:addPropTransparency(0, kAnimNormal, 300, 0, 0, 1);
	local anim = new(AnimDouble, kAnimNormal,0,1, 2500,0);
	anim:setDebugName("AnimationAwardTips || anim");

	local scale = System.getLayoutScale();

	local index = #AnimationAwardTips.tipsTable + 1;
	AnimationAwardTips.tipsTable[index] = {};
	AnimationAwardTips.tipsTable[index].root = root;
	AnimationAwardTips.tipsTable[index].anim = anim;
	AnimationAwardTips.tipsTable[index].c = index;

	local cx , cy = root:getPos();
	local totaly = h * index + (index - 1) * 10;
	local total_t_y = totaly / 2 - h / 2;

	local x , y = cx / scale , 0;
	DebugLog("这是是分割线");
	DebugLog("totaly : "..totaly);
	for k , v in pairs(AnimationAwardTips.tipsTable) do
		-- if k <= index / 2 then
			local ty = (k - 1) * h + ((k - 2) > 0 and (k - 2) or 0) * 10;
			y = ty - cy / scale - total_t_y;
		-- else
		-- 	local ty = (k - 1) * h + ((k - 2) > 0 and k - 2 or 0) * 10;
		-- 	y = ty - cy / scale;
		-- end
		DebugLog("AnimationAwardTips x : "..x);
		DebugLog("AnimationAwardTips y : "..y);
		v.root:setPos(x , y);
	end

	anim:setEvent(nil, function()
		for k , v in pairs(AnimationAwardTips.tipsTable) do 
			DebugLog("释放 c : "..v.c);
			if anim == v.anim then
				v.root:removeFromSuper();
				delete(v.anim);
				table.remove(AnimationAwardTips.tipsTable , k);
				break;
			end
		end
	end);




	-- AnimationAwardTips.root = new(Node);
	-- AnimationAwardTips.root:addToRoot();
	-- AnimationAwardTips.root:setLevel(60);
	-- AnimationAwardTips.tipBg  = UICreator.createImg("Commonx/coinBanner.png");
	-- local w,h = AnimationAwardTips.tipBg:getSize();
	-- AnimationAwardTips.root:setSize(w,h);
	-- AnimationAwardTips.tipText = UICreator.createText(str, 0, 0, 0, 0, kAlignCenter, 40, 150, 40, 40);
	-- AnimationAwardTips.root:setAlign(kAlignCenter);
	-- AnimationAwardTips.root:addChild(AnimationAwardTips.tipBg);
	-- AnimationAwardTips.root:addChild(AnimationAwardTips.tipText);
	-- AnimationAwardTips.tipText:setAlign(kAlignCenter);
	-- -- 渐显
	-- AnimationAwardTips.root:addPropTransparency(0, kAnimNormal, 300, 0, 0, 1);
	-- AnimationAwardTips.anim = new(AnimDouble, kAnimNormal,0,1, 2500,0);
	-- AnimationAwardTips.anim:setDebugName("AnimationAwardTips || anim");
	-- AnimationAwardTips.anim:setEvent(nil, AnimationAwardTips.stop);
end

AnimationAwardTips.play = function(str)
	if not str or str == "" then
		return;
	end
	AnimationAwardTips.load(str);
end

AnimationAwardTips.stop = function()
	if not AnimationAwardTips.root then 
		return; 
	end
	if AnimationAwardTips.anim then
		delete(AnimationAwardTips.anim);
		AnimationAwardTips.anim = nil;
	end
	if not AnimationAwardTips.root:checkAddProp(0) then
        AnimationAwardTips.root:removeProp(0);  -- 移除属性
    end 
	AnimationAwardTips.root:removeAllChildren();
	AnimationAwardTips.root = nil;
end

AnimationAwardTips.dtor = function()

end

