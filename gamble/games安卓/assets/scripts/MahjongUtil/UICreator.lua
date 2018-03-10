---- UICreator.lua
-- Date: 2013-09-11
-- Last modification : 2013-09-11
-- Description: wrapper for create UI item

require("MahjongUtil/MahjongButton");

UICreator = {};
UICreator.createImg = function ( imgDIr, x, y ,leftWidth, rightWidth, topWidth, bottomWidth)
	local img = new(Image , imgDIr, nil, nil, leftWidth, rightWidth, topWidth, bottomWidth);
	img:setVisible(true);
	img:setPos(x or 0 , y or 0);
	return img;
end

UICreator.createImages = function(filenameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	if not filenameArray or #filenameArray <= 0 then
		return;
	end 

	local node = new(Images, filenameArray, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth);
	return node;
end

UICreator.createGrayscaleImg = function( imgDir, x, y )
	local img = new(Image , imgDir, kRGBGray);
	img:setVisible(true);
	img:setPos(x or 0 , y or 0);
	return img;
end

UICreator.createImgContainsWH = function(imgDir,x,y,w,h)
	local img = UICreator.createImg(imgDir,x,y);
	img:setSize(w,h);
	return img;
	-- body
end

UICreator.createBtn = function ( imgDir, x, y, obj, func)
	local btn = new( MahjongButton, imgDir );
	btn:setPos( x, y);
	if func then
		btn:setOnClick(obj,func);
	end
	return btn;
end


UICreator.createBtn9Grid = function ( imgDir, x, y, leftWidth, rightWidth, topWidth, bottomWidth, obj, func)
	local btn = new( MahjongButton, imgDir, nil, nil, nil,leftWidth, rightWidth, topWidth, bottomWidth );
	btn:setPos( x, y);
	if func then
		btn:setOnClick(obj,func);
	end
	return btn;
end

UICreator.createGrayscaleBtn = function ( imgDir, x, y, obj, func)
	local btn = new( MahjongButton, imgDir, nil ,kRGBGray );
	btn:setPos( x, y);
	if func then
		btn:setOnClick(obj,func);
	end
	return btn;
end

UICreator.createTextBtn = function ( imgDir, x, y, str, fontSize, r, g, b)
	str = GameString.convert2Platform(str);
	local btn = new( MahjongButton, imgDir );
	btn:setPos( x, y);
	local text = UICreator.createText(str, 0, 0, btn.m_width, btn.m_height, kAlignCenter, fontSize, r, g, b);
	btn:addChild(text);
	return btn, text;
end

UICreator.createBtn2 = function ( imgDir, disableImgDir, x, y, obj, func)
	local btn = new( MahjongButton, imgDir, disableImgDir );
	btn:setPos( x, y);
	if func then
		btn:setOnClick(obj,func);
	end
	return btn;
end

UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
	str = GameString.convert2Platform(str);
	local text = new( Text, str, width, height, align, nil, fontSize, r, g, b);
	text:setPos( x, y);
	return text;
end

--定义字体加粗
UICreator.createUserDefineText = function(str, x, y, width,height, align , fontStyle, fontSize, r, g, b)
    str = GameString.convert2Platform(str);
	local text = new( Text, str, width, height, align, fontStyle, fontSize, r, g, b);
	text:setPos( x, y);
	return text;
end


