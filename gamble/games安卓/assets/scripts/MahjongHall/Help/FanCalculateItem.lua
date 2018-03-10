require("MahjongHall/Rank/RankUserInfo");
require("MahjongConstant/MahjongImageFunction");

FanCalculateItem = class(Node)

FanCalculateItem.ctor = function(self, width, height, data)
	if not data then
		return;
	end

    local x, y, w, h = 0, 0, 0, 0;
    local ajustX = -6;

    if data["T"] then
        local title = self:createTitle(data["T"]);
        self:addChild(title);
        title:setPos(x, y);
        local _w, _h = title:getSize();
        h = h + _h;
        y = y + _h;
    end

    if data["T1"] then
        local title = self:createTitle(data["T1"]);
        self:addChild(title);
        title:setPos(x, y);
        local _w, _h = title:getSize();
        h = h + _h;
        y = y + _h;
    end

    local dist = data["D"];

    for i = 1, #dist do
        local node = self:createDist(width, dist[i]["T"], dist[i]["D"]);
        self:addChild(node);
        node:setPos(x, y);
        local _w, _h = node:getSize();
        h = h + _h;
        y = y + _h;

        if dist[i]["F"] then
            -- local node = self:createImage(dist[i]["F"]);
            local cardNode = new(Node);
            cardNode:setPos(x ,y);
            local _w, _h = 0 , 0;
            local isVip = PlayerManager.getInstance():getPlayerBySeat(kSeatMine):checkVipStatu(Player.VIP_MZZ);
            for j = 1 , #dist[i]["F"] do
                local baseDir , faceDir = getPengGangImageFileBySeat(kSeatMine , dist[i]["F"][j] , isVip);
                local card = UICreator.createImg(baseDir);
                local cardF = UICreator.createImg(faceDir);
                card:addChild(cardF);

                card:setPos(0 + ((j - 1) * (card.m_width + 2 + ajustX)), 0);
                cardNode:addChild(card);
                _w , _h = card:getSize();
            end

            h = h + _h + 10;
            y = y + _h + 10;
            cardNode:setSize( (_w + 2.5) *  #dist[i]["F"], _h);
            DebugLog("_w : ".._w *  #dist[i]["F"].." _h : ".._h);
            self:addChild(cardNode);
            cardNode:addPropScaleSolid(0,0.8,0.8,kCenterTopLeft)
            --cardNode:packDrawing(true)
        end
    end

    local split = UICreator.createImg("Commonx/split_hori.png",x,y)
    split:setSize(width,2)
    self:addChild(split)
    
    self:setSize(width, h ); -- 比实际大小多出10个逻辑像素
end

FanCalculateItem.createTitle = function ( self, title)
    local titleText = UICreator.createText(title,0,0,0,50,kAlignTopLeft, 30, 0xFF, 0xFF, 0xFF);--0xFF, 0xF4, 0xE7
    titleText:setSize(titleText.m_res.m_width, 50);--titleText.m_res.m_height);--为了跟其他界面保持一致，所以为50
    return titleText;
end

FanCalculateItem.createDist = function ( self, width, name, desc)
    local node = new(Node);

    local nameText = UICreator.createText(name,0,0,0,50,kAlignTopLeft, 30, 0xFF, 0xFF, 0xEF);--0xFF, 0xF4, 0xE7
    local nameWidth = nameText.m_res.m_width
    delete(nameText)
    
    nameText = new(TextView,name,nameWidth,50,kAlignTopLeft,"",30,255,255,255)
    nameText:setSize(nameText.m_drawing:getSize())
    node:addChild(nameText);

    if name == "" then 
        nameWidth = 0
    end

    local tvDesc = new(TextView,desc, width - nameWidth, 50, kAlignTopLeft, "", 30,255, 255, 255);--255, 198, 0
    tvDesc:setPos(nameWidth,0);
    tvDesc:setSize(tvDesc.m_drawing:getSize());
    node:addChild(tvDesc);

    local dW, dH = tvDesc:getSize();
    local test = new(TextView,"D", width - nameWidth, 0, kAlignTopLeft, "", 30,255, 255, 255);--255, 198, 0

    if nameText.m_res.m_height > dH then
         node:setSize(width, nameText.m_res.m_height);
    else
        node:setSize(width, dH + nameText.m_res.m_height - test.m_res.m_height);
    end

    delete(test);
    return node;
end

FanCalculateItem.createImage = function ( self, path)
    local image = UICreator.createImg(path, 0, 0);
    return image;
end

FanCalculateItem.dtor = function(self)
end

