local exchangeHistoryItem = require(ViewLuaPath.."exchangeHistoryItem");

ExchangeHistoryListItem = class(Node);

--兑换历史 元素
ExchangeHistoryListItem.ctor = function ( self, width, height, data, rootNode)

    self.mExchangeHistoryItem  = SceneLoader.load(exchangeHistoryItem);
    
    local scaleW, scaleH = width / 470, height / 120;
    publ_getItemFromTree(self.mExchangeHistoryItem, {"view_item"}):setSize(width, height);

    self:addChild(self.mExchangeHistoryItem);
    self:setSize(width, height);

    self.mIamgeUrl = data.image or "";

    local isExist, localDir = NativeManager.getInstance():downloadImage(self.mIamgeUrl);
    if isExist then
        publ_getItemFromTree(self.mExchangeHistoryItem, { "view_item", "view_infor", "img_headicon" }):setFile(localDir);
        publ_getItemFromTree(self.mExchangeHistoryItem, { "view_item", "view_infor", "img_headicon" }):setSize(84, 84);
    end

    publ_getItemFromTree(self.mExchangeHistoryItem, {"view_item", "view_infor", "text_name"}):setText((data.gname or "") .. "(数量:"..(data.num or 0)..")");
    publ_getItemFromTree(self.mExchangeHistoryItem, {"view_item", "view_infor", "text_decription"}):setText("兑换时间:" ..data.time);
    publ_getItemFromTree(self.mExchangeHistoryItem, {"view_item", "view_operator", "text_status"}):setText("状态:" .. data.status);

    publ_getItemFromTree(self.mExchangeHistoryItem, {"view_item", "view_operator", "btn_1"}):setOnClick(self, function ( self )
        -- body
        require("MahjongPopu/ExchangeGoodsWindow"); 
        local exchangeGoodsWindow = new(ExchangeGoodsWindow);
        exchangeGoodsWindow:setPhoneNum(data.phone);
        exchangeGoodsWindow:setAddress(data.address);
        exchangeGoodsWindow:setName(data.name);
        exchangeGoodsWindow:setPhoneEnable(false);
        exchangeGoodsWindow:setNameEnable(false);
        exchangeGoodsWindow:setAddressEnable(false);
        exchangeGoodsWindow:setWindowName("兑换信息查看");
        exchangeGoodsWindow:setOKBtnName("确 定");
        exchangeGoodsWindow:setWarningVisible(false);
        exchangeGoodsWindow:setOKCallBack(self, function()
            exchangeGoodsWindow:hideWnd();
            exchangeGoodsWindow = nil;
        end);
        rootNode:addChild(exchangeGoodsWindow);
        exchangeGoodsWindow:showWnd();
    end);

    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    if PlatformConfig.platformWDJ == GameConstant.platformType or 
       PlatformConfig.platformWDJNet == GameConstant.platformType then 
       publ_getItemFromTree(self.mExchangeHistoryItem,{"view_item"}):setFile("Login/wdj/Hall/HallMall/exchangeList_item_bg.png");
    end


end

ExchangeHistoryListItem.dtor = function ( self )
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

ExchangeHistoryListItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.mIamgeUrl then
            local isExist, localDir = NativeManager.getInstance():downloadImage(self.mIamgeUrl);
            if isExist then
                publ_getItemFromTree(self.mExchangeHistoryItem, { "view_item", "view_infor", "img_headicon" }):setFile(localDir);
                publ_getItemFromTree(self.mExchangeHistoryItem, { "view_item", "view_infor", "img_headicon" }):setSize(84, 84);
            end
        end
    end
end


