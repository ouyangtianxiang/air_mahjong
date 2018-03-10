local exchangeSuccessLayout = require(ViewLuaPath.."exchangeSuccessLayout");
local blurW = require('libEffect/shaders/blurWidget')

ExchangeSuccessWindow = class(SCWindow);

ExchangeSuccessWindow.m_data = {};


ExchangeSuccessWindow.ctor = function ( self, delegate)
    DebugLog("[ExchangeSuccessWindow :ctor]");

 

    self.delegate = delegate;
    self.m_layout = SceneLoader.load(exchangeSuccessLayout);
    self.m_layout:setLevel(1000);
    self:addChild(self.m_layout);
    
    self:setWindowNode(self.m_layout);
    self:showWnd();
    self:setCoverEnable(true);
    --self:setCoverTransparent();
    --self.cover:setTransparency( 0 );


    local bg = publ_getItemFromTree(self.m_layout, {"bg"});
    self.img_light = publ_getItemFromTree(bg, {"v", "img_light"});
    self.goodsName = publ_getItemFromTree(bg, {"v", "img_bottom", "t"});
    self.goodsImg = publ_getItemFromTree(bg, {"v", "img_award"});
    self.goodsName:setText(delegate.m_name);
    self.goodsImg:setFile("Hall/HallMall/coin1.png")
    
    self.goodsImg:setFile(delegate.localDir)
    local x, y = delegate.mImgIcon:getSize();
    local scale = 1.5;
    self.goodsImg:setSize(x*scale, y*scale);
    
    DebugLog("size x:"..x.." y:"..y);

    --背光转
    self.img_light.seqIdx = 1;
    local prop =  self.img_light:addPropRotate(
                                        self.img_light.seqIdx,
                                        kAnimRepeat,
                                        5000,200,0,
                                        360,
                                        kCenterDrawing);
    local btn_share = publ_getItemFromTree(self.m_layout, {"bg", "btn"});
    btn_share:setOnClick(self, function (self)
        math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
	    local rand = math.random();
	    local index = math.modf( rand*1000%6 );
	    local player = PlayerManager.getInstance():myself();

	    local dd = {};
	    dd.title = PlatformFactory.curPlatform:getApplicationShareName();
	    dd.content = kShareTextContent[ index or 1 ];
	    dd.username = player.nickName or "川麻小王子";
	    dd.url = GameConstant.shareMessage.url or ""

        local data = {name = self.delegate.m_name, imgPath = self.delegate.localDir};
        local shareData = {d = data, share = dd , t = GameConstant.shareConfig.exchange, b = true};
        global_screen_shot(shareData);
        self:hideWnd();
    end);
    Loading.hideLoadingAnim();
--    --背景模糊
    self.blurSprite,self.tex,self.texUnit = blurW.createBlurWidget(GameConstant.curGameSceneRef,{intensity = 2 })
    self:getWidget():add(self.blurSprite)

end

ExchangeSuccessWindow.dtor = function (self)
    DebugLog("[ExchangeSuccessWindow :dtor]");
    
--    --背景模糊
    self:getWidget():remove(self.blurSprite)
    blurW.removeBlur(self.blurSprite,self.tex,self.texUnit,self:getWidget())
    self.blurSprite = nil 
    self.tex        = nil
    self.texUnit    = nil 

    self.img_light:removeProp(self.img_light.seqIdx);
end