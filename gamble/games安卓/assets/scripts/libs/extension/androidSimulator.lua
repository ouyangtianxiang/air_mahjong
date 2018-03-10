-- androidSimulator.lua
-- Author: Vicent Gong
-- Date: 2013-07-03
-- Last modification : 2013-07-03
-- Description: Simulate anroid native keys
AndroidSimulator = class();

AndroidSimulator.ctor = function(self)
	EventDispatcher.getInstance():register(Event.KeyDown,self,self.onEvent);
end

AndroidSimulator.dtor = function(self)
	EventDispatcher.getInstance():unregister(Event.KeyDown,self,self.onEvent);
end

AndroidSimulator.onEvent = function(self,key)
	if key == 81 then -- B 
		EventDispatcher.getInstance():dispatch(Event.Back);
	end
end


