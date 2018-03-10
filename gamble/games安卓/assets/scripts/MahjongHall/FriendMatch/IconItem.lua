
IconItem = class(Node);

function IconItem:ctor( data )
	DebugLog("IconItem:ctor")
	self._data = data
	self:initView( data )
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	-- self._obj = obj
	-- self._func = func
	
end

function IconItem:dtor()
	DebugLog("IconItem:dtor")
	-- self._obj = nil 
	-- self._func = nil
	self._mid = nil 
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end


function IconItem:initView( data )

	self._mid = data.mid 

	local headBtn = UICreator.createBtn("Hall/friend/icon_1.png")
	self:addChild(headBtn)

	headBtn:setOnClick(self,self.onClickedBtn)

	self.m_headImg = UICreator.createImg("Commonx/blank.png",0,0)
	self.m_headImg:setAlign(kAlignCenter)
	headBtn:addChild(self.m_headImg)
	
	self.mHeadIconDir = "";
	self:setHeadIcon(data.small_image, data.sex)
	--addPropScaleSolid = function(self, sequence, scaleX, scaleY, center, x, y)
	headBtn:addPropScaleSolid(0,0.67,0.67,kAlignTopLeft)
	--UICreator.createText = function ( str, x, y, width,height, align ,fontSize, r, g, b )
	local namestr = data.alias;
	if not namestr or string.len(namestr) <= 0 then
		namestr = data.mnick;
	end	

	local text = UICreator.createText(stringFormatWithString(namestr,6,true),0,0,80,40,kAlignCenter,24, 0x4b, 0x2b, 0x1c)
	text:setAlign(kAlignTopLeft)
	text:setPos(0,80)
	self:addChild(text)

	local checkBoxBg = UICreator.createImg("Hall/friend/icon_3.png")
	checkBoxBg:setLevel(100)
	headBtn:addChild(checkBoxBg)

	self.selectedImg = UICreator.createImg("Hall/friend/icon_2.png")
	self.selectedImg:setLevel(101)
	headBtn:addChild(self.selectedImg)
	self.selectedImg:setVisible(false)

	self:setSize(110,120)

	local visible = self._data._isCheck
	self.selectedImg:setVisible(visible)
end

function IconItem:onClickedBtn( )
	local visible = (not self.selectedImg:getVisible())

	self.selectedImg:setVisible(visible)

	-- if self._obj and self._func then 
	-- 	self._func(self._obj,self._mid,visible)
	-- end 
	if self._data then 
		self._data._isCheck = visible
	end 
end


IconItem.setHeadIcon =  function ( self, url, sex)
    local isExist, localDir = NativeManager.getInstance():downloadImage(url);
	self.mHeadIconDir = localDir;
    
    if not isExist then -- 图片已下载
    	if tonumber(sex) == 0 then
            localDir = "Commonx/default_man.png";
	    else
            localDir = "Commonx/default_woman.png";
    	end
    end
    setMaskImg(self.m_headImg,"Hall/friend/icon_4.png",localDir)

    --self.m_headImg:setFile(localDir);
    --self.m_headImg:setSize(84,84);
end

IconItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.mHeadIconDir then
        	setMaskImg(self.m_headImg,"Hall/friend/icon_4.png",self.mHeadIconDir)
        end
    end
end


