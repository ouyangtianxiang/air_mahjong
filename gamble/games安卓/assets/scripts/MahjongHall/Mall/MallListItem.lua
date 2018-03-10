-- MallListItem.lua
-- Author: YifanHe
-- Date: 2013-10-23
-- Last modification : 2013-10-24
-- Description: 金币商品显示列表单项
local hallMallItem = require(ViewLuaPath.."hallMallItem");
MallListItem = class(Node)


MallListItem.ctor = function(self, data)
    if not data then
        return;
    end
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    self.m_id = data.id;                                    --商品ID
    self.m_ptype = tonumber(data.ptype) or 0;                              --所购产品类型[0:游戏币，1:博雅币，2+:道具]
    self.m_pamount = tonumber(data.pamount) or 0;                          --应付款项
    self.m_pcoins = data.pcoins;                            --对等博雅币
    self.m_pchips = data.pchips;                            --对等金币
    self.m_pcard = data.pcard;                              --对等道具ID
    self.m_pnum = data.pnum;                                --数量
    self.productName = data.pname;                          --商品名称
    self.m_desc = data.pdesc;                               --商品描述
    self.m_url1 = data.pimg or "";                          --图片下载地址
    self.data = data;

    self.rootNode     = SceneLoader.load(hallMallItem)
    self:addChild( self.rootNode )

    self:getAllControls()

    -- 价格
    -- local priceDes = "￥"..(self.m_getothername1 or ((self.m_pamount or "")));

    local priceDes =  (self.m_pamount or "").."元";

    self.priceText:setText( priceDes)
    -- if PlatformConfig.platformOPPO == GameConstant.platformType then
    --     self.priceText:setPos(self.priceText.m_x - 2,self.priceText.m_y);
    -- end
    self.nameText:setText( self.productName )

    self.tipsText:setText( self.m_desc or "" )
    self.itemBgImg.data = self.data
    self.itemBgImg:setOnClick(self, self.onClickPayBtn);


------------------------------------------------
    local originW,originH = self.tipsBg:getSize()--背景原始长宽
    local textW,textH = self.tipsText:getSize()--文字宽高
    local textOffToRight = 9 --右对齐间距  文字相对于背景
    local adaptionW = textW + 2*textOffToRight -- 自适应文字 背景宽度

    local bgOffXToParent = self.tipsBg:getPos() --
    local itemW = self.itemBgImg:getSize()

    if adaptionW > itemW - 2* bgOffXToParent  then --最大宽度
        adaptionW = itemW - 2* bgOffXToParent
    elseif adaptionW < originW then
        adaptionW = originW
    end
    self.tipsBg:setSize(adaptionW,originH)
----------------------------------------------------

    if self.m_desc == "" then
        self.tipsBg:setVisible(false)
    end

    --金币图片
    local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_url1);
    self.localDir = localDir;
    self.iconImg:setSize(self.m_ptype == 0 and 160 or 168, self.m_ptype == 0 and 126 or 144);
    if not isExist then -- 图片未下载
        localDir = "coin1.png";

        local default = self.m_ptype == 0 and "Hall/HallMall/coin1.png" or "Hall/HallMall/diamond_default.png";
        self.iconImg:setFile( default )
    else
        self.iconImg:setFile( localDir )
    end


    --促销图标
    local promotionIconStr = self.promotionIconTable[self.m_sptype];
    if promotionIconStr then
        self.tagImg:setFile( promotionIconStr )
        self.tagImg:setVisible(true)
    end

    if PlatformConfig.platformWDJ == GameConstant.platformType or
       PlatformConfig.platformWDJNet == GameConstant.platformType then
       self.itemBgImg:setFile("Login/wdj/Hall/HallMall/item_bg.png");

    end
    if tonumber(GameConstant.checkType) == kCheckStatusOpen or not self.m_desc then
        self.tipsBg:setVisible(false);
    else
        self.tipsBg:setVisible(true);
    end

    if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
        self.tipsBg:setVisible(false)
    end
end

MallListItem.getAllControls = function ( self )
    -- body
    self.itemBgImg    = publ_getItemFromTree(self.rootNode, { "item_bg"});

    self.iconImg      = publ_getItemFromTree(self.itemBgImg, { "icon_img"});
    self.priceText    = publ_getItemFromTree(self.itemBgImg, { "price_text"});
    self.tipsText     = publ_getItemFromTree(self.itemBgImg, { "tips_bg_img" , "tips_text"});
    self.nameText     = publ_getItemFromTree(self.itemBgImg, { "name_text"});
    self.tagImg       = publ_getItemFromTree(self.itemBgImg, { "tag_img"});
    self.tipsBg       = publ_getItemFromTree(self.itemBgImg, { "tips_bg_img"})

    if tonumber(GameConstant.checkType) == kCheckStatusOpen then --审核状态，隐藏加赠标签
        self.tipsBg:setVisible(false)
        self.tipsText:setVisible(false)
    else
        self.tipsBg:setVisible(true)
        self.tipsText:setVisible(true)
    end
    if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee then
        self.tipsBg:setVisible(false)
    end
end

MallListItem.onClickPayBtn = function(self)
    self:reportMallCoinsClick();
    DebugLog("MallListItem.onClickPayBtn")
    -- self.data.payScene = {};
    -- self.data.payScene.scene_id = PlatformConfig.MallCoinBuyForPay;

    PlatformFactory.curPlatform:pay( self.data );
end

MallListItem.dtor = function(self)
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    self:removeAllChildren();
end

MallListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.iconImg:setFile(self.localDir);
            setImgToResSize(self.iconImg)
        end
    end
end

MallListItem.reportMallCoinsClick = function ( self )
    if 0 == tonumber(self.m_ptype) and 2 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallTwoYuan);
    elseif 0 == tonumber(self.m_ptype) and 6 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallSixYuan);
    elseif 0 == tonumber(self.m_ptype) and 10 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallTenYuan);
    elseif 0 == tonumber(self.m_ptype) and 20 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallTwentyYuan);
    elseif 0 == tonumber(self.m_ptype) and 30 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallThirtyYuan);
    elseif 0 == tonumber(self.m_ptype) and 50 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallFiftyYuan);
    elseif 0 == tonumber(self.m_ptype) and 100 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallOneHundredYuan);
    elseif 0 == tonumber(self.m_ptype) and 200 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallTwoHundredYuan);
    elseif 0 == tonumber(self.m_ptype) and 500 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_MallFiveHundredYuan);
    elseif 1 == tonumber(self.m_ptype) and 30 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_Mall30BoyaaCoin);
    elseif 1 == tonumber(self.m_ptype) and 98 == tonumber(self.m_pamount) then
        umengStatics_lua(Umeng_Mall98BoyaaCoin);
    end
end

MallListItem.promotionIconTable = {
    [1]  = "Hall/HallMall/hot.png",--"newHall/mall/mark_hot.png",
    [2]  = "Hall/HallMall/new.png",--"newHall/mall/mark_hot.png",
    [3]  = "Hall/HallMall/chaozhi.png",
    [4]  = "Hall/HallMall/tuijian.png",
    [5]  = "Hall/HallMall/dazhe.png"--"newHall/mall/mark_dazhe.png"
}
