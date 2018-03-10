local DingQueViewPin_map = require("qnPlist/DingQueViewPin")


SelectQueView = class(Node);

SelectQueView.selectCoor = {0,0};

SelectQueView.coor = {
	[kSeatMine] = {220, 308, 140}, -- x, y, dist
	[kSeatRight] = {625, 190}, -- x, y
	[kSeatTop] = {375, 66}, -- x, y
	[kSeatLeft] = {118, 190}, -- x, y
};

SelectQueView.type = {
	[1] = kWanMahjongType,
	[2] = kTongMahjongType,
	[3] = kTiaoMahjongType
};

SelectQueView.dirQueBig = {
	[kWanMahjongType] = DingQueViewPin_map["hasSelect_0.png"],
	[kTongMahjongType] = DingQueViewPin_map["hasSelect_1.png"],
	[kTiaoMahjongType] = DingQueViewPin_map["hasSelect_2.png"]
}

SelectQueView.ctor = function (self)
	self.flashAnim = nil;
	self.selectImgs = {}; -- 自己位置 万通条三张图片
	self.dingqueImgs = {}; -- 其他三张三张定缺图片
	self.myQueImg = nil; -- 自己选定缺后的图片

	self.clickNeedTimes = 1
end

SelectQueView.dtor = function (self)
	delete(self.flashAnim);
	self.flashAnim = nil;
	self:removeAllChildren();
	self.selectImgs = {};
	self.dingqueImgs = {};
end

-- 设置选缺回调函数
SelectQueView.setClickCallback = function ( self, obj, fun )
	self.obj = obj;
	self.callback = fun;
end

SelectQueView.setClickable = function ( self, bClick )
	for k,v in pairs(self.selectImgs) do
		v:setEnable(bClick);
	end
end



-- 选缺时 响应方法
SelectQueView.onClick = function ( self, selectType )
	DebugLog("SelectQueView.onClick  0 万 1 桶 2 条")
	DebugLog("selectType:" .. tostring(selectType))
	if RoomScene_instance and RoomScene_instance.mahjongManager then
		maxNumType = RoomScene_instance.mahjongManager:getMaxNumsTypeOfMineInHandCards()
		DebugLog("maxNumType:" .. tostring(maxNumType))
		DebugLog("self.clickNeedTimes:" .. tostring(self.clickNeedTimes))
		if maxNumType and selectType == maxNumType and self.clickNeedTimes > 1 then
			self.clickNeedTimes = self.clickNeedTimes - 1
			return
		end
	end

	if self.callback then
		self.callback(self.obj, selectType);
		self:setClickable(false);
	end
	self:selectComplite(selectType);
end

-- 显示选缺界面
-- defaultType 推荐的选缺们：0 万 1 桶 2 条
SelectQueView.showSelectQue = function (self, defaultType)
	self.clickNeedTimes = 2
	if #self.selectImgs < 3 then -- 还未创建
		for i = 1,3 do
			local x , y = self.selectCoor[1] + (i - 1) * (158 + 60) , self.selectCoor[2];
			local selectImg = UICreator.createBtn(DingQueViewPin_map[string.format("select_%d.png",i-1)],x,y);
			self:addChild(selectImg);
			selectImg:setOnClick(self , function(self)
				SelectQueView.onClick(self, SelectQueView.type[i]);
			end);

			table.insert(self.selectImgs, selectImg);

			local selectQueingDir ;

			if i == kSeatMine or i == kSeatTop then
				selectQueingDir = DingQueViewPin_map["selectQueingH.png"];
			else
				selectQueingDir = DingQueViewPin_map["selectQueingV.png"];
			end
			-- 除自己外的其他3加定缺图片
			local xuanQueImg = UICreator.createImg( selectQueingDir, self.coor[i][1] , self.coor[i][2] );
			self:addChild(xuanQueImg);
			xuanQueImg:setSize(xuanQueImg.m_res.m_width,xuanQueImg.m_res.m_height);

			table.insert(self.dingqueImgs, xuanQueImg);
		end
		local x , y = self.coor[kSeatMine][1] , self.coor[kSeatMine][2];
		self.myQueImg = UICreator.createImg( DingQueViewPin_map["selectQueingH.png"], x, y);
		self:addChild(self.myQueImg);
		self.myQueImg:setVisible(false);
		self.myQueImg:setSize(self.myQueImg.m_res.m_width,self.myQueImg.m_res.m_height);
		self:setVisible(true);
		--第一次创建时调
		TeachManager.getInstance():show(TeachManager.XUAN_QUE_TIP);
	else -- 已经创建，显示
		for i = 1 , 3 do
			-- 重新设置图片，因为之前播放闪烁动画时修改过图片
			self.selectImgs[i]:setFile(DingQueViewPin_map[string.format("select_%d.png",i-1)]);
			-- 重新修改位置
			self.dingqueImgs[i]:setPos(self.selectCoor[1] + (i - 1) * 140 , self.selectCoor[2]);
			local selectQueingDir ;
			if i == kSeatMine or i == kSeatTop then
				selectQueingDir = DingQueViewPin_map["selectQueingH.png"];
			else
				selectQueingDir = DingQueViewPin_map["selectQueingV.png"];
			end
			self.dingqueImgs[i]:setFile(selectQueingDir); -- 修改图片
			self.dingqueImgs[i]:setSize(self.dingqueImgs[i].m_res.m_width,self.dingqueImgs[i].m_res.m_height);
		end
		self.myQueImg:setVisible(false);
		self:setSelectViewVisible(true);
		self:setClickable(true);-- 设置可点击
		self:setVisible(true);
	end
	if defaultType then
		local oldDir = DingQueViewPin_map[string.format("select_%d.png",defaultType)];
		local newDir = DingQueViewPin_map[string.format("select_%d_light.png",defaultType)];
		self:showFlash(self.selectImgs[defaultType + 1], oldDir, newDir);
	end


end

SelectQueView.showFlash = function ( self, img, fileDir, fileDirLight )
	if not img then
		return;
	end


	if not DrawingBase.checkAddProp(img,1) then
		img:removeProp(1);
	end

	img:setFile(fileDirLight);
	img:setName("Y");
	img:setDebugName("showFlash");

	local timer = img:addPropTranslate(1, kAnimRepeat, 500, 0, 0, 0, 0, 0 );

	timer:setEvent(img, function ( self )
		-- body
		if self:getVisible() then
			if self:getName() == "Y" then
				self:setName("N");
				self:setFile(fileDir);
			else
				self:setName("Y");
				self:setFile(fileDirLight);
			end
		end
	end);
end

-- 隐藏、显示选缺界面
SelectQueView.setSelectViewVisible = function ( self, bVisible )
	for k,v in pairs(self.selectImgs) do
		v:setVisible(bVisible);
	end
	for k,v in pairs(self.dingqueImgs) do
		v:setVisible(bVisible);
		if not DrawingBase.checkAddProp(v,1) then
			v:removeProp(1);
		end
	end

	if bVisible then
		TeachManager.getInstance():show(TeachManager.XUAN_QUE_TIP);
	else
		TeachManager.getInstance():hide();
	end
end

SelectQueView.AnimIndex = 1;
SelectQueView.moving = false;

-- 自己选定缺
SelectQueView.selectComplite = function ( self, selectType )
	for k,v in pairs(self.selectImgs) do
		v:setVisible(false);
	end
	self.myQueImg:setFile(SelectQueView.dirQueBig[selectType]);
	self.myQueImg:setSize(self.myQueImg.m_res.m_width,self.myQueImg.m_res.m_height);
	self.myQueImg:setVisible(true);
end

-- 服务器回应了选缺命令后的 往座位移动动画
SelectQueView.broadcastdingque = function (self, selectTypes)
	for k,v in pairs(self.selectImgs) do
		v:setVisible(false);
	end
	for k,v in pairs(selectTypes) do
		if kSeatMine == k then
			self.myQueImg:setFile(SelectQueView.dirQueBig[v]);
			self.myQueImg:setSize(self.myQueImg.m_res.m_width,self.myQueImg.m_res.m_height);
			self.myQueImg:setVisible(true);
		else
			self.dingqueImgs[k]:setFile(SelectQueView.dirQueBig[v]);
			self.dingqueImgs[k]:setVisible(true);
			self.dingqueImgs[k]:setSize(self.dingqueImgs[k].m_res.m_width,self.dingqueImgs[k].m_res.m_height);

			--选缺中 跟 已选图标大小不一致
			if kSeatRight == k then
				local x, y = self.dingqueImgs[k]:getPos();
				self.dingqueImgs[k]:setPos(x - 18, y);
			end
		end
	end
	--extra
	if self.reconnectRoomQuelist then
		self.myQueImg:setVisible(false);
		for i=1,#self.reconnectRoomQuelist do
			local index = self.reconnectRoomQuelist[i];
			self.dingqueImgs[index]:setVisible(false);
		end
	end
	-- delete(self.flashAnim); -- 删除动画anim
	-- self.flashAnim = nil;
	-- local moveDistX, moveDistY = 0, 0;
	-- -- 移动
	-- self:jumpAni(self.myQueImg, function ( self )
	-- 	-- 往位置方向移动
	-- 	moveDistX = Seat.queCoor[kSeatMine][1] - self.myQueImg.m_x / System.getLayoutScale() - 13;
	-- 	moveDistY = Seat.queCoor[kSeatMine][2] - self.myQueImg.m_y / System.getLayoutScale() - 13;
	-- 	local anim = self.myQueImg:addPropTranslate(self.AnimIndex,kAnimNormal,200,0,0,moveDistX,0,moveDistY);
	-- 	self.myQueImg:addPropScale( 2, kAnimNormal, 400, 0, 1.0, 44/70, 1.0, 44/70, kCenterDrawing);
	-- 	anim:setEvent(self, function ( self )
	-- 		self.myQueImg:setVisible(false);
	-- 		self.myQueImg:removeProp(SelectQueView.AnimIndex);
	-- 		self.myQueImg:removeProp(2);
	-- 		self:setVisible(false);
	-- 		if self.moveAniFun then
	-- 			self.moveAniFun(self.moveAniObj);
	-- 		end
	-- 	end);
	-- end);
	--
	--
	-- self:jumpAni(self.dingqueImgs[1], function ( self )
	-- 	moveDistX = Seat.queCoor[kSeatRight][1] - self.dingqueImgs[1].m_x / System.getLayoutScale() - 13;
	-- 	moveDistY = Seat.queCoor[kSeatRight][2] - self.dingqueImgs[1].m_y / System.getLayoutScale() - 13;
	-- 	local anim=self.dingqueImgs[1]:addPropTranslate(self.AnimIndex,kAnimNormal,200,0,0,moveDistX,0,moveDistY);
	-- 	self.dingqueImgs[1]:addPropScale( 2, kAnimNormal, 400, 0, 1.0, 44/70, 1.0, 44/70, kCenterDrawing);
	-- 	anim:setEvent(self, function ( self )
	-- 		self.dingqueImgs[1]:setVisible(false);
	-- 		self.dingqueImgs[1]:removeProp(SelectQueView.AnimIndex);
	-- 		self.dingqueImgs[1]:removeProp(2);
	-- 	end);
	-- end)
	--
	--
	-- self:jumpAni(self.dingqueImgs[2], function ( self )
	-- 	moveDistX = Seat.queCoor[kSeatTop][1] - self.dingqueImgs[2].m_x / System.getLayoutScale()- 13;
	-- 	moveDistY = Seat.queCoor[kSeatTop][2] - self.dingqueImgs[2].m_y / System.getLayoutScale()- 13;
	-- 	local anim=self.dingqueImgs[2]:addPropTranslate(self.AnimIndex,kAnimNormal,200,0,0,moveDistX,0,moveDistY);
	-- 	self.dingqueImgs[2]:addPropScale( 2, kAnimNormal, 400, 0, 1.0, 44/70, 1.0, 44/70, kCenterDrawing);
	-- 	anim:setEvent(self, function ( self )
	-- 		self.dingqueImgs[2]:setVisible(false);
	-- 		self.dingqueImgs[2]:removeProp(SelectQueView.AnimIndex);
	-- 		self.dingqueImgs[2]:removeProp(2);
	-- 	end);
	-- end)
	--
	--
	-- self:jumpAni(self.dingqueImgs[3], function ( self )
	-- 	moveDistX = Seat.queCoor[kSeatLeft][1] - self.dingqueImgs[3].m_x / System.getLayoutScale()- 13;
	-- 	moveDistY = Seat.queCoor[kSeatLeft][2] - self.dingqueImgs[3].m_y / System.getLayoutScale()- 13;
	-- 	local anim=self.dingqueImgs[3]:addPropTranslate(self.AnimIndex,kAnimNormal,200,0,0,moveDistX,0,moveDistY);
	-- 	self.dingqueImgs[3]:addPropScale( 2, kAnimNormal, 400, 0, 1.0, 44/70, 1.0, 44/70, kCenterDrawing);
	-- 	anim:setEvent(self, function ( self )
	-- 		self.dingqueImgs[3]:setVisible(false);
	-- 		self.dingqueImgs[3]:removeProp(SelectQueView.AnimIndex);
	-- 		self.dingqueImgs[3]:removeProp(2);
	-- 	end);
	-- end)
	self:jumpAni(self.myQueImg,self.doJumpAnimationComplele,kSeatMine);
	self:jumpAni(self.dingqueImgs[1],self.doJumpAnimationComplele,kSeatRight);
	self:jumpAni(self.dingqueImgs[2],self.doJumpAnimationComplele,kSeatTop);
	self:jumpAni(self.dingqueImgs[3],self.doJumpAnimationComplele,kSeatLeft);

end

SelectQueView.doJumpAnimationComplele = function ( self, animationimage, index)
	local moveDistX, moveDistY = 0, 0;
	moveDistX = Seat.queCoor[index][1] - animationimage.m_x / System.getLayoutScale()- 13;
	moveDistY = Seat.queCoor[index][2] - animationimage.m_y / System.getLayoutScale()- 13;
	local anim = animationimage:addPropTranslate(self.AnimIndex,kAnimNormal,200,0,0,moveDistX,0,moveDistY);
	animationimage:addPropScale( 2, kAnimNormal, 400, 0, 1.0, 44/70, 1.0, 44/70, kCenterDrawing);
	anim:setEvent(self, function ( self )
		animationimage:setVisible(false);
		animationimage:removeProp(SelectQueView.AnimIndex);
		animationimage:removeProp(2);
		if animationimage==self.myQueImg then
			self:setVisible(false);
			if self.moveAniFun then
				self.moveAniFun(self.moveAniObj);
			end
		end
	end);
end

SelectQueView.setMoveAniCallback = function ( self, obj, fun )
	self.moveAniObj = obj;
	self.moveAniFun = fun;
end

SelectQueView.jumpAni = function ( self, img, fun, index)
	-- 上移
	local anim = img:addPropTranslate(SelectQueView.AnimIndex, kAnimNormal, 200, 0, 0, 0, 0, -30);
	anim:setEvent(self, function ( self )
		img:removeProp(SelectQueView.AnimIndex);
		img:setPos(img.m_x/ System.getLayoutScale(), img.m_y/ System.getLayoutScale() - 30);
		-- 下移
		local anim = img:addPropTranslate(SelectQueView.AnimIndex, kAnimNormal, 200, 0, 0, 0, 0, 30);
		anim:setEvent(self, function ( self )
			img:removeProp(SelectQueView.AnimIndex);
			img:setPos(img.m_x/ System.getLayoutScale(), img.m_y/ System.getLayoutScale() + 30);
			fun(self,img,index);
		end);
	end);
end

SelectQueView.hiddenSomeImage = function (self,data)
	DebugLog("hiddenSomeImage");
	if not data then
		return
	end
	DebugLog(data);
	self.reconnectRoomQuelist = {};
	DebugLog(self.selectImgs);
	for i=1,#self.selectImgs do
		local img = self.selectImgs[i];
		if img then
			img:setVisible(false);
		end
	end
	local test = "";
	for k,v in pairs(data) do
		local ii = tonumber(k)
		local img = self.dingqueImgs[ii];
		if img then
			img:setVisible(false);
			self.reconnectRoomQuelist[#self.reconnectRoomQuelist+1] = ii;
		end
		test = test.."k:"..tostring(k)..", v:"..tostring(v)..";;"
	end
	DebugLog(self.reconnectRoomQuelist);

-- local view = PopuFrame.showNormalDialog( "温馨提示", test, nil, nil, nil, false, false, "确定", "确定");

end
