--[[
	className    	     :  FriendNoticeItem
	Description  	     :  To wrap the Listview of the friend notice.
	last-modified-date   :  Dec. 5 2013
	create-time 	   	 :  Oct.31 2013
	last-modified-author :  ClarkWu
	create-author        :　ClarkWu
]]
FriendNoticeItem = class(Node);

--[[
	function name	   : FriendNoticeItem.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
						 data    -- list数据
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
FriendNoticeItem.ctor = function ( self, data )
	if not data then
		return;
	end
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self:setPos(CreatingViewUsingData.friendNoticeView.bg.x, CreatingViewUsingData.friendNoticeView.bg.y);
	self:setSize(CreatingViewUsingData.friendNoticeView.bg.w,CreatingViewUsingData.friendNoticeView.bg.h);
	
	data.h = CreatingViewUsingData.friendNoticeView.bg.h;

	self.mid = data.mid;
	self.friendRef = data.friendRef;
	self.notice_key = data.notice_key;

 	local pic_str = CreatingViewUsingData.commonData.regularJudge;
 	local imgPic = data.smallImg;
 	local tempImgPic = string.find(imgPic,pic_str);
 	local imgPic_name = CreatingViewUsingData.commonData.girlPic;

 	if tempImgPic ~= nil then 
	 	imgPic_name = string.sub(imgPic,string.find(imgPic,pic_str));
 	end

 	if  imgPic_name == CreatingViewUsingData.commonData.boyPic or imgPic_name == CreatingViewUsingData.commonData.girlPic then 
 	 	self.album_image = UICreator.createImg(CreatingViewUsingData.commonData.commonSepearate .. imgPic_name); 
 	else
        local isExist , localDir = NativeManager.getInstance():downloadImage(imgPic);
        self.localDir = localDir;
        if not isExist then
            localDir = CreatingViewUsingData.commonData.girlPicLocate;
        end
 		self.album_image = UICreator.createImg(localDir);
 	end

	local coord = CreatingViewUsingData.friendNoticeView.albumImg;
	self.album_image:setPos(coord.x,coord.y);
	self.album_image:setSize(coord.w,coord.h);
	coord = CreatingViewUsingData.friendNoticeView.albumNameText;
	local album_text = UICreator.createText(stringFormatWithString(data.name,kMaxNameLength),coord.x,coord.y,coord.w,coord.h,coord.align,coord.size,coord.r,coord.g,coord.b);

	local x,_ = album_text:getPos();
	local w,_ = album_text:getSize();

	coord = CreatingViewUsingData.friendNoticeView.illustrateText;
 	local shuoming = UICreator.createText(data.action,(x+w)+coord.x,coord.y,coord.w,coord.h,coord.align,coord.size,coord.r,coord.g,coord.b);

 	coord = CreatingViewUsingData.friendNoticeView.ignoreInviteBtn;
	local ignoreBtn = UICreator.createTextBtn(CreatingViewUsingData.commonData.confirmBtnBg.fileName,coord.x,coord.y,coord.str,coord.size,coord.r,coord.g,coord.b);
	ignoreBtn:setOnClick(self,self.onIgnoreClick);

	coord = CreatingViewUsingData.friendNoticeView.acceptInviteBtn;
 	local agreeBtn = UICreator.createTextBtn(CreatingViewUsingData.commonData.cancelBg.fileName,coord.x,coord.y,coord.str,coord.size,coord.r,coord.g,coord.b);
 	agreeBtn:setOnClick(self,self.onAgreeClick);


 	coord = CreatingViewUsingData.friendNoticeView.split;
	local friendLine = UICreator.createImg(coord.fileName);
	friendLine:setPos(coord.x,coord.y);

	self:addChild(self.album_image);
	self:addChild(album_text);
	self:addChild(shuoming);
	self:addChild(ignoreBtn);
	self:addChild(agreeBtn);
	self:addChild(friendLine);

 	self.active = true;
	self:setEventTouch(self, function ( self, finger_action,x, y,drawing_id_first,drawing_id_current )
		if kFingerDown == finger_action then
		    self.lastY = y;
			self.active = true;
		elseif kFingerMove == finger_action then
		    if math.abs(y - self.lastY) > data.h/2 then
				self.active = false;
			end
		end
	end);
end

--[[
	function name	   : FriendNoticeItem.dtor
	description  	   : Destruct a class.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
FriendNoticeItem.dtor = function ( self )
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
	self:removeAllChildren();
end

---------------------------------------------------------------回调函数-----------------------------------------------------------------------------------
--[[
	function name	   : FriendNoticeItem.callEvent
	description  	   : The callBack of java.To download images.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
FriendNoticeItem.nativeCallEvent = function(self, _param, _detailData)
    if _param == kDownloadImageOne then
        if _detailData == self.localDir then
            self.album_image:setFile(self.localDir);
        end
    end
end

--------------------------------------------------------------按键监听-------------------------------------------------------------------------------------
--[[
	function name	   : FriendNoticeItem.onIgnoreClick
	description  	   : The  click event of ignore.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013
	create-time  	   : Oct.31 2013
]]
FriendNoticeItem.onIgnoreClick = function(self)
	umengStatics_lua(kUmengIgnoreAddFriend);
	if self.active then 
		FriendDataManager.getInstance():setCallBack(self.friendRef,self.friendRef.OnIgnoreOrAgreeEvent);
		FriendDataManager.getInstance():OnDeleteFriendNotice(self.notice_key);
	end
end

--[[
	function name	   : FriendNoticeItem.onAgreeClick
	description  	   : The click event of agree.
	param 	 	 	   : self
	last-modified-date : Dec. 5 2013{{mid="",name="",type="",notice_key="",action="",smallImg=""}};
	create-time  	   : Oct.31 2013
]]
FriendNoticeItem.onAgreeClick = function(self)
	umengStatics_lua(kUmengAgreeAddFriend);
	if self.active then
		local notice = FriendDataManager.getInstance():selectFriendNoticesByMid(self.mid);
		FriendDataManager.getInstance():addFriendToServer(notice.mid,notice.name,PlayerManager.getInstance():myself().nickName,0);
		FriendDataManager.getInstance():deleteFriendNoticesByMid(self.mid);
		self.friendRef:OnIgnoreOrAgreeEvent();
		FriendDataManager.getInstance():onRequestAllFriends();
	end
end


