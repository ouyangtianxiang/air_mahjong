local oppo_newrewardview = require(ViewLuaPath.."oppo_newrewardview");
local hall_vip_iconPin_map = require("qnPlist/hall_vip_iconPin");

HallOppoRewardView = class(SCWindow);

HallOppoRewardView.ctor = function ( self,parent )
	DebugLog("HallOppoRewardView ctor"); 
	self.m_event = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);

	self:initView();

	if parent then
		parent:addChild( self );
	else
		self:addToRoot();
	end

	SocketManager.getInstance():sendPack(PHP_CMD_OPPO_REQUEST_VIP_SHOW,nil);
end

HallOppoRewardView.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.httpSocketRequestsCallBackFuncMap[cmd] then 
		self.httpSocketRequestsCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

HallOppoRewardView.initView = function(self)
	self.layout = SceneLoader.load(oppo_newrewardview);
	self.window = publ_getItemFromTree(self.layout, {"bg"});
	self:setWindowNode(self.window);
	self:addChild( self.layout );

	publ_getItemFromTree(self.layout,{"bg","close_btn"}):setOnClick(self, function ( self )
		self:hideWnd();
	end);	

	publ_getItemFromTree(self.layout,{"bg","reward_btn"}):setOnClick(self, function ( self )
		self:onClickRewardBtn(0.01);
	end);

	self.m_price = publ_getItemFromTree(self.layout,{"bg","price_bg","Text3"});
	self.m_item_bg1 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg1"});

	self.m_item_bg_bg = {};
	self.m_item_bg_text = {};

	self.m_item_bg_bg[1] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg1","bg"})
	self.m_item_bg_text[1] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg1","Text"})

	self.m_item_bg2 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg2"});
	self.m_item_bg_bg[2] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg2","bg"})
	self.m_item_bg_text[2] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg2","Text"})
	self.m_item_bg2_add = publ_getItemFromTree(self.layout,{"bg","item_bg","add1"});

	self.m_item_bg3 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg3"});
	self.m_item_bg3_add = publ_getItemFromTree(self.layout,{"bg","item_bg","add2"});
	self.m_item_bg_bg[3] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg3","bg"})
	self.m_item_bg_text[3] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg3","Text"})

	self.m_item_bg4 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg4"});
	self.m_item_bg_bg[4] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg4","bg"})
	self.m_item_bg_text[4] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg4","Text"})
	self.m_item_bg4_add = publ_getItemFromTree(self.layout,{"bg","item_bg","add3"});

	self.m_item_bg5 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg5"});
	self.m_item_bg5_add = publ_getItemFromTree(self.layout,{"bg","item_bg","add4"});
	self.m_item_bg_bg[5] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg5","bg"})
	self.m_item_bg_text[5] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg5","Text"})

	self.m_item_bg6 = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg6"});
	self.m_item_bg_bg[6] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg6","bg"})
	self.m_item_bg_text[6] = publ_getItemFromTree(self.layout,{"bg","item_bg","item_bg6","Text"})
	self.m_item_bg6_add = publ_getItemFromTree(self.layout,{"bg","item_bg","add5"});

	self.m_item_more = publ_getItemFromTree(self.layout,{"bg","item_bg","item_more"});

	self.m_vipExpProduct = ProductManager.getInstance():getProductByPcard();

	local pamount;
	if not self.m_vipExpProduct then 
		pamount = 0.01;
	else
		pamount = self.m_vipExpProduct.pamount;
	end
	self.m_price:setText(pamount .. "元");
end

HallOppoRewardView.onClickRewardBtn = function(self,pamount)
	local product = ProductManager.getInstance():getProductByPamount(pamount,2);

	if not product then 
		self:hideWnd();
		return ;
	end

	local payScene = {};
	payScene.scene_id = PlatformConfig.oppoFirstCharge;

	-- product.pmode = self.m_paySelectInfo[k].pmode;
	-- product.pclientid = self.m_paySelectInfo[k].pclientid;
	-- PayController:payForGoods(false,goodInfo);
	PayController:callThirdPay(product,PlatformConfig.OppoPay);

  	self:hideWnd();
end

HallOppoRewardView.dtor = function ( self )
	self:hide();
	self:removeAllChildren();

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);


end

function HallOppoRewardView:hideWnd()
	self.super.hideWnd( self );
end

function HallOppoRewardView:onWindowHide()
	self.super.onWindowHide( self );
end

function HallOppoRewardView:vipTYShowCallBack(isSuccess,data)
	if isSuccess then 
		if tonumber(data.status:get_value() or 0 ) == 1 then 
			local datas = data.data;
			local length = table.getn(datas);
			if length == 1 then 
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(false);
				self.m_item_bg2_add:setVisible(false);
				self.m_item_bg3:setVisible(false);
				self.m_item_bg3_add:setVisible(false);
				self.m_item_bg4:setVisible(false);
				self.m_item_bg4_add:setVisible(false);
				self.m_item_bg5:setVisible(false);
				self.m_item_bg5_add:setVisible(false);
				self.m_item_more:setVisible(false);

			elseif length == 2 then 
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(true);
				self.m_item_bg2_add:setVisible(true);
				self.m_item_bg3:setVisible(false);
				self.m_item_bg3_add:setVisible(false);
				self.m_item_bg4:setVisible(false);
				self.m_item_bg4_add:setVisible(false);
				self.m_item_bg5:setVisible(false);
				self.m_item_bg5_add:setVisible(false);
				self.m_item_more:setVisible(false);

			elseif length == 3 then
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(true);
				self.m_item_bg2_add:setVisible(true);
				self.m_item_bg3:setVisible(true);
				self.m_item_bg3_add:setVisible(true);
				self.m_item_bg4:setVisible(false);
				self.m_item_bg4_add:setVisible(false);
				self.m_item_bg5:setVisible(false);
				self.m_item_bg5_add:setVisible(false);
				self.m_item_more:setVisible(false);

			elseif length == 4 then 
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(true);
				self.m_item_bg2_add:setVisible(true);
				self.m_item_bg3:setVisible(true);
				self.m_item_bg3_add:setVisible(true);
				self.m_item_bg4:setVisible(true);
				self.m_item_bg4_add:setVisible(false);
				self.m_item_bg5:setVisible(false);
				self.m_item_bg5_add:setVisible(false);
				self.m_item_more:setVisible(false);

			elseif length == 5 then 
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(true);
				self.m_item_bg2_add:setVisible(true);
				self.m_item_bg3:setVisible(true);
				self.m_item_bg3_add:setVisible(true);
				self.m_item_bg4:setVisible(true);
				self.m_item_bg4_add:setVisible(true);
				self.m_item_bg5:setVisible(true);
				self.m_item_bg5_add:setVisible(false);
				self.m_item_more:setVisible(false);
			elseif length >= 6 then 
				self.m_item_bg1:setVisible(true);
				self.m_item_bg2:setVisible(true);
				self.m_item_bg2_add:setVisible(true);
				self.m_item_bg3:setVisible(true);
				self.m_item_bg3_add:setVisible(true);
				self.m_item_bg4:setVisible(true);
				self.m_item_bg4_add:setVisible(true);
				self.m_item_bg5:setVisible(true);
				self.m_item_bg5_add:setVisible(true);
				self.m_item_more:setVisible(true);
			end

			self:setVips(datas);
		end
	end
end

function HallOppoRewardView:setVips(value)
	for i = 1,table.getn(value) do 
		if value[i]:get_value() == "more" then 
			return;
		end
		local vipFile = value[i]:get_value() .. ".png";
		if value[i]:get_value() == "hptsh" then 
			vipFile = "vipHuIcon.png";
		end

		self.m_item_bg_bg[i]:setFile(hall_vip_iconPin_map[vipFile]);
		self.m_item_bg_text[i]:setText(self.vipShowTable[value[i]:get_value()]);
	end
end



HallOppoRewardView.vipShowTable = {
	["VIPbs"]="vip标示",
	["czfl"  ]= "充值返利",
	["qdjb"  ]= "签到金币",
	["pcbz"  ]= "破产补助",
	["trgn"  ]= "踢人功能",
	["kxtxk" ]= "酷炫头像框",
	["VIPzshd" ]= "vip专属活动",
	["VIPkf" ]="VIP客服",
	["bjfc"  ]= "不计负场",
	["zdycyy"]="自定义常用语",
	["ffdbjb"]="丰富的表情包",
	["hhmjz" ]= "豪华麻将子",
	 ["zsch" ]= "专属称号",
	["xgnc"	]= "修改昵称",
	["zfbjtd" ]= "支付便捷通道",
	["hysx"	]= "好友上限",
	["hptsh" ]= "胡牌提示",

}


--回调函数映射表
HallOppoRewardView.httpSocketRequestsCallBackFuncMap =
{
	[PHP_CMD_OPPO_REQUEST_VIP_SHOW] 		= HallOppoRewardView.vipTYShowCallBack,
};
