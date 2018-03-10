--region PopuFrameForDingKai.lua
--Author : BillyYang
--Date   : 2015/1/21
--此文件由[BabeLua]插件自动生成



--endregion
local payMethodPopuWnd_dingkai = require(ViewLuaPath.."payMethodPopuWnd_dingkai");

require("MahjongCommon/SCWindow");

PopuFrameForDingKai = class(SCWindow);

PopuFrameForDingKai.ctor = function ( self, product)
    if not product then 
		return;
	end
	self.window = SceneLoader.load(payMethodPopuWnd_dingkai);
	-- ############################################################################ --
	-- SceneLoader.load的结点必须有父节点，否则将直接显示无法被移除
	-- ############################################################################ --
	self:addChild( self.window );
	self:setName("dingkai");

    self.cover:setEventTouch(self,function(self)

	end);
   	
    self.img_win_bg = publ_getItemFromTree(self.window, {"Image1"});
    self:setWindowNode( self.img_win_bg );
	if not self.windowX and not self.windowY then
		self.windowX,self.windowY = self.img_win_bg:getPos();
	end
	self.windowW,self.windowH = self.img_win_bg:getSize();
   
	self.m_product = product;
	local p_amount = self.m_product.pamount;

	publ_getItemFromTree(self.window,{"Image1","content_bg","title_bg", "product_name"}):setText(self.m_product.getname);	
	publ_getItemFromTree(self.window,{"Image1","content_bg","title_bg", "price"}):setText(self.m_product.pamount .. "元");

	publ_getItemFromTree(self.window,{"Image1","content_bg","commonpayBtn"}):setOnClick(self,self.onClickCommonPay);
	publ_getItemFromTree(self.window,{"Image1","content_bg","commonpayBtn2"}):setOnClick(self,self.onClickCommonExChange);

    publ_getItemFromTree(self.window,{"Image1","content_bg","title_bg","qifan_text"}):setText(PlayerManager.getInstance():myself().dingkaiCoin or 0 .. "个");
	

	publ_getItemFromTree(self.window,{"Image1","close"}):setOnClick(self,self.onCloseBtnClick);

	self.product_pic = publ_getItemFromTree(self.view,{"Image1","content_bg","commonpayBtn","product_icon"});

	self.localDir = product.url1;

	if publ_isFileExsit_lua(self.localDir) then -- 图片已下载
        self.product_pic:setFile(self.localDir);
    end
end

PopuFrameForDingKai.onCloseBtnClick = function(self)
    self:hideWnd();
end

PopuFrameForDingKai.dtor = function ( self )
    self:removeAllChildren();
end

PopuFrameForDingKai.onClickCommonPay = function(self)
    if not self.clickCommonObj or not self.clickCommonFunc then 
		return;
	end
	self.clickCommonFunc(self.clickCommonObj);
	self:hideWnd();
end

PopuFrameForDingKai.setOnClickCommonPay = function(self, clickObj, Func)
     self.clickCommonFunc = Func;
     self.clickCommonObj = clickObj;
end

PopuFrameForDingKai.setOnClickCommonExChange = function(self, clickObj, Func)
    self.clickObj = clickObj;
    self.clickFunc = Func;
end
PopuFrameForDingKai.onClickCommonExChange = function(self)
    if not self.clickObj or not self.clickFunc then 
		return;
	end
     
    self.clickFunc(self.clickObj);
    self:hideWnd();
end