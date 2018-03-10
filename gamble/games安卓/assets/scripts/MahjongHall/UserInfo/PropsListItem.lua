-- PropsListItem.lua
-- Author: YifanHe
-- Date: 2013-10-24
-- Last modification : 2013-10-24
-- Description: 自己物品显示列表单项


require("MahjongHall/UserInfo/ChangeItemWnd");
require("MahjongHall/HongBao/HongBaoModel")
--require("MahjongHall/HongBao/HongBaoViewManager")
PropsListItem = class(Node)

PropsListItem.ctor = function(self, data)
	if not data then
		return;
	end
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);

	EventDispatcher.getInstance():register(GlobalDataManager.updatePaizhiEvent, self, self.onChangeItemCallBack);

	local sw,sh = 276,216

	--self:setPos(0, 0);
	self:setSize(sw, sh);
	self.data = data;
	self.name = data.name;           --商品名称
	self.image = data.image;         --图片路径
	self.goodsdes = data.goodsdes;   --描述
	self.num = data.num;             --剩余数量
	self.cid = data.cid;             --卡片编号
	self.endtime = data.endtime;     --到期时间
	self.localDir = publ_downloadImg(self.image); -- 下载图片
	self.goodsType = tonumber( data.type or 0 ); -- 道具类型
	self.rootNode = self;
	self.canChange = self:checkCanChange();

	if self.cid and self.cid == 46 then 
		EventDispatcher.getInstance():register(HongBaoModel.HongBaoMsgs, self, self.hongbaoNumChange);
	end 

	self:initChangeWnd(sw,sh);

	--150-112/2
	self.icon = UICreator.createImg("Hall/userinfo/prop_default_icon.png", 0, 150/2-80/2)--,74,80,kAlignTop);
	self.icon:setAlign(kAlignTop)
	self.icon:setSize(74,80)
	self.rootNode:addChild(self.icon);
	local isExist , localDir = NativeManager.getInstance():downloadImage(self.image);
	if publ_isFileExsit_lua(self.localDir ) then -- 图片已下载
		self.icon:setFile(self.localDir);
		self.icon:setSize(80,80);
	end

	--商品名称
	--
	self.nameText = UICreator.createText(self.name, 0, 25, 120, 30, kAlignCenter , 30, 255, 255, 255 );
	self.nameText:setAlign(kAlignBottom)
	self.rootNode:addChild(self.nameText);

	self.usingImg = UICreator.createImg("Hall/userinfo/prop_using.png", 0, 0);
	self.rootNode:addChild(self.usingImg)	
	self.usingImg:setVisible(false)

	self:isPaizhiUsing();
	self:isHeadIconUsing();
	

	--描述
	--self.productDescText = UICreator.createText( self.goodsdes, 145, 63, 180, 30, kAlignLeft , 26, 255, 197, 135);
	--self.rootNode:addChild(self.productDescText);

	--剩余数量
	--self.haveNum = UICreator.createText("", 920, 23, 100, 30, kAlignLeft , 30, 255, 255, 255);
	--self.rootNode:addChild(self.haveNum);
	self.numImg      = UICreator.createImg("Commonx/tip.png", 160, 20)
	self.rootNode:addChild(self.numImg)
	
	self.haveNumText = UICreator.createText(self.num, 0, 0, 100, 30, kAlignCenter , 26, 255, 255, 255);
	self.haveNumText:setAlign(kAlignCenter)
	self.numImg:addChild(self.haveNumText);

	--到期时间
	--[[
	if self.endtime then
		self.endtimeTab = os.date("*t", self.endtime);
		local endtimeStr = self.endtimeTab.year .. "年" ..
						   self.endtimeTab.month .. "月" ..
						   self.endtimeTab.day .. "日" ..
						   self.endtimeTab.hour .. "时" ..
						   self.endtimeTab.min .. "分";
		self.endTimeText = UICreator.createText("到期时间:"..endtimeStr, 0, 63, 100, 30, kAlignTopRight , 26, 255, 197, 135);
		self.endTimeText:setAlign(kAlignTopRight)
		self.rootNode:addChild(self.endTimeText);
	end
	]]--
end

function PropsListItem:checkCanChange()
	for k,v in pairs( PropsListItem.s_change ) do
		if tonumber( self.goodsType ) == tonumber( k ) then
			return true;
		end
	end

	return tonumber(self.cid) == 46 ;
end

function PropsListItem:isPaizhiUsing()
	self.mIsCurPaizhiUsing = false;
	local player = PlayerManager.getInstance():myself();
	if tonumber( player.paizhi ) == -1 then
		if tonumber( self.cid ) == 10000 then
			self.usingImg:setVisible(true)
			--self.nameText:setText( self.name.."（使用中）" );
			self.mIsCurPaizhiUsing = true;
		end
	else
		if tonumber( player.paizhi ) == tonumber( self.cid ) then
			--self.nameText:setText( self.name.."（使用中）" );
			self.usingImg:setVisible(true)			
			self.mIsCurPaizhiUsing = true;
		end
	end
end

function PropsListItem:isHeadIconUsing()
	self.mIsCurIconUsing = false;
	local player = PlayerManager.getInstance():myself();
	DebugLog( "player.circletype = "..player.circletype );
	DebugLog( "self.cid = "..self.cid );
	if tonumber( player.circletype ) == tonumber( self.cid ) then
		self.usingImg:setVisible(true)
		self.mIsCurIconUsing = true;
	end
end

function PropsListItem:initChangeWnd(w,h)
	DebugLog( "PropsListItem:initChangeWnd" );
	self.rootNode = UICreator.createBtn( "Hall/userinfo/propbg.png", 0, 0 );
	self.rootNode:setSize( w, h );
	self.rootNode:setType(Button.Gray_Type)
	self:addChild( self.rootNode );
	--if self.canChange then
		DebugLog( "PropsListItem:initChangeWnd self.canChange" );
		self.rootNode:setOnClick( self, function( self )
			self:showChangeWndOrTips();
		end);
	--end
end

--此方法用于通过cid获取比赛场的level
PropsListItem.get_type_level_by_cid = function (self, cid)
    DebugLog("[PropsListItem]:get_level_by_cid");
    if not cid then
        return;
    end
    local matchdata = HallConfigDataManager.getInstance().m_hallData["match"] or {};
    for i = 1, #matchdata do
        if matchdata[i].applyprop and matchdata[i].applyprop.type == cid then
            return matchdata[i].type, matchdata[i].level;
        end
    end
--m_hallData["match"]
end
--展示道具使用说明
PropsListItem.show_item_detail_wnd = function(self)
    DebugLog("[PropsListItem]:show_item_detail_wnd");
	local title = "温馨提示";
	local content = (self.name or "" )..":"..self.goodsdes or ""

    if self.endtime then
		self.endtimeTab = os.date("*t", self.endtime);
        if self.endtimeTab then
        	local endtimeStr = self.endtimeTab.year .. "年" ..
						   self.endtimeTab.month .. "月" ..
						   self.endtimeTab.day .. "日" ..
						   self.endtimeTab.hour .. "时" ..
						   self.endtimeTab.min .. "分";
            endtimeStr = "\n到期时间:"..endtimeStr;
            content = content..endtimeStr
        end

	end
	local view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, true,  false);
	if view then
        view:addChild(node);
		view:setConfirmCallback(view, function ( view )
			
--			
            view = nil;

            --雀圣卡--跳转比赛场
	        if self.cid == ItemManager.MATCH_MONTH_CARD or self.cid == ItemManager.MATCH_WEEK_CARD then
                if HallScene_instance then
                    --需要跳转界面的参数
                    if self.exit_node and self.exit_node.hide then
                    	local matchtype, level = self:get_type_level_by_cid(self.cid)
                    	if matchtype and level then
                    		self.exit_node:hideWithNotAnim( function()
			                    HallScene_instance:onGoToMatchRoom( level, matchtype );
                    		end)
                    	else 
	                        self.exit_node:hide();  
                    	end           
                    end
                end
            end 

		end);
	end
end


function PropsListItem:showChangeWndOrTips()
	DebugLog("PropsListItem:showChangeWndOrTips")
    if not self.canChange then
        DebugLog("goodtype:"..tostring(self.goodsType).." cid:"..tostring(self.cid));
        self:show_item_detail_wnd();
        return;
    end

	if self.cid == ItemManager.HONG_BAO_CID then 
		self:useHongbao()
		return 
	end 


	if self.mIsCurIconUsing and self.goodsType == 6 then
		--local msg = "该道具正在使用中";
		--Banner.getInstance():showMsg( msg );
        self:show_item_detail_wnd();
		return;
	end

	if self.mIsCurPaizhiUsing and self.goodsType == 5 then
		--local msg = "该道具正在使用中";
		--Banner.getInstance():showMsg( msg );
        self:show_item_detail_wnd();
		return;
	end

	if not self.mIsCurIconUsing or not self.mIsCurPaizhiUsing then
		if self.changePaizhiWnd then
			delete( self.changePaizhiWnd );
			self.changePaizhiWnd = nil;
		end
		self.changePaizhiWnd = new(ChangeItemWnd, self.name, self.cid, self.goodsType );
		self.changePaizhiWnd:setOnOkClickListener( self, function( self )
			self:requestChange();
		end);
		self.changePaizhiWnd:showWnd();
	else
		--local msg = "该道具正在使用中";
		--Banner.getInstance():showMsg( msg );
        self:show_item_detail_wnd();
	end
end

function PropsListItem:requestChange()
	local func = PropsListItem.s_change[tonumber(self.goodsType)];
	if func then
		func( self );
	end
end

function PropsListItem.hongbaoNumChange( self, status )
	if status == HongBaoModel.UsedHongBaoEvent and self.cid == 46 then 
		--消耗了红包
		--GameConstant.changeNickTimes.rednum
		if GameConstant.changeNickTimes.rednum <= 0 then 
			self:removeFromSuper()
			return
		end 
		self.haveNumText:setText(""..GameConstant.changeNickTimes.rednum)
	end 
end

PropsListItem.dtor = function(self)
	if self.cid and self.cid == 46 then 
		EventDispatcher.getInstance():unregister(HongBaoModel.HongBaoMsgs, self, self.hongbaoNumChange);
	end 
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updatePaizhiEvent, self, self.onChangeItemCallBack);
	self:removeAllChildren();
end

function PropsListItem:onChangeItemCallBack( cid, goodsType )
	--DebugLog("onChangeItemCallBack cid: " .. tostring(cid) .. ",goodsType: " ..tostring(goodsType))	
	DebugLog("self: name:"..self.name..",cid: "..self.cid .. ",goodsType: " .. self.goodsType)
	if not cid then
		return;
	end
	if self.goodsType == goodsType then
		if cid == self.cid then
			DebugLog("usingImg true")
			self.usingImg:setVisible(true)
			self:setCurrentItemId();
			self:resetUsingState( true );
		else
			self.usingImg:setVisible(false)
			DebugLog("usingImg false")
			self.nameText:setText( self.name );
			self:resetUsingState( false );
		end
	end
end

function PropsListItem:setCurrentItemId()
	if self.goodsType == 5 then
		PlayerManager.getInstance():myself().paizhi = self.cid;
	elseif self.goodsType == 6 then
		PlayerManager.getInstance():myself().circletype = tonumber( self.cid );
	end
end

function PropsListItem:resetUsingState( state )
	if self.goodsType == 5 then
		self.mIsCurPaizhiUsing = state;
	elseif self.goodsType == 6 then
		self.mIsCurIconUsing = state;
	end
end

function PropsListItem:requestChangePaizhi()
	Loading.showLoadingAnim("请求中...");
	local param = {};
	param.cid = self.cid;
	SocketManager.getInstance():sendPack(PHP_CMD_CHANGE_PAIZHI, param);
end

function PropsListItem:requestChangeIcon()
	Loading.showLoadingAnim("请求中...");
	local param = {};
	param.cid = self.cid;
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_CHANGE_ICON, param);
end

function PropsListItem:useHongbao( )
	if not HongBaoModel.getInstance():checkIsSuitSendCondition() then
		return
	end 
	
	HongBaoViewManager.getInstance():showHongBaoSendView()
end



PropsListItem.callEvent = function(self, param, json_data)
	if param == kDownloadImageOne then
		if json_data then
			local imageName = (json_data.ImageName or "")..".png";
			if imageName == self.localDir then
				self.icon:setFile(self.localDir);
				self.icon:setSize(80,80);
			end
		end
	end
end

-- goodstype
PropsListItem.s_change = 
{
	[5]  = PropsListItem.requestChangePaizhi;
	[6]  = PropsListItem.requestChangeIcon;
	--[46] = PropsListItem.useHongbao;
}
