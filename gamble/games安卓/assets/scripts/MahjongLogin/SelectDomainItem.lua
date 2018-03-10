
SelectDomainItem = class(Node)

SelectDomainItem.ctor = function ( self , data )
	if not data then
		print("data is nil");
		return;
	end
	self.domain = data.domain;
	self.viewRef = data.viewRef;
	print("data is not nil");
	self:setPos(0 , 0);
	self:setSize(1280 , 65);
	DebugLog(self.domain);
	local domainText = new(Text , self.domain , 0 , 0 , nil , nil , 30);
	domainText:setPos(0 , 20);
	self:addChild(domainText);
	local clearBtn =  UICreator.createTextBtn("Common/subViewBtnR.png" , 1000 , 10 , "删 除");
	local w , h  = clearBtn:getSize();
	clearBtn:setPos(1000 , 10);
	clearBtn:setSize(w * 0.8 , h * 0.8);
	self:addChild(clearBtn);
	clearBtn:setOnClick(self , function ( self )
		self.viewRef:removeADomain(self.domain);
	end)
	self:setPickable(true);
	self:setEventTouch(self , function ( self, finger_action )
		if finger_action == kFingerUp then
			self.viewRef:selectADomain(self.domain);
		end
	end);
end

SelectDomainItem.dtor = function ( self )
	self:removeAllChildren();
end


