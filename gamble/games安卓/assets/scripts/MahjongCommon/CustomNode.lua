require("ui/node");

-- 弹窗类基类
CustomNode = class(Node)

CustomNode.ctor = function (self)
    
	self.cover = UICreator.createImg("Commonx/zhezhao.png");
	self.cover:setTransparency( 0 );
	-- 显示、关闭时的回调函数
	self.obj = nil;
	self.callback = nil;
	self.cover:setPos(0, 0);
	self.cover:setSize(System.getScreenWidth() / System.getLayoutScale() , System.getScreenHeight() / System.getLayoutScale());
	self:setSize(System.getScreenWidth() / System.getLayoutScale() , System.getScreenHeight() / System.getLayoutScale());
	self.cover:setEventTouch(self , function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
		if finger_action == kFingerUp then
			self:hide();
		end
	end);
	self.cover:setEventDrag(self , function (self)
		-- NoThing
	end);
	self:addChild(self.cover);
end

function CustomNode.setCoverTransparent( self )
	self.cover:setFile( "Commonx/zhezhao.png" );
	self.cover:setTransparency(1.1);
end

CustomNode.setCallback = function ( self, obj, fun )
	self.obj = obj;
	self.callback = fun;
end

CustomNode.show = function ( self )
	self:setVisible(true);
	if self.callback then
		self.callback(self.obj, true);
	end
end

CustomNode.hide = function ( self )
	self:setVisible(false);
	if self.callback then
		self.callback(self.obj, false);
	end
end

CustomNode.setPos = function ( self, x, y )
	Node.setPos(self, x, y);
	-- 遮罩图保持覆盖整个根节点
	self.cover:setPos(-x, -y);
end

CustomNode.dtor = function (self)
	self:setVisible(false);
	self:removeAllChildren();
end

