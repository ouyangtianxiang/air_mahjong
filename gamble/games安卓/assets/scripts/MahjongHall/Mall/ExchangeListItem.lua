-- ExchangeListItem.lua
-- Author: YifanHe
-- Date: 2013-10-25
-- Last modification : 2013-10-25
-- Description: 兑换商品显示列表单项
require("MahjongData/ItemManager");
require("MahjongHall/exchange/ExchangeSuccessWindow");


local hallMallItem = require(ViewLuaPath.."hallMallItem");

ExchangeListItem = class(Node)


ExchangeListItem.ctor = function(self, data, rootNode)
	
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
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
    self.m_moneytype = data.moneytype;  --0积分 1金币 2博雅币 3积分加金币 4话费券
    self.m_goodsdes = data.goodsdes;  --商品描述
    self.m_goodstype = data.goodstype;  --商品类型: 1卡片 2金币 3实物
    self.m_cid = data.cid; --卡片ID
    self.m_discount = data.discount;  --折扣
    self.m_num = data.num;  --总量
    self.m_limitnum = data.limitnum;  --个人限购
    self.m_sort = data.sort;  --排序
    self.m_mallRef = data.mallRef; --商城主界面引用
    self.m_url1 = data.image or "";       --图片下载地址
    self.m_rootNode = rootNode;
    self.bindCount = "";
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
        elseif self.m_moneytype == 4 then
            self.payText = self.m_coupons .. "话费券";
        end
    end

    self:initView();

    local isExist , localDir = NativeManager.getInstance():downloadImage(self.m_url1);
    self.localDir = localDir;

    if not isExist then -- 图片未下载
        localDir = "coin1.png";
        self.mImgIcon:setFile( "Hall/HallMall/coin1.png" )
    else 
        self.mImgIcon:setFile( localDir )
    end
    self.mImgIcon:setSize(112, 112);
    self.mTextName:setText( self.m_name );
    self.mTextPrice:setText( self.payText );
    self.mTextDesp:setText( self.m_goodsdes );
    
    if self.m_goodsdes == "" then 
        self.mImgTipsBg:setVisible(false)
    end
    --限量信息
   --[[if self.m_num then
        self.mTextNums:setText( "剩余:"..self.m_num );
        self.mTextNums:setVisible( true );
    else
        self.mTextNums:setVisible( false );
    end
    ]] 
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

function ExchangeListItem.initView( self )

    self.layout = SceneLoader.load( hallMallItem );
    self:addChild( self.layout );

    self.exchangeBtn = publ_getItemFromTree(self.layout, {"item_bg"});
    self.exchangeBtn:setOnClick( self, function( self )
        self:onClickPayBtn();
    end);

    self.exchangeBtn:setFile("Hall/HallMall/exchange_item_bg.png")
--价格--图片--有效期--个数--角标  推荐 or 超值

    self.mImgIcon       = publ_getItemFromTree(self.exchangeBtn, {"icon_img"});
    --self.mImgIcon.localDir = "";
    self.mTextName      = publ_getItemFromTree(self.exchangeBtn, {"name_text"});
    self.mTextPrice     = publ_getItemFromTree(self.exchangeBtn, {"price_text"});
    self.mTextDesp      = publ_getItemFromTree(self.exchangeBtn, { "tips_bg_img" , "tips_text"});
    self.mImgPromotion  = publ_getItemFromTree(self.exchangeBtn, {"tag_img"});
    self.mImgTipsBg     = publ_getItemFromTree(self.exchangeBtn, { "tips_bg_img"})         
end

--请求兑换物品
ExchangeListItem.onClickPayBtn = function(self)

    --处理个人限购数量
    local myCardNum = ItemManager.getInstance():getCardNum(self.m_cid);
    if self.m_limitnum and self.m_limitnum ~= 0 and myCardNum >= self.m_limitnum then
        local msg = "您已经拥有太多此类物品";
        Banner.getInstance():showMsg(msg);
        return;
    end

    for k,v in pairs(self) do
        DebugLog("k: "..tostring(k) .. " v: " .. tostring(v))
    end

    --处理兑换的是实物的情况
    if self.m_goodstype == 3 then

        if tonumber(self.m_coupons) > PlayerManager.getInstance():myself():getCoupons() then
            Banner.getInstance():showMsg("话费券不足，请累计足够后再兑换");
            return ;
        end
        --非手机登录且未绑定则进入手机绑定界面
        if (not GlobalDataManager.getInstance():getIsCellAcccountLogin()) 
            and (not GlobalDataManager.getInstance():getIsCellAcccountBind()) then
            require("MahjongLogin/LoginMethod/CellphoneLogin")
            CellphoneLoginWindow:showExchangeIfNoBind(self);
            return;
        end

        require("MahjongPopu/ExchangeGoodsWindow");

        local exchangeGoodsWindow = new(ExchangeGoodsWindow);
        self.m_rootNode:addChild(exchangeGoodsWindow);
        local bindAccount = GlobalDataManager.getInstance():getCellBindAccount();
        --判断是不是绑定过的帐号，绑定过则填绑定帐号，未绑定看是不是手机登录，填入手机号码，其他为空
        if bindAccount <= 0 then
            if GlobalDataManager.getInstance():getIsCellAcccountLogin() then
                bindAccount = GlobalDataManager.getInstance():getLoginSuccessAcPwd()
            end
        end
        bindAccount = tostring(bindAccount) or "";
        exchangeGoodsWindow:setPhoneNum(bindAccount or "");
        
        local _, name, ad = GlobalDataManager.getInstance():getExchangeDictInfo();
        exchangeGoodsWindow:setName(name or "");
        exchangeGoodsWindow:setAddress(ad or "");
        DebugLog("请求兑换物品:"..tostring(bindAccount)..tostring(name)..tostring(ad));
        --目前是单例，所以每次显示前清空下数据，以免上一次操作的号码和信息还存在
        exchangeGoodsWindow:showWnd();
        exchangeGoodsWindow:setOKCallBack(self, function()        
            local strPhoneNum   = exchangeGoodsWindow:getPhoneNum() or "";           
            local strAddress    = exchangeGoodsWindow:getAddress() or "";
            local strName       = exchangeGoodsWindow:getName() or "";

            if not strPhoneNum or strPhoneNum == "" then
                Banner.getInstance():showMsg("请填写您的手机号码");
                return ;
            end
          
            if not tonumber(publ_trim(strPhoneNum)) then
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if string.len(publ_trim(strPhoneNum)) ~= 11 then 
                Banner.getInstance():showMsg("请填写11位有效手机号码");
                return;
            end

            if not strName or strName == "" or publ_trim(strName) == "" then
                Banner.getInstance():showMsg("请填写您的姓名");
                return ;
            end

            if string.len(publ_trim(getStringLen(strName))) > 10 then
                Banner.getInstance():showMsg("请填写不超过10个字符的姓名");
                return ;
            end

            self:postExchange(strPhoneNum, strName, strAddress);
            -- popWindowUp(exchangeGoodsWindow, exchangeGoodsWindow.hideHandle,exchangeGoodsWindow.bg);
            exchangeGoodsWindow:hideWnd();
            exchangeGoodsWindow:setVisible(false);
            exchangeGoodsWindow = nil;
        end);
        return;
   --[[ elseif self.m_goodstype == 4 then
        require("MahjongHall/Mall/ActivationCodeWnd");
        new( ActivationCodeWnd, MallWindow.instance );
        return;
    ]]
    elseif self.m_goodstype == 2 then --换的是金币的情况
        --require("MahjongCommon/ExchangePopu");
        --new(ExchangePopu, self.m_cid, ExchangeWindow.instance);
        self:postExchange()

    end


end


--发送兑换请求
ExchangeListItem.postExchange = function( self, phone, name, address )
    local param_data = self.data or {};
    if phone and name and address then
        param_data.phone    = phone;
        param_data.name     = name;
        param_data.address  = address;
    end
    GlobalDataManager.getInstance():setExchangeDictInfo(phone, name, address);
    param_data.mallRef = nil;
    param_data.mid = PlayerManager.getInstance():myself().mid;
    --param_data.sitemid = SystemGetSitemid();
    param_data.number = 1;
    param_data.money = PlayerManager.getInstance():myself().money or 0;
    Loading.showLoadingAnim("正在为您兑换...");
    SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_EXCHANGE, param_data);
end


ExchangeListItem.requestExchangeCallBack = function(self, isSuccess, data)
    Loading.hideLoadingAnim();

     if data then
        local goodsId = GetNumFromJsonTable(data, "goodsid")
        if not self.m_id or not goodsId or  tonumber(self.m_id) ~= tonumber(goodsId) then 
            return 
        end
    end
     
    if not isSuccess or not data then
        if data and data.msg  then
            
            Banner.getInstance():showMsg( tostring(data.msg) );
        end
        return;
    end

    if not isSuccess and data then
        if type( data ) == "string" then
            Banner.getInstance():showMsg( data );
        end
    end

    if isSuccess then
        --goodsSid
        local goodsId = GetNumFromJsonTable(data, "goodsid")
        if not self.m_id or not goodsId or  tonumber(self.m_id) ~= tonumber(goodsId) then 
            return 
        end 

        local msg = GetStrFromJsonTable(data, "msg");
        if msg and msg ~= "" then 
            --Banner.getInstance():showMsg(msg);改用界面显示，所以这个提示要去掉
        end

        if GetNumFromJsonTable(data, "status") == 1 then
            local ctype = GetNumFromJsonTable(data, "ctype"); --1加 2减 （chips）
            local chips = GetNumFromJsonTable(data, "chips"); --积分
            local mtype = GetNumFromJsonTable(data, "mtype"); --1加 2减 （money）
            local money = GetNumFromJsonTable(data, "money"); --金币
            local btype = GetNumFromJsonTable(data, "btype"); --1加 2减 （boyaacoin）
            local boyaacoin = GetNumFromJsonTable(data, "boyaacoin"); --博雅币
            local cptype = GetNumFromJsonTable(data, "cptype");
            local coupons = GetNumFromJsonTable(data, "coupons");
            local myself = PlayerManager.getInstance():myself();
            --处理积分变化
            if ctype == 1 then
                myself.chips = myself.chips + chips;
            elseif ctype == 2 then
                myself.chips = myself.chips - chips;
            end
            --处理金币变化
            if mtype == 1 then
                myself.money = myself.money + money;
                showGoldDropAnimation()
            elseif mtype == 2 then
                myself.money = myself.money - money;
            end
            --处理博雅币变化
            if btype == 1 then
                myself.boyaacoin = myself.boyaacoin + boyaacoin;
            elseif btype == 2 then
                myself.boyaacoin = myself.boyaacoin - boyaacoin;
            end
            --处理话费变化
            DebugLog("ttttt myself.coupons= " .. myself.coupons);
            if cptype == 1 then
                myself.coupons = myself.coupons + coupons;
            elseif cptype == 2 then
                myself.coupons = myself.coupons - coupons;
            end

            self.m_rootNode.boyaaText:setText(trunNumberIntoThreeOneFormWithInt(tostring(myself.coupons)));
            --updateChangeNicknameTimes( data );
            BaseInfoManager.getInstance():refreshCards();
            -- self.m_mallRef:updateUserInfo();
            GlobalDataManager.getInstance():updateScene();
            GlobalDataManager.getInstance():onRequestMyItemList(); -- 重新拉取卡片
            ProductManager.getInstance():getExchangeHistoryList(); --重新拉去兑换记录
            if self.m_rootNode and self.m_rootNode.send_php_get_rank then--兑换成功后拉去下兑换排行榜
                self.m_rootNode:send_php_get_rank();
            end
            --兑换成功展示动画
            local window = new(ExchangeSuccessWindow, self);
            window:addToRoot();
        end
    end
end

ExchangeListItem.reportExchangePropsClick = function ( self )
    -- if 0 == tonumber(self.m_ptype) and 2 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange2);
    -- elseif 0 == tonumber(self.m_ptype) and 6 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange12);
    -- elseif 0 == tonumber(self.m_ptype) and 10 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange18);
    -- elseif 0 == tonumber(self.m_ptype) and 20 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange68);
    -- elseif 0 == tonumber(self.m_ptype) and 30 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange108);
    -- elseif 0 == tonumber(self.m_ptype) and 50 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange178);
    -- elseif 0 == tonumber(self.m_ptype) and 100 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange5WCard);
    -- elseif 0 == tonumber(self.m_ptype) and 200 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchange2WCard);
    -- elseif 0 == tonumber(self.m_ptype) and 500 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchangeBuQian);
    -- elseif 1 == tonumber(self.m_ptype) and 30 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchangeXueLiu);
    -- elseif 1 == tonumber(self.m_ptype) and 98 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchangeHuanSZ);
    -- elseif 1 == tonumber(self.m_ptype) and 98 == tonumber(self.m_pamount) then
    --     umengStatics_lua(Umeng_MallExchangeLongJie);
    -- end
end


ExchangeListItem.promotionIconTable = {
    --1 hot, 2 new, 3 超值, 4 限量  [5折扣(后端未启用)]
    [1]  = "Hall/HallMall/hot.png",--"newHall/mall/mark_hot.png",
    [2]  = "Hall/HallMall/new.png",--"newHall/mall/mark_hot.png",
    [3]  = "Hall/HallMall/chaozhi.png",
    [4]  = "Hall/HallMall/tuijian.png",
    [5]  = "Hall/HallMall/dazhe.png"--"newHall/mall/mark_dazhe.png"
}

ExchangeListItem.onPhpMsgResponse = function ( self, param, cmd, isSuccess,... )
    if self.httpRequestsCallBackFuncMap[cmd] then
        self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param,...);
    end 
end 

--回调函数映射表
ExchangeListItem.httpRequestsCallBackFuncMap =
{
    [PHP_CMD_REQUEST_EXCHANGE] = ExchangeListItem.requestExchangeCallBack
};

ExchangeListItem.dtor = function(self)
 
	self:removeAllChildren();
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

ExchangeListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.mImgIcon:setFile(self.localDir);
            setImgToResSize(self.mImgIcon)
        end
    end
end

