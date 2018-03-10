require("ui/node");

-- 弹窗类基类
NoCoverCustomNode = class(Node)

NoCoverCustomNode.ctor = function (self)
	print("NoCoverCustomNode.ctor");
	-- 显示、关闭时的回调函数
	self.obj = nil;
	self.callback = nil;
end

NoCoverCustomNode.setCallback = function ( self, obj, fun )
	self.obj = obj;
	self.callback = fun;
end

NoCoverCustomNode.show = function ( self )
	self:setVisible(true);
	if self.callback then
		self.callback(self.obj, true);
	end
end

NoCoverCustomNode.hide = function ( self )
	self:setVisible(false);
	if self.callback then
		self.callback(self.obj, false);
	end
end

NoCoverCustomNode.setPos = function ( self, x, y )
	Node.setPos(self, x, y);
end

NoCoverCustomNode.dtor = function (self)
	self:setVisible(false);
	self:removeAllChildren();
end

