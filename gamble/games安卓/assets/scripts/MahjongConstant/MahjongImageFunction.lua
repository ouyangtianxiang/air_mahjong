--local MahjongImage_map = require("qnPlist/MahjongImage")

--local MahjongImage_map = require("qnPlist/MahjongImage")

--local MahjongImagePengPin_map = require("qnPlist/MahjongImagePengPin")

local MahjongImage_map = require("qnPlist/MahjongImage")

require("MahjongRoom/Mahjong/MahjongViewManager")

-- 得到麻将的类型和值
function getMahjongTypeAndValueByValue(value)
	local mahjongValue = value % 16;
	local mahjongType = (value - mahjongValue) / 16;
	return mahjongType , mahjongValue;
end

function getMahjongPinMapAndImgMark( mahjongType, inPintu )
	local mark = "";
	local pintu = inPintu or MahjongImage_map;

	mahjongType = tonumber( mahjongType );

    local file_list = {
 		[MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_PINK] = "_28",
 		[MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_CYAN] = "_29",
        [MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_SKYBLUE] = "_30",
        [MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_VIP] = "_vip",
        [MahjongViewManager.MahongTypeTable.MAHJONG_TYPE_NORMAL] = "",
 		default = "", 		  
    };
    mark = file_list[mahjongType] or file_list.default
    DebugLog("[getMahjongPinMapAndImgMark] mahjongType:"..tostring(mahjongType).." pintu:"..tostring(pintu).." mark:"..tostring(mark));

	return pintu, mark;
end

-- 是否需要打出一张牌
function needToDiscard(cardsCount)
	if 2 == (cardsCount % 3) then
		return true;
	end
	return false;
end

-- 通过座位和麻将的值得到手牌图片路径
-- mahjongType: 0 普通 1 vip
function getInHandImageFileBySeat(seat , value, mahjongType)
	value = tonumber(value);
	local baseDir, faceDir = nil;
	local offsetX, offsetY = 0, 0;
	local pintu, mark = getMahjongPinMapAndImgMark( tonumber(mahjongType) );
	local ds = nil
	if kSeatMine == seat then
		faceDir = MahjongImage_map[string.format("own_hand_0x%02x.png",value)];
		baseDir = pintu[string.format("front_block_2"..mark..".png")];
		ds = GameConstant.bottomMahjongScale
        DebugLog("my mahjongType:"..tostring(mahjongType));
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("front_block_2_vip.png")];
		-- else
		-- 	baseDir = MahjongImage_map[string.format("front_block_2.png")];
		-- end
	elseif kSeatRight == seat then
		faceDir = "";
		if mark == "_vip" then
			baseDir = pintu[string.format("right_hand_vip.png")] or "";
		else
			baseDir = pintu[string.format("r_hand"..mark..".png")] or "";
		end
		ds = GameConstant.rightMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("right_hand_vip.png")];
		-- else
		-- 	baseDir = MahjongImage_map[string.format("r_hand.png")];
		-- end
	elseif kSeatTop == seat then
		faceDir = "";

		if mark == "" then
			baseDir = pintu[string.format("top_hand.png")]  or "";
		else
			baseDir = pintu[string.format("oppo_hand"..mark..".png")]  or "";
		end
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("oppo_hand_vip.png")];
		-- else
		-- 	baseDir = MahjongImage_map[string.format("top_hand.png")];
		-- end
	elseif kSeatLeft == seat then
		faceDir = "";
		if mark == "_vip" then
			baseDir = pintu[string.format("left_hand_vip.png")] or "";
		else
			baseDir = pintu[string.format("l_hand"..mark..".png")] or "";
		end
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("left_hand_vip.png")];
		-- else
		-- 	baseDir = MahjongImage_map[string.format("l_hand.png")];
		-- end
	end
	return baseDir, faceDir, offsetX, offsetY,ds;
end

-- 通过座位和值获取中间显示牌的图片路径
-- mahjongType: 0 普通 1 vip
function getShowCenterImageFileBySeat(seat , value, mahjongType)
	value = tonumber(value);
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
	baseDir = pintu["out_big_bg"..mark..".png"] or "";
	-- if mahjongType then
	-- 	baseDir = MahjongImage_map["out_big_bg_vip.png"] or "";
	-- else
	-- 	baseDir = MahjongImage_map["out_big_bg.png"] or "";
	-- end
	faceDir = MahjongImage_map[string.format("out_big_0x%02x.png",value)] or "";
	-- DebugLog(string.format("out_big_0x%02x.png",value));
	offsetX, offsetY = 0, 0;
	return baseDir, faceDir, offsetX, offsetY,1.0;
end

-- 通过座位和值获取打出牌的图片路径
-- mahjongType: 0 普通 1 vip
function getOutCardImageFileBySeat(seat, value, mahjongType)
	value = tonumber(value);
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
	local ds
	if kSeatMine == seat then
		faceDir = MahjongImage_map[string.format("own_out_0x%02x.png",value)] or "";
		baseDir = pintu["own_out_bg"..mark..".png"] or "";
		ds = GameConstant.bottomMahjongScale
        DebugLog("my mahjongType:"..tostring(mahjongType).." faceDir:"..tostring(faceDir));
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["own_out_bg_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["own_out_bg.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatRight == seat then
		faceDir = MahjongImage_map[string.format("r_out_0x%02x.png",value)] or "";
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.rightMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["left-right_block_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["left-right_block.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatTop == seat then
		faceDir = MahjongImage_map[string.format("own_out_0x%02x.png",value)] or "";
		baseDir = pintu["own_out_bg"..mark..".png"] or "";
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["own_out_bg_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["own_out_bg.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatLeft == seat then
		faceDir = MahjongImage_map[string.format("l_out_0x%02x.png",value)] or "";
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["left-right_block_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["left-right_block.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	end
	return baseDir, faceDir, offsetX, offsetY,ds;
end

-- 通过座位和值获取碰杠牌的图片路径
-- mahjongType: 0 普通 1 vip
function getPengGangImageFileBySeat(seat , value, mahjongType)
	value = tonumber(value);
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local ds 
	if kSeatMine == seat then
		faceDir = MahjongImage_map[string.format("own_block_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["front_block"..mark..".png"] or "";
		ds = GameConstant.bottomMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("front_block_vip.png")];
		-- else
		-- 	baseDir = MahjongImage_map[string.format("front_block.png")];
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatRight == seat then
		faceDir = MahjongImage_map[string.format("r_out_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.rightMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["left-right_block_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["left-right_block.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatTop == seat then
		faceDir = MahjongImage_map[string.format("oppo_p_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["oppo_block"..mark..".png"] or "";
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["oppo_block_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["oppo_block.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatLeft == seat then
		faceDir = MahjongImage_map[string.format("l_out_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map["left-right_block_vip.png"] or "";
		-- else
		-- 	baseDir = MahjongImage_map["left-right_block.png"] or "";
		-- end
		offsetX, offsetY = 0, 0;
	end
	return baseDir, faceDir, offsetX, offsetY,ds ;
end

-- 通过座位获取暗杠牌的图片路径
-- mahjongType: 0 普通 1 vip
function getAnGangImageFileBySeat(seat, mahjongType)
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
	local ds 
	if kSeatMine == seat then
		baseDir = pintu["own_gang"..mark..".png"] or "";
		ds = GameConstant.bottomMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("own_gang_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("own_gang.png")] or "";
		-- end
	elseif kSeatRight == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("right_block_back_vip.png")] or "";
		elseif mark == "" then
			baseDir = pintu["l_r_gang.png"] or "";
		else
			baseDir = pintu["right_block_back"..mark..".png"] or "";
		end
		ds = GameConstant.rightMahjongScale
		
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("right_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("l_r_gang.png")] or "";
		-- end
	elseif kSeatTop == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("oppo_block_back_vip.png")] or "";
		else
			baseDir = pintu["top_gang"..mark..".png"] or "";
		end
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("oppo_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("top_gang.png")] or "";
		-- end
	elseif kSeatLeft == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("left_block_back_vip.png")] or "";
		elseif mark == "" then
			baseDir = pintu["l_r_gang.png"] or "";
		else
			baseDir = pintu["left_block_back"..mark..".png"] or "";
		end
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("left_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("l_r_gang.png")] or "";
		-- end
	end
	return baseDir, faceDir, offsetX, offsetY,ds;
end

-- 通过座位和值获取胡牌的图片路径
-- mahjongType: 0 普通 1 vip
function getHuCardImageFileBySeat(seat , value, mahjongType)
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
	value = tonumber(value);
	local ds
	if kSeatMine == seat then
		faceDir = MahjongImage_map[string.format("own_block_0x%02x.png",value)] or "";
		baseDir = pintu["front_block"..mark..".png"] or "";
		ds = GameConstant.bottomMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("front_block_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("front_block.png")] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatRight == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("right_block_back_vip.png")] or "";
		elseif mark == "" then
			baseDir = pintu["l_r_gang.png"] or "";
		else
			baseDir = pintu["right_block_back"..mark..".png"] or "";
		end
		ds = GameConstant.rightMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("right_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("l_r_gang.png")] or "";
		-- end
	elseif kSeatTop == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("oppo_block_back_vip.png")] or "";
		else
			baseDir = pintu["top_gang"..mark..".png"] or "";
		end
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("oppo_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("top_gang.png")] or "";
		-- end
	elseif kSeatLeft == seat then
		if mark == "_vip" then
			baseDir = pintu[string.format("left_block_back_vip.png")] or "";
		elseif mark == "" then
			baseDir = pintu["l_r_gang.png"] or "";
		else
			baseDir = pintu["left_block_back"..mark..".png"] or "";
		end
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("left_block_back_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("l_r_gang.png")] or "";
		-- end
	end
	return baseDir, faceDir, offsetX, offsetY,ds;
end

-- 通过座位和值获取牌局结束手牌的图片路径
-- mahjongType: 0 普通 1 vip
function getGameOverCardImageFileBySeat(seat , value, mahjongType)
	value = tonumber(value);
	local baseDir, faceDir = "", "";
	local offsetX, offsetY = 0, 0;
	local ds
	if kSeatMine == seat then
		faceDir = MahjongImage_map[string.format("own_block_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["front_block"..mark..".png"] or "";
		ds = GameConstant.bottomMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("front_block_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("front_block.png")] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatRight == seat then
		faceDir = MahjongImage_map[string.format("r_out_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.rightMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("left-right_block_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("left-right_block.png")] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatTop == seat then
		faceDir = MahjongImage_map[string.format("oppo_p_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["oppo_block"..mark..".png"] or "";
		ds = GameConstant.topMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("oppo_block_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("oppo_block.png")] or "";
		-- end
		offsetX, offsetY = 0, 0;
	elseif kSeatLeft == seat then
		faceDir = MahjongImage_map[string.format("l_out_0x%02x.png",value)] or "";
		local pintu, mark = getMahjongPinMapAndImgMark( mahjongType, MahjongImage_map );
		baseDir = pintu["left-right_block"..mark..".png"] or "";
		ds = GameConstant.leftMahjongScale
		-- if mahjongType then
		-- 	baseDir = MahjongImage_map[string.format("left-right_block_vip.png")] or "";
		-- else
		-- 	baseDir = MahjongImage_map[string.format("left-right_block.png")] or "";
		-- end
		offsetX, offsetY = 0, 0;
	end
	return baseDir, faceDir, offsetX, offsetY,ds;
end


