-- PropListItem.lua
-- Author: YifanHe
-- Date: 2013-10-25
-- Last modification : 2013-10-25
-- Description: 兑换商品显示列表单项

require("MahjongData/ItemManager");

--local hall_mallPin_map = require("qnPlist/hall_mallPin")

local hallMallItem = require(ViewLuaPath.."hallMallItem");



PropListItem = class(Node)


PropListItem.ctor = function(self, data, rootNode)
	DebugLog("*********************id = "..data.id .. "--name=" .. data.name)
    self.m_event = EventDispatcher.getInstance():getUserEvent();
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	self.data = data;
    self.m_id = data.id;  --商品ID
    self.m_name = data.name;  --商品名称
    self.m_sptype = data.sptype;  --商品销售类型: 1 hot, 2 new, 3 超值, 4 限量  [5折扣(后端未启用)]
    self.m_image = data.image;  --商品图片URL
    self.m_money = data.money;  --价值多少金币
    self.m_chips = data.chips;  --价值多少积分
    self.m_boyaacoin = data.boyaacoin;  --价值多少博雅币
    self.m_coupons = data.coupons;  --价值多少话费券
    self.m_rewardmoney = data.rewardmoney;  --赠送金币
    self.m_moneytype = data.moneytype;  --0积分 1金币 2博雅币 3积分加金币
    self.m_goodsdes = data.goodsdes or "";  --商品描述
    self.m_goodstype = data.goodstype;  --商品类型: 1卡片 2金币 3实物
    self.m_cid = data.cid; --卡片ID
    self.m_discount = data.discount;  --折扣
    self.m_num = data.num;  --总量
    self.m_limitnum = data.limitnum;  --个人限购
    self.m_sort = data.sort;  --排序
    self.m_mallRef = data.mallRef; --商城主界面引用
    self.m_url1 = data.image or "";       --图片下载地址
    self.m_rootNode = rootNode;

    --购买按钮 [0积分 1金币 2博雅币 3积分加金币]
    if self.m_goodstype == 4 then
        self.payText = "";
    else
        if self.m_moneytype == 0 then
            self.payText = self.m_chips .. "积分";
        elseif self.m_moneytype == 1 then
            self.payText = self.m_money .. "金币";
        elseif self.m_moneytype == 2 then
            self.payText = self.m_boyaacoin .. "钻石";
        elseif self.m_moneytype == 3 then
            self.payText = self.m_chips .. "积分与"..self.m_money.."金币";
        end
    end

    self:initView();

    DebugLog("buy prop img name(PropListItem): " .. tostring(self.m_url1))
    local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_url1);
    self.localDir = localDir;

    if not isExist then -- 图片未下载
        localDir = "coin1.png";
        self.mImgIcon:setFile( "Hall/HallMall/coin1.png" )
    else 
        self.mImgIcon:setFile( localDir )
    end

    self.mTextPrice:setText( self.payText );
    self.mTextDesp:setText( self.m_goodsdes );

    if self.m_goodsdes == "" then 
        self.mImgTipsBg:setVisible(false)
    end
    --local name_num_str = self.m_name

    self.mTextNums:setText( self.m_name);
    self.mTextNums:setVisible( true );

    --处理兑换的激活码
    if self.m_goodstype == 4 then
        self.mTextPrice:setText( self.m_name)
    end 
------------------------------------------------
    local originW,originH = self.mImgTipsBg:getSize()--背景原始长宽
    local textW,textH = self.mTextDesp:getSize()--文字宽高
    local textOffToRight = 9 --右对齐间距  文字相对于背景
    local adaptionW = textW + 2*textOffToRight -- 自适应文字 背景宽度
    
    local bgOffXToParent = self.mImgTipsBg:getPos() --
    local itemW = self.exchangeBtn:getSize()

    if adaptionW > itemW - 2* bgOffXToParent  then --最大宽度
        adaptionW = itemW - 2* bgOffXToParent 
    elseif adaptionW < originW then 
        adaptionW = originW
    end 
    self.mImgTipsBg:setSize(adaptionW,originH)
----------------------------------------------------
    --促销图标
    local promotionIconStr = self.promotionIconTable[self.m_sptype];
    if promotionIconStr then
        self.mImgPromotion:setFile( promotionIconStr );
        self.mImgPromotion:setVisible( true );
    else
        self.mImgPromotion:setVisible( false );
    end



end

function PropListItem.initView( self )
    self.layout = SceneLoader.load( hallMallItem );
    self:addChild( self.layout );

    self.exchangeBtn = publ_getItemFromTree(self.layout, {"item_bg"});
    self.exchangeBtn:setOnClick( self, function( self )
        self:onClickPayBtn();
    end);
--价格--图片--有效期--个数--角标  推荐 or 超值

    self.mImgIcon       = publ_getItemFromTree(self.exchangeBtn, {"icon_img"});
    self.mTextNums      = publ_getItemFromTree(self.exchangeBtn, {"name_text"});
    self.mTextPrice     = publ_getItemFromTree(self.exchangeBtn, {"price_text"});
    self.mTextDesp      = publ_getItemFromTree(self.exchangeBtn, { "tips_bg_img" , "tips_text"});
    --self.mTextNums      = publ_getItemFromTree(self.exchangeBtn, {"text_nums"});
    self.mImgPromotion  = publ_getItemFromTree(self.exchangeBtn, {"tag_img"});
    self.mImgTipsBg     = publ_getItemFromTree(self.exchangeBtn, { "tips_bg_img"}) 

    if PlatformConfig.platformWDJ == GameConstant.platformType or 
       PlatformConfig.platformWDJNet == GameConstant.platformType then 
      self.exchangeBtn :setFile("Login/wdj/Hall/HallMall/item_bg.png");  
    end    
end

--请求兑换物品
PropListItem.onClickPayBtn = function(self)
    --处理个人限购数量
    local myCardNum = ItemManager.getInstance():getCardNum(self.m_cid);
    if self.m_limitnum and self.m_limitnum ~= 0 and myCardNum >= self.m_limitnum then
        local msg = "您已经拥有太多此类物品";
        Banner.getInstance():showMsg(msg);
        return;
    end

    --处理兑换的激活码
    if self.m_goodstype == 4 then
        require("MahjongHall/Mall/ActivationCodeWnd");
        new( ActivationCodeWnd, MallWindow.instance );
        return;
    end

    require("MahjongCommon/ExchangePopu");
    new(ExchangePopu, self.m_cid, MallWindow.instance);
end

PropListItem.promotionIconTable = {
    --1 hot, 2 new, 3 超值, 4 限量  [5折扣(后端未启用)]
    [1]  = "Hall/HallMall/hot.png",--"newHall/mall/mark_hot.png",
    [2]  = "Hall/HallMall/new.png",--"newHall/mall/mark_hot.png",
    [3]  = "Hall/HallMall/chaozhi.png",
    [4]  = "Hall/HallMall/tuijian.png",
    [5]  = "Hall/HallMall/dazhe.png"--"newHall/mall/mark_dazhe.png"
}




PropListItem.dtor = function(self)
	self:removeAllChildren();
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

PropListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.mImgIcon:setFile(self.localDir);
            self.mImgIcon:setSize(112, 112);
        end
    end
end

