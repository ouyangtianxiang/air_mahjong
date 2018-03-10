local HongBaoViewOpenning = class(SCWindow);

require("MahjongRoom/GameResult/ShareWindow");
local number2Pin_map = require("qnPlist/number2Pin")




HongBaoViewOpenning.ctor = function ( self, hongbaoId)
	self.hongbaoId = hongbaoId

    self:set_pop_index(new_pop_wnd_mgr.get_instance():get_min_wnd_idx());

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
	EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.openedCallback);
	----------------
	self.bg = UICreator.createImg("Hall/hongbao/hongbaoBg.png",0,0);
	self.bg:setAlign(kAlignCenter)
	self:addChild(self.bg)
	
	self:setWindowNode( self.bg );
	self.cover:setEventTouch(self , function (self, finger_action, x, y, drawing_id_first, drawing_id_current )
		--if finger_action == kFingerUp then
		--	EventDispatcher.getInstance():dispatch(HongBaoModel.HongBaoMsgs);
		--end
	end);

	local dirs = {}
	for i=1,5 do
		table.insert(dirs,string.format("Hall/hongbao/gold%d.png", i))
	end
	self.m_golds = UICreator.createImages(dirs)
	self.bg:addChild(self.m_golds)
	self.m_golds:setAlign(kAlignCenter)
	self.m_golds:setPos(0,120)

	self.anim_index = 1;
	local anim = self.m_golds:addPropTranslate(0, kAnimRepeat, 100, 0, 0, 0, 0, 0);
	anim:setEvent(self, self.showGoldAnimOnTime);

	HongBaoModel.getInstance():qiangHongBaoRequest(self.hongbaoId)
	self:createCloseBtn()

	--self.resultIsReturn = false
	local liveTime = 10*1000--  10秒
    local anim = self:addPropTranslate(0,kAnimNormal,liveTime,0,0,0,0,0)
    anim:setDebugName("hongbao open alive time anim");
    anim:setEvent(self,function ( self )
    	if not self:checkAddProp(0) then
    		self:removeProp(0)
    	end
    	self:overtime()
    end)

	self:showWnd();
end

HongBaoViewOpenning.overtime = function ( self )
	if self.m_golds then
		if not self.m_golds:checkAddProp(0) then
			self.m_golds:removeProp(0)
		end
		self.m_golds:removeFromSuper()
		self.m_golds = nil		
		--self:createCloseBtn()
		if self.hongbao then 
			self:createHead(self.hongbao.imgUrl,self.hongbao.sex,self.hongbao.name,self.hongbao.tipsStr or "")
		else 
			if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    self:createHead("Login/yx/Commonx/default_woman.png",kSexMan,"","");
			else
				self:createHead("default_man",kSexMan,"","")
			end
		end 
		self:createTipText()
		self:createBottomBtn()	 
	end 
end

HongBaoViewOpenning.showGoldAnimOnTime = function ( self )
	if self.anim_index >= 4 then
		self.anim_index = 0
	else
		self.anim_index = self.anim_index + 1
	end 

	self.m_golds:setImageIndex(self.anim_index);
end

--------只有当server返回抢红包结果 且 php返回发红包者的头像地址,姓名,性别详细信息  才打开红包
HongBaoViewOpenning.openedCallback = function ( self, status, data )

	if status == HongBaoModel.qiangHongBaoSuccess then 
		if data.hongbaoId ~= self.hongbaoId then 
			return 
		end  

		self.hongbao = data
	elseif status == HongBaoModel.qiangHongBaoFail then 
		if data.hongbaoId ~= self.hongbaoId then 
			return 
		end
		--self:removeProp(0)
		self.hongbao = data
	elseif status == HongBaoModel.getUserInfoDone then 
		if self.hongbao and self.hongbao.sendUid == data then
			self.userinfo = HongBaoModel.getInstance():getUserInfo(self.hongbao.sendUid)
		end 
	elseif status == HongBaoModel.recieveNewHongBao then --又来了一个新红包
		--self:hideWnd()
		self:overtime()
--	elseif status == HongBaoModel.exchangeHongBaoEvent then --购买了红包道具
--		self:showSendHongbaoView()
	end 


	if self.m_golds and self:checkResultIsAllback() then 
		if not self:checkAddProp(0) then
			self:removeProp(0)
		end 
		if not self.m_golds:checkAddProp(0) then
			self.m_golds:removeProp(0)
		end 
		self.m_golds:removeFromSuper()
		self.m_golds = nil

		self:createHead(self.userinfo.imgUrl,self.userinfo.sex,self.userinfo.name,self.hongbao.tipsStr or "")
		
		if self.hongbao.money and self.hongbao.money > 0 then 
			self:createTipText(1,self.hongbao.money)
			self:createBottomBtn(1)
		else
			self:createTipText()
			self:createBottomBtn()
		end 
		
	end 
end

HongBaoViewOpenning.checkResultIsAllback = function ( self )

	if not self.hongbao then 
		return false
	end 

	if not self.userinfo then
		self.userinfo = HongBaoModel.getInstance():getUserInfo( self.hongbao.sendUid )
	end 

	if self.hongbao and self.userinfo and self.userinfo.name ~= "" then 
		--if self.hongbao.cmdRequest == MSG_CMD_NOTIFY_RED_SUCC then 
				
		--end 
		return true
	end 

	return false
end


HongBaoViewOpenning.dtor = function( self )
	DebugLog("NewHongBaoEntryView.dtor")
	if not self:checkAddProp(0) then 
		self:removeProp(0)
	end 
	if self.m_golds and not self.m_golds:checkAddProp(0) then
		self.m_golds:removeProp(0)
	end
	self.hongbao = nil 
	self.userinfo = nil 

	EventDispatcher.getInstance():unregister(HongBaoModel.HongBaoMsgs, self, self.openedCallback);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end



----------------------------button actions------------------------------------------------------------
function HongBaoViewOpenning.sendHongBao( self )
	-- body
	--check send condition

	--检查发红包条件
	
	if not HongBaoModel.getInstance():checkIsSuitSendCondition() then
		return
	end 
	--检查红包道具数量
	local hongbaoNum = GameConstant.changeNickTimes.rednum
	if hongbaoNum <= 0 then 
		--check 道具商城是否有该道具
		if not ProductManager.getInstance():getExchangeListItem(ItemManager.HONG_BAO_CID) then 
			Banner.getInstance():showMsg("红包道具不存在,请去商城界面查看购买！")
			return 
		end 

		require("MahjongCommon/ExchangePopu");
		self.exchangePopu = new(ExchangePopu, ItemManager.HONG_BAO_CID, self );
		self.exchangePopu:setOnWindowHideListener( self, function( self )
			self.exchangePopu = nil;
		end);
		self.exchangePopu:showWnd();
	else 
		self:showSendHongbaoView()
	end 
end

function HongBaoViewOpenning.share( self )

	--screen shot
	HongBaoViewManager.getInstance():showShareWindowView()
end


function HongBaoViewOpenning.showSendHongbaoView(self)
	HongBaoViewManager.getInstance():showHongBaoSendView()
	self:hideWnd(true)
end 
--------------------------------------------------event callback--------------------------------------
HongBaoViewOpenning.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(self.headImg,"Commonx/headMask.png",self.localDir)
        end
    end
end





-------------------------view create func---------------------------------------------------------------
function HongBaoViewOpenning.createCloseBtn( self )
	local closeBtn = UICreator.createBtn2("Commonx/close_btn.png","Commonx/close_btn_disable.png",-20,-20,self,function ( self )
		self:hideWnd()
	end)
	closeBtn:setAlign(kAlignTopRight)
	self.bg:addChild(closeBtn)
end

function HongBaoViewOpenning.createHead( self, imageUrl, sex, name,desc )
	self.headBg = UICreator.createImg("Commonx/headBg.png",0,-175)
	self.headBg:setAlign(kAlignCenter)
	self.bg:addChild(self.headBg)

	self.headBg:addPropScaleSolid(0,1.15,1.15,kCenterDrawing)

	self.headImg = UICreator.createImg("Commonx/blank.png",0,0)
	self.headImg:setAlign(kAlignCenter)
	self.headBg:addChild(self.headImg)
	-----------------------imageUrl  sex
	local isExist , localDir = NativeManager.getInstance():downloadImage(imageUrl);
	self.localDir = localDir; -- 下载图片
    if not isExist then
        if tonumber(kSexMan) == tonumber(sex) then
            localDir = "Commonx/default_man.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_man.png";
			end
	    else
            localDir = "Commonx/default_woman.png";
            if PlatformConfig.platformYiXin == GameConstant.platformType then 
			    localDir = "Login/yx/Commonx/default_woman.png";
			end
	    end
    end
	setMaskImg(self.headImg,"Commonx/headMask.png",localDir)
	
	self.headNameText = UICreator.createText(name,0,-100,0,0,kAlignCenter,26, 0xff, 0xff, 0xff)
	self.headNameText:setAlign(kAlignCenter)
	self.bg:addChild(self.headNameText)


	self.descText = UICreator.createText(desc,0,-60,0,0,kAlignCenter,22, 0xff, 0xc4, 0x95)
	self.descText:setAlign(kAlignCenter)
	self.bg:addChild(self.descText)
end

function HongBaoViewOpenning.createTipText( self,tipType,value,text )
	local textBg = UICreator.createImg("Hall/hongbao/textBg.png",0,0)
	textBg:setAlign(kAlignCenter)
	self.bg:addChild(textBg)

	if tipType and tipType == 1 then --抢红包成功
		self.textTip = new(Node)
		if self.hongbao and self.hongbao.hongbaoType and self.hongbao.hongbaoType == 2 then 
			self:setMoneyNode("Hall/HallMall/telephone_fare.png",value,self.textTip,2)
		else 
		    self:setMoneyNode("Hall/hongbao/gold_small.png",value,self.textTip,1)
		end 
	else
		self.textTip = UICreator.createText(text or "手慢了，红包抢完了！",0,0,0,0,kAlignCenter,30, 0xff, 0xff, 0xff)
	end
	self.textTip:setAlign(kAlignCenter)	
	textBg:addChild(self.textTip)
end


function HongBaoViewOpenning.setMoneyNode( self,imgFile,value,node,vtype )

	intStr = tostring(value)
	DebugLog(""..intStr)
	local moneyNode = node or new(Node)
	moneyNode:removeAllChildren()

	local preImg = nil--
	local w,h = 0,0
	local x,y = 0,0


	preImg = UICreator.createImg( imgFile , x,y )
	preImg:setAlign(kAlignLeft)
	moneyNode:addChild(preImg)
	x = x + preImg.m_res.m_width
	h = math.max(h, preImg.m_res.m_height)	


	for i = 1,string.len(intStr) do 
		local img = UICreator.createImg( number2Pin_map[string.sub(intStr,i,i)..".png"] , x, y );
		img:setAlign(kAlignLeft)
		moneyNode:addChild(img)
		x = x + img.m_res.m_width;
		h = math.max(h, img.m_res.m_height)
	end 
	--万金币

	local img = nil--
	if vtype and vtype == 2 then 
		img = UICreator.createImg( number2Pin_map["huafei.png"] , x,y )
	else 
		img = UICreator.createImg( number2Pin_map["jinbi.png"] , x,y )
	end 

	moneyNode:addChild(img)
	img:setAlign(kAlignLeft)
	x = x + img.m_res.m_width
	h = math.max(h, img.m_res.m_height)	

	moneyNode:setSize(x,h)
	return moneyNode	
end

function HongBaoViewOpenning.createBottomBtn( self,buttonType )
	local createBtnFunc = function ( self, imgName, x, y, obj, func, textStr)
		local btn = UICreator.createBtn(imgName,x or 0,y or 0,obj, func)
		btn:setAlign(kAlignBottom)
		self.bg:addChild(btn)
		if textStr then 
			local btntext = UICreator.createText(textStr, 0, -4, 0, 0, kAlignCenter, 28, 0xff, 0xff, 0xdc);
			btntext:setAlign(kAlignCenter)	
			btn:addChild(btntext)		
		end
		return btn
	end

	if buttonType and buttonType == 1 then --抢红包成功  两个按钮  来一发+分享
		self.shareBtn 	= createBtnFunc(self,"Commonx/green_small_btn.png",-90 ,55,self,self.share,"分享")
		local sendBtn 	= createBtnFunc(self,"Commonx/yellow_small_btn.png",90  ,55,self,self.sendHongBao,"发红包")
		if not PlatformFactory.curPlatform:needToShareWindow() then 
			self.shareBtn:setVisible(false);
			sendBtn:setPos(0,55);
		end
		--DrawingBase.addPropScaleSolid = function(self, sequence, scaleX, scaleY, center, x, y)
		--shareWechatBtn:addPropScaleSolid(0,0.8,0.8,kCenterDrawing)
	else--抢红包失败  来一发
		createBtnFunc(self,"Commonx/yellow_bg_wide_btn.png",0,55,self,self.sendHongBao,"我来发一个")
	end 
end

return HongBaoViewOpenning

