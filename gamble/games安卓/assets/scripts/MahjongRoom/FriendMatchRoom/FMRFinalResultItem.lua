local fmrFinalResultItem = require(ViewLuaPath.."fmrFinalResultItem");

FMRFinalResultItem = class(Node)

function FMRFinalResultItem:ctor(data)
	-- body
	self:initView(data)

	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
end

function FMRFinalResultItem:dtor()
	-- body
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
end

function FMRFinalResultItem:initView(data)
	self._layout = SceneLoader.load(fmrFinalResultItem);
	self:addChild(self._layout)

	self.bg      = publ_getItemFromTree(self._layout,{"bg"})
	self.headBg  = publ_getItemFromTree(self._layout,{"bg","headBg"})
	self.headImg = publ_getItemFromTree(self._layout,{"bg","headBg","head"})

	self.headBg:addPropScaleSolid(0,0.8,0.8,kAlignCenter)

	self.nameText  = publ_getItemFromTree(self._layout,{"bg","name"})
	self.scoreText = publ_getItemFromTree(self._layout,{"bg","score"})

	if data.isBigWin then 
		local logo = UICreator.createImg( "Hall/friendMatch/win.png", 0, 0)
		self.bg:addChild(logo)
		logo:setAlign(kAlignRight)
	end 
--
	self.nameText:setText(stringFormatWithString(data.name,18,true))
	if data.money >= 0 then 
		self.scoreText:setText("+"..data.money)
	else
		self.scoreText:setText(""..data.money)
	end 

    local isExist , localDir = NativeManager.getInstance():downloadImage(data.small_image);
	self.localDir = localDir; -- 下载图片
    if not isExist then
        if tonumber(kSexMan) == tonumber(data.sex) then
            localDir = "Commonx/default_man.png";
	    else
            localDir = "Commonx/default_woman.png";
	    end
    end
	setMaskImg(self.headImg,"Hall/friend/icon_4.png",localDir)
end

FMRFinalResultItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
        	setMaskImg(self.headImg,"Hall/friend/icon_4.png",self.localDir)
        end
    end
end