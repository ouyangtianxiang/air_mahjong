local payPopuWnd = require(ViewLuaPath.."payPopuWnd");
require("MahjongCommon/SCWindow");

PaymentSelectWindow = class(SCWindow);

PaymentSelectWindow.ctor = function ( self, productInfo,paySelectInfo,root )
	if not productInfo or not paySelectInfo then
		return;
	end
	self.obj = root;
	self.m_productInfo = productInfo;
	self.m_paySelectInfo = paySelectInfo;

	local p_image = {};
	local p_messages = {};

	for i=1,#paySelectInfo do
		-- mahjongPrint(paySelectInfo[i])
		p_image[#p_image + 1 ] = paySelectInfo[i].pimage;
		p_messages[#p_messages + 1] = paySelectInfo[i].ptypename;
	end
 --    self.btnArray = {};
	-- self.curSelectType = -1;
	-- self.obj = _obj;
	-- self.fun = nil;
    self.layout = SceneLoader.load(payPopuWnd);
    self:addChild(self.layout);
    self.bg = publ_getItemFromTree(self.layout, { "bg"});
    self:setWindowNode( self.bg );
    self.goodsNameText = publ_getItemFromTree(self.layout, {"bg","contentBg","productName"});
    self.goodsNameText:setText(productInfo.pname);
    self.moneyText = publ_getItemFromTree(self.layout, {"bg","contentBg","price"});
    self.moneyText:setText( (productInfo.pamount or "").."元");
    self.contentScrollView = publ_getItemFromTree(self.layout, {"bg","contentBg","chooseView"});
    self.contentScrollView:setDirection(kVertical);
    self:addPayBtns(p_image,p_messages);
	-- if GameConstant.iosDeviceType>0 then
	-- 	DebugLog("PaymentSelectWindow");
	-- 	if productInfo.pamount>648 then
	-- 		local button = self.btnArray[4];
	-- 		if button then
	-- 			button:setPickable(falses)
	-- 			button:setTransparency(0.5)
	-- 		end
	-- 	end
	-- 	if not GameConstant.isWechatInstalled then
	-- 		local button = self.btnArray[1];
	-- 		if button then
	-- 			button:setPickable(falses)
	-- 			button:setTransparency(0.5)
	-- 		end
	-- 	end
	-- end
    self.closeBtn = publ_getItemFromTree(self.layout, {"bg","close"});
    self.closeBtn:setOnClick(self, function ( self )
    	self:hideWnd();
    	if self.obj then
    		self.obj.payWnd = nil;
    	end
    end);
    self:showWnd();
end

PaymentSelectWindow.begX = 0;
PaymentSelectWindow.begY = 60;


PaymentSelectWindow.addPayBtns = function ( self, imageArray,messageArray )
	self.contentScrollView:removeAllChildren();
	self.btnArray = {};
	local x, y = PaymentSelectWindow.begX,PaymentSelectWindow.begY;
	local b = false;
	for k = 1,#imageArray do
		local btn = new (CusBtn, imageArray[k],messageArray[k], self.m_productInfo.ptype);
		btn:setCallback(self, function ( self)
			local goodInfo = self.m_productInfo;
			goodInfo.pmode = self.m_paySelectInfo[k].pmode;
			goodInfo.pclientid = self.m_paySelectInfo[k].pclientid;
			PayController:payForGoods(false,goodInfo);
			self:hideWnd();
			if self.obj then
	    		self.obj.payWnd = nil;
	    	end
		end);

		if k < 3 then
			btn:setPos(x, 1);
			y = 1;
		else
			btn:setPos(x,y);
		end
		if GameConstant.iosDeviceType>0 then
			local pmode = self.m_paySelectInfo[k].pmode;
			local productInfo = self.m_productInfo;
			if productInfo.pamount>648 and pmode==99 then
				btn:setPickable(falses)
				btn:setTransparency(0.5)
			end
			if not GameConstant.isWechatInstalled and pmode==463 then
				btn:setPickable(falses)
				btn:setTransparency(0.5)
			end
		end
		self.contentScrollView:addChild(btn);
		if k%2 ~= 0 then
			x = x + 60 + btn.m_width;
		else
			x = PaymentSelectWindow.begX;
			y = y + 30 + btn.m_height;
		end

		-- if k == 1 then
		-- 	y = 10;
		-- end

		table.insert(self.btnArray, btn);
		if not b then
			self.curSelectType = v;
			b = true;
		end
	end
end

PaymentSelectWindow.dtor = function ( self )
	DebugLog("PaymentSelectWindow dtor");
    self:removeAllChildren();
end

CusBtn = class(Node);

CusBtn.ctor = function ( self, image,message, pType )
	self.m_type = pType or 0 --金币为0，博雅币为1
	self.btn = UICreator.createBtn( "payPopu/payBg.png", 0, 0, self, CusBtn.payAction);
	self.btn:setSize(self.btn.m_res.m_width, self.btn.m_res.m_height);
	self:addChild(self.btn);
	self.content = UICreator.createImg( "payPopu/" .. image, 0, 0 );
	self.content:setPos(30,15 );
	self.contentText = UICreator.createText(message .. "支付",self.content.m_width/2 + 10,self.content.m_height/2,self.btn.m_width,30,kAlignCenter,32,204,68,0);
	self.btn:addChild(self.content);

	if self.m_type == 0 then --金币才有赠送
		if GameConstant.iosDeviceType>0 then
		else
			if image == "img_zhifubao.png" or image == "img_weixin.png" then
				self.cornerMark = UICreator.createImg( "payPopu/mark/zhifubao_corner_mark.png",0, 0);
				self.cornerMark:setPos(self.btn.m_res.m_width - self.cornerMark.m_res.m_width,-3);
				self.cornerMark:setAlign( kAlignTopLeft );
				self.btn:addChild( self.cornerMark );
			end
		end
	end

	self.btn:addChild(self.contentText);
	self.btn:setOnClick(self,function(self)
		self:payAction();
	end);
	self:setSize(self.btn.m_width, self.btn.m_height);
end

CusBtn.setBeingSelect = function ( self, bSelect )
	if bSelect then
		self.frame:setVisible(true);
	else
		self.frame:setVisible(false);
	end
end

CusBtn.setCallback = function ( self, obj, fun )
	self.obj = obj;
	self.fun = fun;
end

CusBtn.payAction = function ( self )
	if self.fun then
		self.fun(self.obj, self.m_type);
	end
end

CusBtn.dtor = function ( self )
	self:removeAllChildren();
end
