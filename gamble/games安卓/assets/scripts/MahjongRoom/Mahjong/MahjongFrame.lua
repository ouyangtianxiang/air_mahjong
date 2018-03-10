
local kDiscardListNum = 3

MahjongFrame = class();

kDisCardHangNum = 12;

MineInHandCard_W  = 88 * GameConstant.bottomMahjongScale;
MineInHandCard_H  = 128* GameConstant.bottomMahjongScale;
MineBlockCard_W   = 88 * GameConstant.bottomMahjongScale;
MineBlockCard_H   = 128 * GameConstant.bottomMahjongScale;
MineDiscardCard_W = 38 * GameConstant.discardMahjongScale--43
MineDiscardCard_H = 58 * GameConstant.discardMahjongScale--63

TopInHandCard_W  = 44*GameConstant.topMahjongScale
TopInHandCard_H  = 72*GameConstant.topMahjongScale
TopBlockCard_W	 = 44*GameConstant.topMahjongScale
TopBlockCard_H	 = 40*GameConstant.topMahjongScale
TopDiscardCard_W = 38*GameConstant.discardMahjongScale;
TopDiscardCard_H = 58*GameConstant.discardMahjongScale;

RightInHandCard_W  = 26*GameConstant.rightMahjongScale
RightInHandCard_H  = 56*GameConstant.rightMahjongScale
RightBlockCard_W   = 44*GameConstant.rightMahjongScale
RightBlockCard_H   = 40*GameConstant.rightMahjongScale
RightDiscardCard_W = 44*GameConstant.discardMahjongScale;
RightDiscardCard_H = 40*GameConstant.discardMahjongScale;

LeftInHandCard_W  = 26*GameConstant.leftMahjongScale
LeftInHandCard_H  = 56*GameConstant.leftMahjongScale
LeftBlockCard_W   = 44*GameConstant.leftMahjongScale
LeftBlockCard_H   = 40*GameConstant.leftMahjongScale
LeftDiscardCard_W = 44*GameConstant.discardMahjongScale;
LeftDiscardCard_H = 40*GameConstant.discardMahjongScale;



--------------------------------------------------------
MahjongFrame.sMineX = 0;
MahjongFrame.sMineY = 0;

MahjongFrame.ctor = function (self, frameCount)
	self.layout = {};
	self.layout[kSeatMine] 	= new (BottomMahjongLayout, frameCount or 14);
	self.layout[kSeatRight] = new (RightMahjongLayout, frameCount or 14);
	self.layout[kSeatTop] 	= new (TopMahjongLayout, frameCount or 14);
	self.layout[kSeatLeft] 	= new (LeftMahjongLayout, frameCount or 14);
	MahjongFrame.sMineX, MahjongFrame.sMineY = self.layout[kSeatMine]:get14thPos();
end

MahjongFrame.dtor = function (self)
	delete(self.mineLayout);
end

MahjongFrame.getFrameCount = function (self)
	return self.layout[kSeatMine].mjNum;
end

-- 取得抓牌的位置 , 和胡的牌公用一个地址
MahjongFrame.getCatchFrame = function (self ,seat, index , blockCount)
	
	return self.layout[seat]:get14thPos(index , blockCount);
end

-- 取得某个位置的手牌坐标
MahjongFrame.getInhandFrame = function (self , seat , index , blockCount)
	
	return self.layout[seat]:getPosByIndex(index, blockCount);
end

-- 取得当前打出的牌的位置
MahjongFrame.getDiscardFrame = function (self , seat , index)
	return self.layout[seat]:getDiscardPos(index);

end

-- 取得当前碰杠牌的位置
MahjongFrame.getBlockFrame = function (self , seat , index)
	
	return self.layout[seat]:getBlockPosByIndex(index);
end

-- 取得胡牌手牌的坐标
MahjongFrame.getHuInHandCardFrame = function (self , seat , index ,blockCount)
	
	return self.layout[seat]:getHuPosByIndex(index, blockCount);
end

MahjongFrame.getHuCardFrame = function (self , seat , handCardsNum)
	return self.layout[seat]:getHuPos(handCardsNum);
end

MahjongFrame.getPos = function ( self, seat)
	-- body
	return self.layout[seat]:getPos();
end
MahjongFrame.getSize = function ( self, seat)
	-- body
	return self.layout[seat]:getSize();
end
MahjongFrame.getMineHandCardTopLine = function ( self )
	--return MineInHandCard_Y;
	return self.layout[kSeatMine].y;
end

MahjongFrame.getBigDiscardPos = function ( self, seat)
	-- body
	return self.layout[seat]:getBigDiscardPos();
end

MahjongFrame.getAvatarPos = function ( self, seat )
	-- body
	return self.layout[seat]:getAvatarPos();
end
MahjongFrame.getAvatarSize = function ( self, seat )
	-- body
	return self.layout[seat]:getAvatarSize();
end
MahjongFrame.getChatBtnPos = function ( self )
	-- body
	return self.layout[kSeatMine]:getChatBtnPos();
end

MahjongFrame.getBankPos = function ( self, seat )
	-- body
	return self.layout[seat]:getBankPos();
end

MahjongFrame.getMatchScorePos = function ( self, seat )
	-- body
	return self.layout[seat]:getMatchScorePos();
end

MahjongFrame.getSelectPos = function ( self, seat )
	-- body
	return self.layout[seat]:getSelectPos();
end

MahjongFrame.getDiscardSize = function ( self, seat )
	-- body
	return self.layout[seat]:getDiscardSize();
end

MahjongFrame.getDiscardFrameSize = function ( self , seat )
	return self:getDiscardSize(seat);
end

MahjongFrame.getHandCardsSize = function ( self , seat )
	return self.layout[seat]:getHandCardsSize();
end

MahjongFrame.getShowDiscardPos = function ( self , seat ,index )
	return self.layout[seat]:getShowDiscardPos(index);
end

function MahjongFrame.getDiscardNodeSize( self, seat)
 	return self.layout[seat]:getDiscardNodeSize();
end

function MahjongFrame.getDiscardNodePos( self, seat)
 	return self.layout[seat]:getDiscardNodePos();
end
--[[
function MahjongFrame.addAPengOrGang( self, seat )
	self.layout[seat]:addAPengOrGang()
end
]]

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--													mahjong layout base class												    --
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

MahjongLayout = class();


MahjongLayout.ctor = function ( self, count )
	-- body

	self.mjNum	= count; --麻将总个数
	self.mjW  	= 0; --麻将宽度（单个）-- 去掉宽度为3空白像素
	self.mjH  	= 0; --麻将高度 (单个)		
	self.blockW = 0; --碰杠牌宽度（单个）--去掉宽度为3空白像素
	self.dist13thTo14th 	= 0; --13th麻将与14th麻将的距离
	self.distToEdge		= 0; --麻将牌面到边界的距离
	self.handCardsW		= 0;
	self.handCardsH		= 0;

	self.mjBlockNum     = 0;--麻将杠的个数

	self.x		= 0; -- 起始坐标(水平居中)
	self.y		= 0; -- 起始坐标(垂直方向)
	self.w 		= 0; -- 总宽度
	self.h 		= 0; -- 总高度

	self.mj14thX= 0; --14th麻将的起始坐标(水平方向)
	self.mj14thY= 0; -- --14th麻将的起始坐标(垂直方向)

	self.discardX = 0;--弃牌起始坐标(X)
	self.discardY = 0;--弃牌起始坐标(y)
	self.discardW = 0;--弃牌宽度
	self.discardH = 0;--弃牌高度
	self.discardPerRow = 0;--弃牌第行12个

	self.bigDiscardW = 74; --大弃牌宽度 
	self.bigDiscardH = 112; --大弃牌高度

	self.avatarW	= 80; -- 头像宽度
	self.avatarH	= 80; -- 头像高度
	self.avatarX	= 0 ;
	self.avatarY	= 0;

	self.bankW		= 49; -- 庄家标志
	self.bankH		= 50;
	self.bankX		= 0;
	self.bankY		= 0;

	self.matchScoreX=0; --比赛积分
	self.matchScoreY=0; --比赛积分
	self.matchScoreW=90; --比赛积分
	self.matchScoreH=30; --比赛积分


	self.selectW	= 44; -- 选择标志
	self.selectH	= 44;
	self.selectX	= 0; -- 选择标志
	self.selectY	= 0;

end

MahjongLayout.dtor = function ( self )
	-- body
end

MahjongLayout.getPos = function ( self )
	-- body
	return self.x, self.y;
end
MahjongLayout.getSize = function ( self )
	-- body
	return self.w, self.h;
end

MahjongLayout.get14thPos = function ( self ,mjNum, blockNum)
	-- body
	return self.mj14thX, self.mj14thY;
end

MahjongLayout.getPosByIndex = function ( self, index, blockNum )
	-- body
	return 0, 0;

end

MahjongLayout.getHuPosByIndex = function ( self, index, blockNum )
	return self:getPosByIndex(index,blockNum);
end

MahjongLayout.getHuPos = function ( self )
	return self:get14thPos(self.mjNum - 1,0);
end


MahjongLayout.getBlockPosByIndex = function ( self, blockIndex )
	-- body
	return 0, 0;

end

MahjongLayout.getDiscardPos = function ( self, index )
	-- body
	return 0, 0;

end

MahjongLayout.getBigDiscardPos = function ( self )
	-- body
	return 0,0;
end

MahjongLayout.getAvatarPos = function ( self)
	-- body
	return self.avatarX, self.avatarY;
end
MahjongLayout.getAvatarSize = function ( self)
	-- body
	return self.avatarW, self.avatarH;
end

MahjongLayout.getBankPos = function ( self)
	-- body
	return self.bankX, self.bankY;
end

MahjongLayout.getMatchScorePos = function ( self)
	-- body
	return self.matchScoreX, self.matchScoreY;
end

MahjongLayout.getSelectPos = function ( self)
	-- body

	return self.selectX, self.selectY;
end

MahjongLayout.getDiscardSize = function ( self )
	
	return self.discardW, self.discardH;
end

MahjongLayout.getHandCardsSize = function ( self )
	return self.handCardsW,self.handCardsH;
end

MahjongLayout.getShowDiscardPos = function(self)
	return 0 , 0;
end

--UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
MahjongLayout.showDebugText = function ( self,str )
--[[
	if DEBUGMODE == 1 then
		local text = UICreator.createText(str,self.x,self.y)
		text:addToRoot()
		text:setLevel(1000)
	end
	]]
end

MahjongLayout.getBlockSum = function ( self )
	return self.blockH * 3 - self.dYBlockCovered * 2 - 3
end
--[[
MahjongLayout.addAPengOrGang = function ( self )
	self.mjBlockNum = self.mjBlockNum + 1
end
]]
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--													bottom mahjong layout class												    --
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

BottomMahjongLayout = class(MahjongLayout, true);

BottomMahjongLayout.ctor = function ( self, count )
	-- body
	self.mjW  	= MineInHandCard_W-5; --; --麻将宽度（单个）
	self.mjH  	= MineInHandCard_H; --麻将高度 (单个)		
	self.blockW = MineBlockCard_W-5; --碰杠牌宽度（单个
	self.dist13thTo14th = 30; --13th麻将与14th麻将的距离(水平方向)
	self.distToEdge		= 10 * System.getScreenHeight() / (System.getLayoutHeight() * System.getLayoutScale() ) + 2; --麻将牌面到边界的距离 (垂直方向)

	self.w 		= self.mjW * self.mjNum + self.dist13thTo14th;
	self.h 		= self.mjH;

	self.handCardsW = self.w;
	self.handCardsH = self.h;

	self.x		= (System.getScreenWidth() / System.getLayoutScale() - self.w) / 2; -- 起始坐标(水平居中)
	self.y		= System.getScreenHeight() / System.getLayoutScale() - self.h - self.distToEdge; -- 起始坐标(垂直方向)

	self.mj14thX= self.x + self.w - self.mjW; --14th麻将的起始坐标(水平方向)
	self.mj14thY= self.y; -- --14th麻将的起始坐标(垂直方向)

	self.discardW = MineDiscardCard_W;--弃牌宽度
	self.discardH = MineDiscardCard_H;--弃牌高度
	self.discdrdCovered = 16*GameConstant.discardMahjongScale; -- 堆叠弃牌时产生的重叠部分的高度(垂直方向)
	self.discardPerRow = 12;--弃牌第行12个

	self.discardX = (System.getScreenWidth() / System.getLayoutScale() - self.discardW * self.discardPerRow) / 2;--(水平居中)
	self.discardY = self.y - self.discardH - 20; --弃牌与主牌的间隔为35 (垂直方向)

	self.avatarX	= 160 * System.getScreenWidth() / (System.getLayoutWidth() * System.getLayoutScale() ) - self.avatarW - 40; -- 偏离主牌起始位置70
	self.avatarY	= self.y - self.avatarH - 20 - 35 -10;--35是头像下面金币框的高度

	--将会添加到头像的节点下
	self.bankX		= self.avatarW - self.bankW + 20 - 64; -- 庄家标志坐标
	self.bankY		= -20;

	self.selectX	= self.avatarX + self.avatarW + 6; -- 选择标志坐标
	self.selectY	= self.avatarY + self.avatarH - self.selectH + 3; --8阴影

	self.matchScoreX = (self.avatarW - self.matchScoreW) / 2;
	self.matchScoreY = - self.matchScoreH - 8;

	self:showDebugText("bottom")
end

BottomMahjongLayout.dtor = function ( self )
	-- body
end

BottomMahjongLayout.getPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x + blockNum * 3 * self.blockW + (index - 1) *  self.mjW;
	local y = self.y;
	return x, y;

end

BottomMahjongLayout.getBlockPosByIndex = function ( self, blockIndex )
	-- body
	local x = self.x + (blockIndex - 1) * 3 * (self.blockW + 1) - 12; --12是因为碰了之后，点击其他牌时会左右移动6个像素
	local y = self.y;
	return x, y;

end


BottomMahjongLayout.getDiscardPos = function ( self, index )
	return self.discardX + (self.discardW) * ((index -1)% self.discardPerRow ) + 0.5 , 
			self.discardY - (self.discardH - self.discdrdCovered) * math.floor((index -1)/ self.discardPerRow);
end

BottomMahjongLayout.getBigDiscardPos = function ( self )
	-- body
	-- Y方向底部与弃牌第一行对齐,不然因为level，会被覆盖
	return (System.getScreenWidth() / System.getLayoutScale() - self.bigDiscardW) / 2 , self.discardY - self.bigDiscardH;
end

BottomMahjongLayout.getChatBtnPos = function ( self )
	--聊天按钮的尺寸为64*65
	--定缺大小为44x44
	--根据头像位置确定坐标
	return self.avatarX + self.avatarW + 8 + 44 + 8 + 25, self.avatarY + self.avatarH - 65 + 8 + 30;--8为头像边框
end

function BottomMahjongLayout.getDiscardNodeSize(self)
	return self.discardPerRow * self.discardW , (self.discardH - self.discdrdCovered) * (kDiscardListNum - 1) + self.discardH;
end

function BottomMahjongLayout.getDiscardNodePos(self)
	local x , y = self:getDiscardPos( (kDiscardListNum - 1) * self.discardPerRow + 1);
	local w , h = self:getDiscardNodeSize();
	return x , y;
end

function BottomMahjongLayout.getShowDiscardPos( self, index )
	return ((index - 1) % self.discardPerRow) * self.discardW ,
			(self.discardH - self.discdrdCovered) * (kDiscardListNum - 1 - math.floor((index - 1) / self.discardPerRow));
end

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--													top mahjong layout class												    --
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

TopMahjongLayout = class(MahjongLayout, true);

TopMahjongLayout.ctor = function ( self, count )
	-- body

	self.mjW  	= TopInHandCard_W; --麻将宽度（单个）
	self.mjH  	= TopInHandCard_H; --麻将高度 (单个)		
	self.blockW = TopBlockCard_W; --碰杠牌宽度（单个）
	self.dist13thTo14th = 15; --13th麻将与14th麻将的距离(水平方向)
	self.distToEdge		= 30 * System.getScreenHeight() / (System.getLayoutHeight() * System.getLayoutScale() ) + 20 ; --麻将牌面到边界的距离 (垂直方向)

	self.w 		= self.mjW* self.mjNum + self.dist13thTo14th; -- 总宽度
	self.h 		= self.mjH;

	self.handCardsW = self.w;
	self.handCardsH = self.h;

	self.x		= (System.getScreenWidth() / System.getLayoutScale() - self.w) * 3 / 5 + self.w + 40; -- 起始坐标(3:5)
	self.y		= self.distToEdge; -- 起始坐标(垂直方向)
	self.mj14thX= self.x - self.w; --14th麻将的起始坐标(水平方向)
	self.mj14thY= self.y; --14th麻将的起始坐标(垂直方向)

	self.discardW = TopDiscardCard_W;--弃牌宽度
	self.discardH = TopDiscardCard_H;--弃牌高度
	self.discdrdCovered = 16*GameConstant.discardMahjongScale; -- 堆叠弃牌时产生的重叠部分的高度(垂直方向)
	self.discardPerRow = 12;--弃牌第行12个

	self.discardX = self.x - (self.w - self.discardW * self.discardPerRow) / 2 - 40;--(水平居中)
	self.discardY = self.y + self.mjH + 10; --弃牌与主牌的间隔为10 (垂直方向)

	self.avatarX = self.x - self.w - self.avatarW - 60 +10--- 90 ; -- 40表示与主牌的距离
	self.avatarY = self.y + self.mjH - self.avatarH -10 + 10---20;--(self.avatarH - self.mjH)/2; -- 表示与主牌的距离  

	--将会添加到头像的节点下
	self.bankX		= self.avatarW - self.bankW + 20 - 64; -- 庄家标志坐标
	self.bankY		= -20;

	self.selectX	= self.avatarX + self.avatarW + 5; -- 选择标志坐标
	self.selectY	= self.avatarY + self.avatarH - self.selectH + 3; --8阴影

	self.matchScoreX = (self.avatarW - self.matchScoreW) / 2;
	self.matchScoreY = self.avatarH + 8;

	self:showDebugText("top")
end

TopMahjongLayout.dtor = function ( self )
	-- body
end

TopMahjongLayout.getBlockSum = function ( self )
	return self.blockW * 3 + 2 -- self.dYBlockCovered * 2 - 3
end

TopMahjongLayout.getPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x - blockNum * (self:getBlockSum()) - index *  self.mjW - 5;--5为碰牌与手牌的距离
	local y = self.y;
	return x, y;

end

TopMahjongLayout.getBlockPosByIndex = function ( self, blockIndex )
	-- body
	local x = self.x - (blockIndex-1) * (self:getBlockSum())-- - self.blockW;
	local y = self.y;
	return x, y;
end

TopMahjongLayout.getDiscardPos = function ( self, index )
	-- body
	return self.discardX - (self.discardW) * ((index -1)% self.discardPerRow ) - self.discardW, self.discardY + (self.discardH - self.discdrdCovered) * math.floor((index -1)/ self.discardPerRow);
end

TopMahjongLayout.getBigDiscardPos = function ( self )
	-- body
	--Y方向顶部与弃牌第一行底部对齐,不然因为level，会被覆盖
	return (System.getScreenWidth() / System.getLayoutScale() - self.bigDiscardW) / 2 , self.discardY ;
end

function TopMahjongLayout.getDiscardNodeSize(self)
	return self.discardPerRow * self.discardW , (self.discardH - self.discdrdCovered) * (kDiscardListNum - 1) + self.discardH;
end

function TopMahjongLayout.getDiscardNodePos(self)
	local x , y = self:getDiscardPos(kDisCardHangNum);
	local w , h = self:getDiscardNodeSize();
	return x , y;
end

function TopMahjongLayout.getShowDiscardPos( self, index )
	return (kDisCardHangNum - 1 - ((index - 1) % self.discardPerRow)) * self.discardW ,
			(self.discardH - self.discdrdCovered) * (math.floor((index - 1) / self.discardPerRow));
end

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--													right mahjong layout class												    --
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

RightMahjongLayout = class(MahjongLayout, true);

RightMahjongLayout.ctor = function ( self, count )
	-- body

	self.mjW  	= RightInHandCard_W; --麻将宽度（单个）
	self.mjH  	= RightInHandCard_H; --麻将高度 (单个)		
	self.blockW = RightBlockCard_W; --碰杠牌宽度（单个）
	self.blockH = RightBlockCard_H; --碰杠牌高度（单个）
	self.dist13thTo14th = 0; --13th麻将与14th麻将的距离(垂直方向)
	self.distToEdge		= 160 * System.getScreenWidth() / (System.getLayoutWidth() * System.getLayoutScale() ); --麻将牌面到边界的距离 (水平方向)

	self.dYNonCovered 	= 18*GameConstant.rightMahjongScale;--单个麻将非覆盖部分(垂直方向)
	self.dYBlockCovered = 16*GameConstant.rightMahjongScale; --单个碰杠牌覆盖部分(垂直方向)


	local mahjongLen1 = self.dYNonCovered * (self.mjNum - 2)  + self.mjH + self.dist13thTo14th + self.mjH;--14总长度
	local mahjongLen2 = (self.blockH - self.dYBlockCovered)* 3 * 4  + (self.mjH - self.dYBlockCovered)+ self.dist13thTo14th + self.mjH;--碰杠牌

	self.w = self.mjW;
	self.h = math.max(mahjongLen1,mahjongLen2); -- 最长高度

	self.handCardsW = self.w;
	self.handCardsH = mahjongLen1;


	self.x		= System.getScreenWidth() / System.getLayoutScale() - self.distToEdge - self.mjW; -- 起始坐标(水平方向)
	self.y		= (System.getScreenHeight() / System.getLayoutScale() - self.h)   * 40 / (36+84) + self.h +5 --- 20; -- 按照上下麻将高度比重(36:84)
	self.mj14thX= self.x; --14th麻将的起始坐标(水平方向)
	self.mj14thY= self.y - self.h; --14th麻将的起始坐标(垂直方向)


	self.discardW = RightDiscardCard_W;--弃牌宽度
	self.discardH = RightDiscardCard_H;--弃牌高度
	self.discdrdCovered = 14*GameConstant.discardMahjongScale--17*GameConstant.discardMahjongScale; -- 堆叠弃牌时产生的重叠部分的高度(垂直方向)
	self.discardPerRow = 12;--弃牌第行12个

	self.discardX = self.x - self.mjW - 10;--弃牌与主牌的间隔为10 (水平方向)
	self.discardY = self.y-25 - (mahjongLen1 - self.discardH - (self.discardH - self.discdrdCovered) * (self.discardPerRow - 1))/2;--垂直居中


	self.avatarX = self.x + self.mjW + 40 -10;
	self.avatarY = self.y-25 - (mahjongLen1 - self.avatarH )/2 - self.avatarH; -- 5 表示与主牌的距离

	self.selectX	= self.avatarX ; -- 选择标志坐标
	self.selectY	= self.avatarY - self.selectH - 5;

	--将会添加到头像的节点下
	self.bankX		= self.avatarW - self.bankW + 20 --- 64; -- 庄家标志坐标
	self.bankY		= -20;

	self.matchScoreX = (self.avatarW - self.matchScoreW) / 2;
	self.matchScoreY = self.avatarH + 8;

	self:showDebugText("right")
end

RightMahjongLayout.dtor = function ( self )
	-- body
end

--+blockNum*10
RightMahjongLayout.getPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x ;
	local blockSum = self:getBlockSum() 
	local handSum  = self.mjH + self.dYNonCovered * (index - 1)-- + self.mjH 
	local y = self.y - blockSum * blockNum - handSum

	return x, y;
end

RightMahjongLayout.getBlockPosByIndex = function ( self, blockIndex )
	-- body

	local x = self.x - (self.blockW - self.mjW - 1); -- 1个透明像素
	local y = self.y - (self:getBlockSum()) * blockIndex;

	return x, y;
end

RightMahjongLayout.getHuPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x - (self.blockW - self.mjW - 1); -- 1个透明像素
	local blockSum = self:getBlockSum()
	local huSum    = self.blockH + (RightBlockCard_H - self.dYBlockCovered) * (index - 1)
	local y = self.y - blockSum * blockNum - huSum --(self.blockH - self.dYBlockCovered+5) * (3 * blockNum + index) - self.dYBlockCovered;
	return x, y;
end

RightMahjongLayout.getHuPos = function ( self,handCardsNum )
	handCardsNum = handCardsNum or 0
	local blockNum = math.floor((self.mjNum - handCardsNum)/3)
	local x, y = self:getHuPosByIndex(handCardsNum,blockNum);
	return x, y - self.dYBlockCovered - self.dist13thTo14th;
end

RightMahjongLayout.get14thPos = function ( self ,mjNum, blockNum)
	-- body
	if not blockNum or not mjNum then 
		return self.mj14thX, self.mj14thY;
	end

	self.mj14thX, self.mj14thY = self:getPosByIndex(mjNum, blockNum);
	self.mj14thY = self.mj14thY - self.mjH - self.dist13thTo14th;
	return self.mj14thX, self.mj14thY;
end


RightMahjongLayout.getDiscardPos = function ( self, index )
	-- body
	return self.discardX - self.discardW * math.floor((index -1)/ self.discardPerRow) - self.discardW , self.discardY - (self.discardH - self.discdrdCovered)* ((index -1)% self.discardPerRow ) - self.discardH;
end

RightMahjongLayout.getBigDiscardPos = function ( self )
	-- body
	--Y方向顶部与弃牌第一行底部对齐,不然因为level，会被覆盖
	return self.discardX - self.bigDiscardW - self.discardW, self.y - self.h + (self.h - self.bigDiscardH) / 2;
end

function RightMahjongLayout.getDiscardNodeSize(self)
	return self.discardW * kDiscardListNum , (self.discardPerRow - 1) * (self.discardH - self.discdrdCovered) + self.discardH;
end

function RightMahjongLayout.getDiscardNodePos(self)
	local x , y = self:getDiscardPos(kDiscardListNum * self.discardPerRow);
	local w , h = self:getDiscardNodeSize();
	return x , y;
end

function RightMahjongLayout.getShowDiscardPos( self, index )
	return (kDiscardListNum - 1 - (math.floor((index - 1) / self.discardPerRow))) * self.discardW,
			(self.discardPerRow - 1 - ((index - 1) % self.discardPerRow)) * (self.discardH - self.discdrdCovered);
end

----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
--													left mahjong layout class												    --
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

LeftMahjongLayout = class(MahjongLayout, true);

LeftMahjongLayout.ctor = function ( self, count )
	-- body

	self.mjW  	= LeftInHandCard_W; --麻将宽度（单个）
	self.mjH  	= LeftInHandCard_H; --麻将高度 (单个)	
	self.blockW = LeftBlockCard_W; --碰杠牌宽度（单个）
	self.blockH = LeftBlockCard_H; --碰杠牌高度（单个）
	self.dist13thTo14th = 5; --13th麻将与14th麻将的距离(垂直方向)
	self.distToEdge		= 160 * System.getScreenWidth() / (System.getLayoutWidth() * System.getLayoutScale() ); --麻将牌面到边界的距离 (水平方向)

	self.dYNonCovered 	= 18*GameConstant.leftMahjongScale;--单个麻将非覆盖部分(垂直方向)
	self.dYBlockCovered = 16*GameConstant.leftMahjongScale; --单个碰杠牌覆盖部分(垂直方向)

	local mahjongLen1 = self.dYNonCovered * (self.mjNum - 2)  + self.mjH + self.dist13thTo14th + self.mjH;--14总长度
	local mahjongLen2 = (self.blockH - self.dYBlockCovered)* 3 * 4  + (self.mjH - self.dYBlockCovered)+ self.dist13thTo14th + self.mjH;--碰杠牌

	self.w 			= self.mjW;
	self.h = math.max(mahjongLen1,mahjongLen2);

	self.handCardsW = self.w;
	self.handCardsH = mahjongLen1;

	self.x		= self.distToEdge ; -- 起始坐标(水平方向)
	self.y		= (System.getScreenHeight() / System.getLayoutScale() - self.h)  * (count == 14 and 40 or 50) / (36+84) - 10;--40 / (36+84); -- 按照上下麻将高度比重(36:84)

	self.mj14thX= 0; --坐标需要动态计算
	self.mj14thY= 0;

	self.discardW = LeftDiscardCard_W;--弃牌宽度
	self.discardH = LeftDiscardCard_H;--弃牌高度
	self.discdrdCovered = 14*GameConstant.discardMahjongScale--17*GameConstant.discardMahjongScale; -- 堆叠弃牌时产生的重叠部分的高度(垂直方向)
	self.discardPerRow = 12;--弃牌第行12个

	self.discardX = self.x + self.blockW + 10;--弃牌与主牌的间隔为10 (水平方向)
	self.discardY = self.y + (mahjongLen1 - self.discardH - (self.discardH - self.discdrdCovered) * (self.discardPerRow - 1))/2 + 30;--垂直居中

	self.avatarX = self.x - self.avatarW - 40;
	self.avatarY = self.y + (mahjongLen1 - self.avatarH )/2 +5+40; -- 5 表示与主牌的距离 --因为与任备重叠，故下调25

	if MatchRoomScene_instance then 
		self.avatarY = self.avatarY - 10
	end 

	self.selectX	= self.avatarX ; -- 选择标志坐标
	self.selectY	= self.avatarY - self.selectH - 5;

	--将会添加到头像的节点下
	self.bankX		= self.avatarW - self.bankW + 20 --- 64; -- 庄家标志坐标
	self.bankY		= -20;

	self.matchScoreX = (self.avatarW - self.matchScoreW) / 2;
	self.matchScoreY = self.avatarH + 8;

	self:showDebugText("left")
end

LeftMahjongLayout.dtor = function ( self )
	-- body
end


LeftMahjongLayout.getPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x;

	local blockSum = self:getBlockSum()
	local handSum  = self.dYNonCovered * (index - 1)-- + self.mjH 
	-- local y = self.y + (self.blockH - self.dYBlockCovered) * 3 * blockNum  + self.dYNonCovered * (index - 1) - self.dYBlockCovered * (blockNum > 0 and 1 or 0);
	local y = self.y + blockSum * blockNum + handSum
	--(self.blockH - self.dYBlockCovered) * 3 * blockNum  + self.dYNonCovered * (index - 1) - self.dYBlockCovered * (blockNum > 0 and 1 or 0) + (self.mjH - self.blockH + 2);
	return x, y;
end

LeftMahjongLayout.getHuPosByIndex = function ( self, index, blockNum )
	-- body
	local x = self.x;
	local blockSum = self:getBlockSum()
	local huSum    = (LeftBlockCard_H - self.dYBlockCovered) * (index - 1)
	local y = self.y + blockSum * blockNum + huSum --(self.blockH - self.dYBlockCovered+5) * (3 * blockNum + index-1);
	return x, y;
end

LeftMahjongLayout.getHuPos = function ( self,handCardsNum )
	handCardsNum = handCardsNum or 0
	local blockNum = math.floor((self.mjNum - handCardsNum)/3)
	local x, y = self:getHuPosByIndex(handCardsNum,blockNum);
	return x, y + self.dYBlockCovered + self.dist13thTo14th;
end

LeftMahjongLayout.getBlockPosByIndex = function ( self, blockIndex )
	-- body

	local x = self.x;
	local y = self.y + (self:getBlockSum())*(blockIndex-1);
	
	return x, y;

end

LeftMahjongLayout.get14thPos = function ( self ,mjNum, blockNum)
	-- body
	if not blockNum or not mjNum then 
		return self.mj14thX, self.mj14thY;
	end
	self.mj14thX, self.mj14thY = self:getPosByIndex(mjNum, blockNum);

	self.mj14thY = self.mj14thY + self.mjH + self.dist13thTo14th;
	return self.mj14thX, self.mj14thY;
end

LeftMahjongLayout.getDiscardPos = function ( self, index )
	-- body
	return self.discardX + self.discardW * math.floor((index -1)/ self.discardPerRow), self.discardY + (self.discardH - self.discdrdCovered)* ((index -1)% self.discardPerRow );
end

LeftMahjongLayout.getBigDiscardPos = function ( self )
	-- body
	--Y方向顶部与弃牌第一行底部对齐,不然因为level，会被覆盖
	return self.discardX + self.discardW, self.y + ( self.h - self.bigDiscardH) / 2;
end

function LeftMahjongLayout.getDiscardNodeSize(self)
	return self.discardW * kDiscardListNum , (self.discardPerRow - 1) * (self.discardH - self.discdrdCovered) + self.discardH;
end

function LeftMahjongLayout.getDiscardNodePos(self)
	local x , y = self:getDiscardPos(1);
	local w , h = self:getDiscardNodeSize();
	return x , y;
end

function LeftMahjongLayout.getShowDiscardPos( self, index )
	return (math.floor((index - 1) / self.discardPerRow)) * self.discardW,
			((index - 1) % self.discardPerRow) * (self.discardH - self.discdrdCovered);
end
