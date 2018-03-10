--local friendAddWindow = require(ViewLuaPath.."friendAddWindow");
--require("MahjongHall/HongBao/HongBaoModel")
local number3Pin_map = require("qnPlist/number3Pin")

HongBaoSendView = class(SCWindow);


HongBaoSendView.ctor = function ( self)

	--UICreator.createImg = function ( imgDIr, x, y ,leftWidth, rightWidth, topWidth, bottomWidth)
	self.bg = UICreator.createImg("Commonx/userinfobg.png",0,0,40,40,40,40);
	self.bg:setAlign(kAlignCenter)
	self.bg:setSize(465,575)
	self:addChild(self.bg)
	--self.lightBg:addPropScaleSolid(0,3.0,3.0,kCenterDrawing)
	--self.lightBg:addPropRotate(1,kAnimRepeat,4500,0,0,360,kCenterDrawing)
	----------------
	self:setWindowNode( self.bg );
	self.cover:setEventTouch(self , function (self)
	end);
	-------------
	local closeBtn = UICreator.createBtn2("Commonx/close_btn.png","Commonx/close_btn_disable.png",-20,-20,self,function ( self )
		self:hideWnd()
	end)
	closeBtn:setAlign(kAlignTopRight)
	self.bg:addChild(closeBtn)
	--------内框
	local innerFrame = UICreator.createImg("Commonx/innerBg.png",0,0,20,20,20,20);
	innerFrame:setSize(375,300)
	innerFrame:setAlign(kAlignTop)
	innerFrame:setPos(0,45)
	self.bg:addChild(innerFrame)

	---顶部文字提示
	local textTip = UICreator.createText("选择红包金币数量",20,30,0,0,kAlignCenter,30, 0x4b, 0x2b, 0x1c)
	innerFrame:addChild(textTip)
	--function(self, width, height, bgImage, fgImage, buttonImage, leftWidth, rightWidth, topWidth, bottomWidth)
	
	--滑动选择
	self.sliderWidth = 310
	self.moneySlider = new(Slider,self.sliderWidth,34,"Hall/task/progress_bg.png","Hall/task/progress.png","Hall/hongbao/sliderBtn.png",15,15,5,10);
	--setProgress  getProgress
	self.moneySlider:setOnChangeOver(self,self.changeMoney)
	self.moneySlider:setAlign(kAlignCenter)
	self.moneySlider:setPos(0,-10)
	
	innerFrame:addChild(self.moneySlider)

	----红包金额提示
	self.moneyBg = UICreator.createImg("Hall/hongbao/tips.png",0,65)
	self.moneyBg:setAlign(kAlignCenter)
	innerFrame:addChild(self.moneyBg)
	local moneyIcon = UICreator.createImg("Hall/hongbao/gold_small.png",20,6)
	moneyIcon:setAlign(kAlignLeft)
	--moneyIcon:setPos(20,0)
	self.moneyBg:addChild(moneyIcon)
	
	local percent = 0
	self.curMoney,percent = self:getLastMoneyAndPercent()
	self.moneyNode = setMoney2Node(self.curMoney)
	self.moneyNode:setAlign(kAlignLeft)
	self.moneyNode:setPos(75,6)
	self.moneyBg:addChild(self.moneyNode)

	self.moneySlider:setProgress(percent)

	--红包文字祝福语
	local sendText = HongBaoModel.getInstance():getConfigMsg() or "恭喜发财,大吉大利"
	self.hongbaoText = UICreator.createText(sendText,0,175,0,0,kAlignCenter,30, 0xcc, 0x44, 0x00)
	self.bg:addChild(self.hongbaoText)
	self.hongbaoText:setAlign(kAlignBottom)

	--发红包按钮
	local sendBtn = UICreator.createBtn("Commonx/red_big_wide_btn.png",0,55,self, self.sendHongbao)
	sendBtn:setAlign(kAlignBottom)
	self.bg:addChild(sendBtn)

	local btntext = UICreator.createText("发红包", 0, -4, 0, 0, kAlignCenter, 36, 0xff, 0xff, 0xdc);
	btntext:setAlign(kAlignCenter)	
	sendBtn:addChild(btntext)		


	self:showWnd();
end

HongBaoSendView.getLastMoneyAndPercent = function ( self )
	local selectConfig = HongBaoModel.getInstance():getMoneySelectConfig()

	local lastSendMoney = g_DiskDataMgr:getAppData('lastSendMoney',0)--记录的上次发放的钱

	local curMax = HongBaoModel.getInstance():getMaxSendMoneyConfigIndex()--当前所能发的红包的最大额度 下标

	for i=curMax,1,-1 do
		if lastSendMoney >= selectConfig[i] then 
			return selectConfig[i],(i-1)/(#selectConfig - 1)
		end
	end
	return selectConfig[1],0
	--
end

HongBaoSendView.sendHongbao = function ( self )
	g_DiskDataMgr:setAppData('lastSendMoney',self.curMoney)
	HongBaoModel.getInstance():requestSendHongbao(self.curMoney,self.hongbaoText:getText())
	self:hideWnd()
end

HongBaoSendView.changeMoney = function ( self )
	local progress = self.moneySlider:getProgress()
	local selectConfig = HongBaoModel.getInstance():getMoneySelectConfig()
	local perCount = #selectConfig - 1
	if perCount <= 0 then 
		error("hongbao money selected config error! please check!")
	end
	local per = math.modf(100 / perCount )
	local integer,decimal  =  math.modf(progress*100/per)
	if decimal >= 0.5 then 
		integer = integer + 1
	end 


	local curMax = HongBaoModel.getInstance():getMaxSendMoneyConfigIndex()
	if integer + 1 >= curMax then 
		integer = curMax - 1
	end 

	self.moneySlider:setProgress(integer / perCount)
	self:updateMoneyTipNode(selectConfig[integer+1],integer)
end

HongBaoSendView.updateMoneyTipNode = function( self,value,integer )
	self.curMoney = value
	setMoney2Node(value,self.moneyNode)
end


HongBaoSendView.dtor = function( self )
	DebugLog("HongBaoSendView.dtor")

	self:removeAllChildren();
end

