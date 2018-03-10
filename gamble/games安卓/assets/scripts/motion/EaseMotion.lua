require("motion/Transmission");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] EaseBase------------------------------------------
---------------------------------------------------------------------------------------------

EaseBase = class(AnimBase);

EaseBase.ctor = function(self)
end
--------------- private functions, don't use these functions in your code -----------------------

EaseBase.onEvent = function(self, anim_type, anim_id, repeat_or_loop_num)
	self.m_timer = (self.m_timer + self.m_duration);
	self.m_process = self.m_transmission:getInterpolation(self.m_timer/self.m_dur_time);
	if self.m_eventCallback.func then
		self.m_eventCallback.func(self.m_eventCallback.obj,anim_type, anim_id, repeat_or_loop_num);
	end
end

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] EaseMotion-------------------------------------------
---------------------------------------------------------------------------------------------

EaseMotion = class(EaseBase);

EaseMotion.ctor = function(self, animType, duration, dur_time, delay, paramTb)
	self.m_timer = 0;			--计时器
	self.m_duration = duration;	--步长
	self.m_dur_time = dur_time;	--总时长
	self.m_type = animType;		--变速器类型
	self.m_param = paramTb or {};
	self.m_transmission = Transmission.create(self.m_type, unpack(self.m_param));	--获取对应变速器
	anim_create_int(0, self.m_animID, kAnimRepeat, 0, 1, duration, delay or 0);
end

EaseMotion.dtor = function(self)
	anim_delete(self.m_animID);
end




