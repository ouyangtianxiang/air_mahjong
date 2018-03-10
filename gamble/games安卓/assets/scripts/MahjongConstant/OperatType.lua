require("libs/bit");

     -------------------- 各种操作类型 ---------------------
RIGHT_CHOW 		= 0x001;    -- 右吃
MIDDLE_CHOW 	= 0x002;   -- 中吃
LEFT_CHOW 		= 0x004;     -- 左吃

PUNG 			= 0x008;          -- 碰

PUNG_KONG 		= 0x010;     -- 碰杠
HUA_KONG 		= 0x020;      -- 花杠

AN_KONG 		= 0x200;       -- 暗杠
BU_KONG 		= 0x400;       -- 补杠

ZI_MO 			= 0x800;         -- 自摸
QIANG 			= 0x040;         -- 放枪
QIANG_GANG_HU 	= 0x080; 		-- 抢杠胡
HUA_HU 			= 0x100;        -- 抢花胡

GUO    			= 0x4000; 	   -- 过

--OPE_MAN_YOU = 0x1000;  --海底漫游


function guo(operatorValue) -- 过
	if operatorValue then
		local value = bit.band(operatorValue , GUO);
		if value == GUO then
			return true;
		end
	end
	return false;
end

function peng(operatorValue) -- 碰
	if operatorValue then
		local value = bit.band(operatorValue , PUNG);
		if value == PUNG then
			return true;
		end
	end
	return false;
end

function peng_gang(operatorValue) --碰杠
	if operatorValue then
		local value = bit.band(operatorValue , PUNG_KONG);
		if value == PUNG_KONG then
			return true;
		end
	end
	return false;
end

function an_gang(operatorValue) --暗杠
	if operatorValue then
	   	local value = bit.band(operatorValue , AN_KONG);
		if value == AN_KONG then
			return true;
		end
	end
	return false;
end

function bu_gang(operatorValue) --补杠
	if operatorValue then
		local value = bit.band(operatorValue , BU_KONG);
		if value == BU_KONG then
			return true;
		end
	end
	return false;
end


-- 胡牌
function hu_zimo(operatorValue) --自摸
	if operatorValue then
		local value = bit.band(operatorValue , ZI_MO);
		if value == ZI_MO then
			return true;
		end
	end
	return false;
end

function hu_qiang(operatorValue) --放枪
	if operatorValue then
		local value = bit.band(operatorValue , QIANG);
		if value == QIANG then
			return true;
		end
	end
	return false;
end

function hu_qiangGang(operatorValue) --抢杠
	if operatorValue then
		local value = bit.band(operatorValue , QIANG_GANG_HU);
		if value == QIANG_GANG_HU then
			return true;
		end
	end
	return false;
end

function operatorValueHasGuo(operatorValue)
	return guo(operatorValue);
end

function operatorValueHasPeng(operatorValue)
	return peng(operatorValue);
end

function operatorValueHasGang(operatorValue)
	return peng_gang(operatorValue) or an_gang(operatorValue) or bu_gang(operatorValue);
end

function operatorValueHasHu(operatorValue)
	return hu_zimo(operatorValue) or hu_qiang(operatorValue) or hu_qiangGang(operatorValue);
end


