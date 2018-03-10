-- file: 'ExpressionAnim.lua'


require("Animation/expressionMagic1");
require("Animation/expressionMagic2");
require("Animation/expressionMagic3");
require("Animation/expressionMagic4");
require("Animation/expressionMagic5");
require("Animation/expressionMagic6");
require("Animation/expressionMagic7");
require("Animation/expressionMagic8");
require("Animation/expressionMagic9");
require("Animation/expressionMagic10");
require("Animation/expressionMagic11");
require("Animation/vip1");
require("Animation/vip2");
require("Animation/vip3");
require("Animation/vip4");
require("Animation/vip5");
require("Animation/vip6");
require("Animation/vip7");
require("Animation/vip8");
require("Animation/vip9");
require("Animation/vip10");
require("Animation/vip11");
require("Animation/vip12");

ExpressionAnim = {};
ExpressionAnim.loaded = false;
ExpressionAnim.time=2500;
ExpressionAnim.playCount = 1;
ExpressionAnim.sprites={};
ExpressionAnim.coords = {
    [0] = {155,275,120,120},
    [1] = {616,164,120,120},
    [2] = {155,18,120,120},
    [3] = {61,164,120,120},

    [4] = {406,292,120,120},
    [5] = {522,164,120,120},
    [6] = {406,18,120,120},
    [7] = {156,164,120,120},
};

--private
ExpressionAnim.onTimer=function(sp,anim_type, anim_id, repeat_or_loop_num)
	if repeat_or_loop_num >= sp.playCount-1 then
		ExpressionAnim.releaseSprite(sp);
	end
end

--private
ExpressionAnim.releaseSprite=function(sp)
	local sprite 
	if type(sp) == "table" then 
		sprite = sp;
	else
		sprite = ExpressionAnim.sprites[sp];
	end
	if not sprite then 
	    return;
	end
    if sprite.drawing and sprite.prop then 
        sprite.drawing:removePropByID(sprite.prop.m_propID);
    end;
    delete(sprite.prop);
    sprite.prop = nil;
    delete(sprite.anim);
    sprite.anim = nil;
	
    if sprite.res then
        for k,v in pairs(sprite.res) do 
            delete(v);
        end
    end
    sprite.res = nil;
    if sprite.drawing then
        ExpressionAnim.root:removeChild(sprite.drawing);
        delete(sprite.drawing);
        sprite.drawing = nil;
    end
end

ExpressionAnim.loadResOld = function(formatName,startIndex,num)
	local res = {};
	for i=0,num-1 do
		local strTmp=string.format(formatName,i+startIndex);
        strTmp=MJAnim_map[strTmp];
		res[i] = new(ResImage,strTmp);
	end
	return res;
end


ExpressionAnim.loadRes = function(formatName,startIndex,num)
    
    local res       = {};
    local config    = ExpressionAnim.config[formatName];
    local count     = 0
    for _ in pairs(config) do count = count + 1 end
    for i = 0, count - 1 do
        local key  = "" .. (i+1) ..".png";
        local temp = {};
        temp.x = config[key].x;
        temp.y = config[key].y;
        temp.width = config[key].width;
        temp.height = config[key].height;
        temp.file = "face_anim/" .. config[key].file;
        res[i] = new(ResImage,temp);
    end
    return res;
end

ExpressionAnim.createDrawing = function(res,x,y,w,h)
	local drawing = new(DrawingImage,res[0]);
	drawing:setPos(x,y);
	drawing:setSize(w,h);
	for i=1,#res do
		drawing:addImage(res[i],i);
	end
	
	return drawing;
end

ExpressionAnim.play = function(seat,formatName,startIndex,num,duration,playCount,x,y,w,h, oldVersion)	
    if ExpressionAnim.coords and ExpressionAnim.coords[seat] then 
        x = x or ExpressionAnim.coords[seat][1];
        y = y or ExpressionAnim.coords[seat][2];
        w = w or ExpressionAnim.coords[seat][3];
        h = h or ExpressionAnim.coords[seat][4];
    end
    ExpressionAnim.releaseSprite(seat);

    if not ExpressionAnim.loaded then
    	ExpressionAnim.loaded = true;
    	ExpressionAnim.root = new(Node);
        ExpressionAnim.root:setLevel(4);
    	ExpressionAnim.root:addToRoot();
    end

	local sprite = {};
	sprite.playCount = playCount or ExpressionAnim.playCount;
    sprite.res = oldVersion and ExpressionAnim.loadResOld(formatName,startIndex,num) or ExpressionAnim.loadRes(formatName,startIndex,num);

    w = sprite.res[1].m_width;
    h = sprite.res[1].m_height;

	sprite.drawing = ExpressionAnim.createDrawing(sprite.res,x,y,w,h);
	ExpressionAnim.root:addChild(sprite.drawing);
	
    sprite.anim = oldVersion and new(AnimInt,kAnimRepeat,0,#sprite.res,duration or ExpressionAnim.time,-1) or 
                    new(AnimInt,kAnimRepeat,0,#sprite.res,#sprite.res * duration,-1);
    sprite.anim:setDebugName("ExpressionAnim|sprite.anim");
	sprite.anim:setEvent(sprite,ExpressionAnim.onTimer);
	sprite.prop = new(PropImageIndex,sprite.anim);
	sprite.drawing:addProp(sprite.prop,0);
	
	ExpressionAnim.sprites[seat] = sprite;

	return ExpressionAnim.root;
end

--public
ExpressionAnim.release=function()
    for k,v in pairs(ExpressionAnim.sprites) do 
        ExpressionAnim.releaseSprite(k);
        ExpressionAnim.sprites[k] = nil;
    end
    ExpressionAnim.sprites = {};

    if ExpressionAnim.root then
    	local parent = ExpressionAnim.root:getParent();
    	if parent then
    		parent:removeChild(ExpressionAnim.root);
    	end
        ExpressionAnim.root:setVisible(false);
    	delete(ExpressionAnim.root);
    	ExpressionAnim.root = nil;
    end

    ExpressionAnim.loaded = false;
end


ExpressionAnim.config = 
{
    ["expressionMagic1"] = expressionMagic1_map,
    ["expressionMagic2"] = expressionMagic2_map,
    ["expressionMagic3"] = expressionMagic3_map,
    ["expressionMagic4"] = expressionMagic4_map,
    ["expressionMagic5"] = expressionMagic5_map,
    ["expressionMagic6"] = expressionMagic6_map,
    ["expressionMagic7"] = expressionMagic7_map,
    ["expressionMagic8"] = expressionMagic8_map,
    ["expressionMagic9"] = expressionMagic9_map,
    ["expressionMagic10"] = expressionMagic10_map,
    ["expressionMagic11"] = expressionMagic11_map,
    ["vip1"] = vip1_map,
    ["vip2"] = vip2_map,
    ["vip3"] = vip3_map,
    ["vip4"] = vip4_map,
    ["vip5"] = vip5_map,
    ["vip6"] = vip6_map,
    ["vip7"] = vip7_map,
    ["vip8"] = vip8_map,
    ["vip9"] = vip9_map,
    ["vip10"] = vip10_map,
    ["vip11"] = vip11_map,
    ["vip12"] = vip12_map
}


