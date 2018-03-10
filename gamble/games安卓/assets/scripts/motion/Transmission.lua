kCCEaseIn 	= 1;			-- 越来越快
kCCEaseOut 	= 2;			-- 先快后慢，S曲线
kAccelerateDecelerate = 3;	-- 在动画开始与结束的地方速率改变比较慢，在中间的时候加速
kAccelerate = 4;			-- 在动画开始的地方速率改变比较慢，然后开始加速
kAnticipate = 5;			-- 开始的时候向后然后向前甩
kAnticipateOvershoot = 6;	-- 开始的时候向后然后向前甩一定值后返回最后的值
kBounce = 7;				-- 动画结束的时候弹起
kCycle = 8;					-- 动画循环播放特定的次数，速率改变沿着正弦曲线
kDecelerate = 9;			-- 在动画开始的地方快然后慢
kLinear = 10;				-- 以常量速率改变
kOvershoot = 11;			-- 开始的时候向后然后向前甩一定值后返回最后的值
kBrezier = 12;
kBounce1 = 13;				-- 动画结束的时候弹起2次
kEaseOut = 14;              -- 动画开始的时候很快 后面均匀降速

---------------------------------------------------------------------------------------------
---------------------------------------- Transmission ---------------------------------------
------------------------------------------- 变速器 ------------------------------------------
---------------------------------------------------------------------------------------------
Transmission = {};

Transmission.create = function(param , ...)
	if param == kCCEaseIn then 
		return new(CCEaseInInterpolator, ...);
	elseif param == kCCEaseOut then 
		return new(CCEaseOutInterpolator, ...);
	elseif param == kAccelerateDecelerate then
		return new(AccelerateDecelerateInterpolator, ...);
	elseif param == kAccelerate then
		return new(AccelerateInterpolator, ...);
	elseif param == kAnticipate then
		return new(AnticipateInterpolator, ...);
	elseif param == kAnticipateOvershoot then
		return new(AnticipateOvershootInterpolator, ...);
	elseif param == kBounce then
		return new(BounceInterpolator, ...);
	elseif param == kBounce1 then
		return new(BounceInterpolator1, ...);
	elseif param == kCycle then
		return new(CycleInterpolator, ...);
	elseif param == kDecelerate then
		return new(DecelerateInterpolator, ...);
	elseif param == kLinear then
		return new(LinearInterpolator, ...);
	elseif param == kOvershoot then
		return new(OvershootInterpolator, ...);	
	elseif param == kBrezier then
		return new(BrezierInterpolator, ...);
	elseif param == kEaseOut then
		return new(SoftEaseOutInterpolator, ...)
	end

end

---------------------------------------------------------------------------------------------
----------------------------------- 各种变速器 ----------------------------------------------
---------------------------------------------------------------------------------------------

-- 差值计算
local function a(t, s)
	return t * t * ((s + 1) * t - s);
end

local function o(t, s)
	return t * t * ((s + 1) * t - s);
end

local function bounce(t)
    return t * t * 8.0;
end

local function powf(x, y)
	return math.pow(x, y);
end

Interpolator = class();

Interpolator.ctor = function(self)
end

Interpolator.getInterpolation = function(self, curValue)
	return curValue;
end


-- 在动画开始与结束的地方速率改变比较慢，在中间的时候加速
AccelerateDecelerateInterpolator = class(Interpolator);

AccelerateDecelerateInterpolator.getInterpolation = function(self, curValue)
	return (math.cos((curValue + 1) * math.pi) / 2.0) + 0.5;
end


--在动画开始的地方速率改变比较慢，然后开始加速
AccelerateInterpolator = class(Interpolator);
AccelerateInterpolator.ctor = function(self, factor)
	self.m_factor = factor or 1.0;
	self.m_doubleFactor = 2*self.m_factor;
end

AccelerateInterpolator.getInterpolation = function(self, curValue)
	if (self.m_factor == 1.0) then
        return curValue * curValue;
    else 
        return math.pow(curValue, self.m_doubleFactor);
    end
end

--开始的时候向后然后向前甩
AnticipateInterpolator = class(Interpolator);
AnticipateInterpolator.ctor = function(self, tension)
	self.m_tension = tension or 2.0;
end

AnticipateInterpolator.getInterpolation = function(self, curValue)
	return curValue * curValue * ((self.m_tension + 1) * curValue - self.m_tension);
end

--开始的时候向后然后向前甩一定值后返回最后的值
AnticipateOvershootInterpolator = class(Interpolator);
AnticipateOvershootInterpolator.ctor = function(self, tension, extraTension)
	self.m_tension = (tension or 2.0) * (extraTension or 1.5);
end

AnticipateOvershootInterpolator.getInterpolation = function(self, curValue)
	if (curValue < 0.5) then
		return 0.5 * a(curValue * 2.0, self.m_tension);
    else 
    	return 0.5 * (o(curValue * 2.0 - 2.0, self.m_tension) + 2.0);
    end
end


--动画结束的时候弹起
BounceInterpolator = class(Interpolator);
BounceInterpolator.ctor = function(self)
end

BounceInterpolator.getInterpolation = function(self, curValue)
	curValue = curValue * 1.1226;
    if (curValue < 0.3535) then
    	return bounce(curValue);
    elseif (curValue < 0.7408) then
    	return bounce(curValue - 0.54719) + 0.7;
    elseif (curValue < 0.9644) then
    	return bounce(curValue - 0.8526) + 0.9;
    else 
    	return bounce(curValue - 1.0435) + 0.95;
    end
end


--动画结束的时候弹起2次
BounceInterpolator1 = class(Interpolator);
BounceInterpolator1.ctor = function(self)
end

BounceInterpolator1.getInterpolation = function(self, curValue)
    if (curValue < 0.8) then
    	return curValue * curValue * 0.78125 + 0.5;
    else 
    	return 15 * (curValue - 0.9) * (curValue - 0.9) + 0.85;
    end
end

--动画循环播放特定的次数，速率改变沿着正弦曲线
CycleInterpolator = class(Interpolator);
CycleInterpolator.ctor = function(self, cycles)
	self.m_cycles = cycles or 1;
end

CycleInterpolator.getInterpolation = function(self, curValue)
	return (math.sin(2 * self.m_cycles * math.pi * curValue));
end

--在动画开始的地方快然后慢
DecelerateInterpolator = class(Interpolator);
DecelerateInterpolator.ctor = function(self, factor)
	self.m_factor = factor or 1.0;
end

DecelerateInterpolator.getInterpolation = function(self, curValue)
	local result;
    if (self.m_factor == 1.0) then
        result = (1.0 - (1.0 - curValue) * (1.0 - curValue));
    else
        result = (1.0 - math.pow((1.0 - curValue), 2 * self.m_factor));
    end
    return result;
end
 
--以常量速率改变
LinearInterpolator = class(Interpolator);
LinearInterpolator.getInterpolation = function(self, curValue)
	return curValue;
end

--向前甩一定值后再回到原来位置
OvershootInterpolator = class(Interpolator);
OvershootInterpolator.ctor = function(self, tension)
	self.m_tension = tension or 2.0;
end
OvershootInterpolator.getInterpolation = function(self, curValue)
	curValue = curValue - 1.0;
    return curValue * curValue * ((self.m_tension + 1) * curValue + self.m_tension) + 1.0;
end

-- 越来越快
CCEaseInInterpolator = class(Interpolator)
CCEaseInInterpolator.getInterpolation = function(self, curValue)
	return 1- math.cos(math.pi/2*curValue);
end

-- 先快后慢 S曲线
CCEaseOutInterpolator = class(Interpolator)
CCEaseOutInterpolator.getInterpolation = function(self, curValue)
	return -0.5*(math.cos(math.pi*curValue) -1);
end

-- 贝塞尔
BrezierInterpolator = class(Interpolator)
BrezierInterpolator.ctor = function(self, x1, y1, x2, y2)
	self.m_x0 = 0;
	self.m_y0 = 0;
	self.m_x1 = x1;
	self.m_y1 = y1;
	self.m_x2 = x2;
	self.m_y2 = y2;
	self.m_x3 = 1;
	self.m_y3 = 1;
end

BrezierInterpolator.getInterpolation = function(self, curValue)
	local m_x = 3 * self.m_x1 * curValue* math.pow(1-curValue, 2) +
		3 * self.m_x2 * math.pow(curValue, 2) * (1-curValue) + math.pow(curValue, 3);
	local process = 3 * self.m_y1 * m_x* math.pow(1-m_x, 2) +
		3 * self.m_y2 * math.pow(m_x, 2) * (1-m_x) + math.pow(m_x, 3);
	return process;
end

-- 先快之后柔和减慢
SoftEaseOutInterpolator = class(Interpolator)

SoftEaseOutInterpolator.ctor = function(self, tension)
	self.m_tension = tension or 2;
end

SoftEaseOutInterpolator.getInterpolation = function(self, curValue)
 	if curValue == 1 then
		return curValue;
	else
		local interpolation = 1 - powf(self.m_tension, -10 * curValue/1);
		if interpolation >= 0.99999 then
			return 1;
		else
			return interpolation;
		end
	end
end

