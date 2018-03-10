
require("MahjongRoom/Mahjong/MahjongViewManager");
local TeachPin_map = require("qnPlist/TeachPin")



Operation = class(Node);
Operation.ROOT_DIR = "Room/operator/";


-- Operation.selectPeng = 1;
-- Operation.selectGang = 2;
-- Operation.selectHu = 3;
-- Operation.selectCancel = 4;

--在RoomScene将会初始化(动态计算)
Operation.sX 	 = 0; --起始坐标(X)
Operation.sY 	 = 0; --起始坐标(Y)
Operation.sW = 0; --宽度
Operation.sH = 80; -- 固定坐标

local PengGangJianJu = 242;
local HuGuoJianJu = 170;

Operation.ctor = function (self , scene)
	self.scene = scene;
end

Operation.dtor = function (self)
	self:removeAllChildren();
end

Operation.hideOperation = function (self)
	self:removeAllChildren();
	self:setVisible(false);
	TeachManager.getInstance():hide();
end

Operation.showOperation = function (self , data)

	if not data or #data < 1 then
		return;
	end

	local isQiangGang = false;
	local isHu 		  = false;
	local isMingGang  = false;
	local isAnGang 	  = false;
	
	local mjView = MahjongViewManager.getInstance();

	-- local cancel = {}; -- 加入取消
	-- cancel.card = 0;
	-- cancel.operatype = 0;
	-- table.insert(data , cancel);

	local gapX = 10;--两两之间的空隙
	local gapY = 15;

	local row = math.floor((#data + 2)/ 3);

	local startIdx 	= 1;
	local endIdx 	= 0;

	for i = 1, row do

		local col = (1 == i) and ( (#data - 3 * (row-1)) % 4 ) or 3;

		local opTotalWidth = 0;
		local opTotalHeight= 0;

		endIdx = startIdx + col - 1;

		--计算总宽度
		for j = startIdx, endIdx do
			local w, h = Operation:getOperationSize(data[j].operatype);
			opTotalWidth = opTotalWidth + w;
			opTotalHeight= math.max(opTotalHeight, h);
		end

		opTotalWidth = opTotalWidth + (endIdx - startIdx) * gapX;
		--创建操作
		local x = Operation.sX + (Operation.sW - opTotalWidth)/2;
		local y = Operation.sY - (row - i + 1) * (opTotalHeight + gapY);
		
		for j = startIdx , endIdx do

			local w = Operation:getOperationSize(data[j].operatype);
			
			local image = new(Button , self:getOperationImage(data[j].operatype));

			if operatorValueHasPeng(data[j].operatype) or operatorValueHasGang(data[j].operatype) then
				local tnode = mjView:operatPengGangMahjongView(data[j].card,data[j].operatype);
				tnode:setPickable(false);
				image:addChild(tnode);
			end

			--新手引导
			isQiangGang = isQiangGang or hu_qiangGang(data[j].operatype);
			isHu		= isHu or operatorValueHasHu(data[j].operatype);
			isAnGang 	= isAnGang or an_gang(data[j].operatype);
			isMingGang 	= isMingGang or peng_gang(data[j].operatype) or bu_gang(data[j].operatype);

			if operatorValueHasGuo(data[j].operatype) then
				data[j].operatype = 0;
			end
			--回调
			image:setOnClick(self , function (self) self:clickOperator(data[j].operatype , data[j].card); end);
			--设置坐标
			--if operatorValueHasHu(data[j].operatype) then 
			--	image:setPos(x, y-50);
			--else 
				image:setPos(x, y);
			--end 
			

			self:addChild(image);

			x = x + w + gapX;
		end

		startIdx = startIdx + col;

	end

	self:setVisible(true);

	if isQiangGang then
		TeachManager.getInstance():show(TeachManager.QIANG_GANG_HU_TIP);
	elseif isHu then
		TeachManager.getInstance():show(TeachManager.ZI_MO_TIP);
	elseif isAnGang then
		TeachManager.getInstance():show(TeachManager.AN_GANG_TIP);
	elseif isMingGang then
		TeachManager.getInstance():show(TeachManager.MING_GANG_TIP);
	end
	

end

Operation.getOperationSize = function ( self, operatype )
	-- body
	--if operatorValueHasPeng(operatype) then
		return 280, 200;
	--[[
	elseif operatorValueHasGang(operatype) then
		return 280, 200;
	elseif operatorValueHasHu(operatype) then
		return 280, 200;
	elseif operatorValueHasGuo(operatype) then
		return 280, 200;
	end
	]]
end

-- 排序操作
Operation.sortOperationData = function (self , data)
	if not data then
		return ; 
	end
	if #data >= 3 then
		for k , v in pairs(data) do
			if operatorValueHasHu(v.operatype) then
				table.remove(data , k);
				table.insert(data , v , 3);
				return;
			end
		end
	end
end

Operation.clickOperator = function (self , operatype , card)
	if self.scene then
		self.scene:operationCallback(operatype , card);
	end
end

Operation.getOperationImage = function (self , operatype)
	if operatorValueHasPeng(operatype) then
		return TeachPin_map["operat_peng.png"];
	elseif operatorValueHasGang(operatype) then
		return TeachPin_map["operat_gang.png"];
	elseif operatorValueHasHu(operatype) then
		return TeachPin_map["operat_hu.png"];
	elseif operatorValueHasGuo(operatype) then
		return TeachPin_map["operat_guo.png"];
	end
end

