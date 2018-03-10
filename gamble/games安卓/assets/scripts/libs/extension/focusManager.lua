-- focusManager.lua
-- Author: Vicent Gong
-- Date: 2013-07-02
-- Last modification : 2013-07-03
-- Description: Simlute a android TV focus manager
FocusManager = class();

FocusManager.Left = 1;
FocusManager.Right = 2;
FocusManager.Up = 3;
FocusManager.Down = 4;
FocusManager.Forward = 5;
FocusManager.Backward = 6;
FocusManager.Enter = 7;

FocusManager.Event = EventDispatcher.getInstance():getUserEvent();

FocusManager.ctor = function(self)
	self.m_itemMap = {};
	self.m_currentItem = nil;
end

FocusManager.start = function(self)
	EventDispatcher.getInstance():register(FocusManager.Event,self,self.onEvent);
end

FocusManager.stop = function(self)
	EventDispatcher.getInstance():unregister(FocusManager.Event,self,self.onEvent);
end

FocusManager.setCurItem = function(self,item)
	self.m_currentItem = item or self.m_currentItem;
end

FocusManager.addForwardItem = function(self,item,forwardItem)
	if not item then
		return;
	end

	if #self.m_itemMap == 0 then
		FocusManager.setCurItem(self,item);
	end

	self.m_itemMap[item] = FocusManager.getItemTable(self,item);

	if not forwardItem or item == forwardItem then
		return;
	end

	FocusManager.removeForwardItem(self,forwardItem);
	self.m_itemMap[forwardItem] = FocusManager.getItemTable(self,forwardItem);

	local orgForwardItem = self.m_itemMap[item][FocusManager.Forward];
	FocusManager.setDirectionItem(self,forwardItem,FocusManager.Forward,orgForwardItem);
	FocusManager.setDirectionItem(self,orgForwardItem,FocusManager.Backward,forwardItem);
	FocusManager.setDirectionItem(self,item,FocusManager.Forward,forwardItem);
	FocusManager.setDirectionItem(self,forwardItem,FocusManager.Backward,item);
end

FocusManager.removeForwardItem = function(self,item)
	if not item then
		return;
	end

	local itemTable = self.m_itemMap[item];
	if not itemTable then
		return;
	end

	backwardItem = itemTable[FocusManager.Backward];
	forwardItem = itemTable[FocusManager.Forward];

	FocusManager.setDirectionItem(self,backwardItem,FocusManager.Forward,forwardItem);
	FocusManager.setDirectionItem(self,forwardItem,FocusManager.Backward,backwardItem);

	itemTable[FocusManager.Forward] = nil;
	itemTable[FocusManager.Backward] = nil;

	if item == self.m_currentItem then
		FocusManager.setCurItem(self,backwardItem or forwardItem);
	end
end

FocusManager.addDPadItem = function(self,item,leftItem,rightItem,upItem,downItem)
	self.m_itemMap[item] = FocusManager.getItemTable(item);
	local itemTable = self.m_itemMap[item];
	itemTable[FocusManager.Left] = leftItem;
	itemTable[FocusManager.Right] = rightItem;
	itemTable[FocusManager.Up] = upItem;
	itemTable[FocusManager.Down] = downItem;
end

FocusManager.removeDPadItem = function(self,item,autoLink)
	if not (item and self.m_itemMap[item]) then
		return;
	end

	if autoLink then
		local itemTable = self.m_itemMap[item];
		local leftItem = itemTable[FocusManager.Left];
		local rightItem = itemTable[FocusManager.Right];
		local upItem = itemTable[FocusManager.Up];
		local downItem = itemTable[FocusManager.Down];

		FocusManager.setDirectionItem(leftItem,FocusManager.Right,rightItem);
		FocusManager.setDirectionItem(rightItem,FocusManager.Left,leftItem);
		FocusManager.setDirectionItem(upItem,FocusManager.Down,downItem);
		FocusManager.setDirectionItem(downItem,FocusManager.Up,upItem);
	end

	itemTable[FocusManager.Left] = nil;
	itemTable[FocusManager.Right] = nil;
	itemTable[FocusManager.Down] = nil;
	itemTable[FocusManager.Up] = nil;
end

FocusManager.getItemTable = function(self,item)
	return self.m_itemMap[item] or {};
end

FocusManager.setDirectionItem = function(self,item,direction,directionItem)
	if not item then
		return;
	end

	local itemTable = FocusManager.getItemTable(self,item);
	itemTable[direction] = directionItem;
	self.m_itemMap[item] = itemTable;
end

FocusManager.onEvent = function(self,key)
	if not self.m_currentItem then
		return;
	end

	if key == FocusManager.Enter then
		self.m_currentItem:onEventTouch(kFingerDown,0,0,
			self.m_currentItem:getId(),self.m_currentItem:getId());
		self.m_currentItem:onEventTouch(kFingerUp,0,0,
			self.m_currentItem:getId(),self.m_currentItem:getId());
	else
		local itemTable = self.m_itemMap[m_currentItem];

		if not (itemTable and itemTable[key])then
			return;
		end

		self.m_currentItem:onEventFocus(kFocusOut);
		self.m_currentItem = itemTable[key];
		self.m_currentItem:onEventFocus(kFocusIn);
	end
end


