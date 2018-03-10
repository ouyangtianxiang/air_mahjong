-- HuCardWindow
-- OnlynightZhang
local huTipsPin_map = require("qnPlist/huTipsPin")

require("MahjongRoom/Mahjong/MahjongViewManager");
require("MahjongCommon/NoCoverWindow");

HuCardTipsWindow = class(NoCoverWindow);

HuCardTipsWindow.height = 96;

HuCardTipsWindow.ctor = function( self, data, x, y, parent )

	if not data then
		delete(self);
		return;
	end

	self.initSuccess = true;

	self.x = x;
	self.y = y;
	self.data = data;

	if parent then
		parent:addChild( self );
	else
        if GameConstant.curGameSceneRef and  GameConstant.curGameSceneRef.m_root then
            GameConstant.curGameSceneRef.m_root:addChild(self);
        else
            self:addToRoot();
        end
	end

	self:initView();
end

HuCardTipsWindow.initView = function( self )
	self.imgBg = UICreator.createImg( huTipsPin_map["huCardBG.png"], self.x, self.y, 20, 20, 20, 20 );
	self.imgBg:setSize( 500, self.height );
	self.imgBg:setPos( self.x, self.y );
	self:addChild( self.imgBg );

	self:setWindowNode( self.imgBg );

	self.imgHu = UICreator.createImg( huTipsPin_map["hu.png"], 5, 5 );
	self.m_window:addChild( self.imgHu );

	local w,_ = self.imgHu:getSize();
	local tempData = self.data.cards;
	if tempData then
		for i=0,#tempData-1 do
			local temp = new(HuCardView, tempData[i+1], HuCardView.width*i + w, 0 );
			self.m_window:addChild( temp );
		end
	end

	local width = w + 5 + HuCardView.width * #tempData + 10;
	self.imgBg:setSize( width, self.height );

	self:calXPos();
end

HuCardTipsWindow.showWnd = function( self )
	if self.initSuccess then
		self.super.showWnd( self );
	else
		log( "init error" );
	end
end

HuCardTipsWindow.calXPos = function( self )
	local w,h = self.imgBg:getSize();
	local rightX = self.x + w;

	local x = self.x;

	log( "HuCardTipsWindow.calXPos" );
	log( "rightX == "..rightX );
	local screenWidth = System.getScreenWidth();
	local scale = System.getLayoutScale();
	local scaledWidth = screenWidth / scale;

	if rightX > scaledWidth then
		local deltaX = scaledWidth - rightX - 30;
		x = self.x - math.abs(deltaX);
	end

	self.imgBg:setPos( x, self.y );
end

HuCardTipsWindow.playHideAnim = function( self )
	self:setVisible( false );
	self:onWindowHide();
end

HuCardTipsWindow.playShowAnim = function( self )
	self:setVisible( true );
	self:onWindowShow();
end

HuCardTipsWindow.dtor = function( self )
end

HuCardView = class(Node);

HuCardView.width = 110;

HuCardView.ctor = function( self, data, x, y )
	self.data = data;
	if not data then
		delete(self);
		return;
	end

	self:setSize( self.width, 0 );
	self:setFillParent(false, true);

	self.mahjong = new(Mahjong , getInHandImageFileBySeat(kSeatMine , data.card, MahjongViewManager.getInstance():getMahjongType(kSeatMine)));
	--self.mahjong:setSize(50, 70);
	local  sx = 50 / 82
	local  sy = 70 / 128
	--local  ow,oh =  
	self.mahjong:setScale(sx,sy)
	--self.mahjong.faceImg:setSize(self.mahjong.faceImg.m_res.m_width * sx ,self.mahjong.faceImg.m_res.m_height * sy);
	--self.mahjong.faceImg:setPos((sx - 1)*82 / 2 , (sy - 1)*128 / 2);
	
	self.mahjong:setPos(x + 10, y + 13);
	self.textFan      = UICreator.createText( tostring(data.fans), x + 70, 18, 0, 0, kAlignCenter, 22, 250, 200, 0 );
	self.textFanTips  = UICreator.createText( "番", x + 90, 18, 0, 0, kAlignCenter, 22, 106, 202, 102 );
	self.textLeft     = UICreator.createText( tostring(data.left), x + 70, 53, 0, 0, kAlignCenter, 22, 250, 200, 0 );
	self.textLeftTips = UICreator.createText( "张", x + 90, 53, 0, 0, kAlignCenter, 22, 106, 202, 102 );

	self:addChild( self.mahjong );
	self:addChild( self.textFan );
	self:addChild( self.textFanTips );
	self:addChild( self.textLeft );
	self:addChild( self.textLeftTips );
end