require("coreex/mask")
require("Animation/FrameAnim")
local TeachPin_map = require("qnPlist/TeachPin")
TeachManager = class(Node);

TeachManager.m_Instance 		= nil;

TeachManager.HAUNG_PAI_TIP 		= 1;
TeachManager.XUAN_QUE_TIP 		= 2;
TeachManager.CHU_PAI_TIP 		= 3; -- 1.手牌中无定缺牌 2.不是定缺玩法
TeachManager.CHU_PAI_1_TIP 		= 4; -- 在定缺玩法中，手牌有定缺牌
TeachManager.MING_GANG_TIP 		= 5;
TeachManager.AN_GANG_TIP 		= 6;
TeachManager.QIANG_GANG_HU_TIP 	= 7;
TeachManager.CHA_DA_JIAO_TIP 	= 8;
TeachManager.ZI_MO_TIP 			= 9;
TeachManager.KUAI_SHU_KAI_SHI_TIP= 10;
TeachManager.HAUNG_PAI_TIP1 	= 11;

TeachManager.getInstance = function()
	return TeachManager.m_Instance;
end

TeachManager.setInstance = function(instance)
	TeachManager.m_Instance = instance;
end

TeachManager.ctor = function(self, centerX, centerY, screenW, screenH)
	TeachManager.m_Instance = self;
	if not self:isNeedGuide() then
		return;
	end

	self.screenW = screenW;
	self.screenH = screenH;

	self.m_teachLayer 		= new(Image , TeachPin_map["teachLayer.png"],nil,nil,20,20,20,20);
	self.m_teachLayer:setSize(470,150)
	local playerHeadIcon 	= new(Image , TeachPin_map["tipPlayer2.png"]);
	if PlatformConfig.platformYiXin == GameConstant.platformType then 
		playerHeadIcon:setFile("Login/yx/Room/tipPlayer2.png");
	end
	playerHeadIcon:setAlign(kAlignLeft)
	playerHeadIcon:setPos(-10 , 0);
	self.m_teachLayer:addChild(playerHeadIcon);

	self.m_teachTip = new(TextView , "", 315, 100, kAlignLeft, nil, 22, 0xcc, 0x44, 0x00);
	self.m_teachTip:setPos(135,12);
	self.m_teachLayer:addChild(self.m_teachTip);

	self.m_teachLayer:setVisible(false);
	self:addChild(self.m_teachLayer);

	local w, h = self.m_teachLayer:getSize();
	self.m_finalX = centerX - w/2;
	self.m_finalY = centerY - h/2 --- 240;

	self.m_teachLayer:setPos(self.m_finalX, self.m_finalY);


	local tipsText = {};
	tipsText[TeachManager.HAUNG_PAI_TIP] 		= "选择需要更换的三张手牌！";
	tipsText[TeachManager.XUAN_QUE_TIP] 		= "四川麻将需要缺一门才可以胡牌，请提前选择你不要的那门牌！";
	tipsText[TeachManager.CHU_PAI_TIP] 			= "双击或者拖动即可出牌！";
	tipsText[TeachManager.CHU_PAI_1_TIP] 		= "双击或拖动即可出牌！要先将所有定缺的牌打出去哦！";
	tipsText[TeachManager.MING_GANG_TIP] 		= "刮风，即为明杠，点击杠立即收取其他玩家的钱哦！";
	tipsText[TeachManager.AN_GANG_TIP] 			= "下雨，即为暗杠，点击杠立即收取其他玩家的钱哦！";
	tipsText[TeachManager.QIANG_GANG_HU_TIP] 	= "点击即可抢杠胡哦！";
	tipsText[TeachManager.CHA_DA_JIAO_TIP] 		= "没听牌的要被听牌的查大叫，有三种花色牌的人要被查花猪！";
	tipsText[TeachManager.ZI_MO_TIP] 			= "血战玩法一家胡牌后其他家继续玩，血流玩法胡牌后可以继续胡牌哦！";
	if GameConstant.platformType == PlatformConfig.platformDingkai then
        tipsText[TeachManager.KUAI_SHU_KAI_SHI_TIP] = "欢迎来到血战麻将，点击开始游戏！";
    elseif GameConstant.platformType == PlatformConfig.platformYiXin then 
    	tipsText[TeachManager.KUAI_SHU_KAI_SHI_TIP] = "欢迎来到易信四川麻将，点击开始游戏！";
    	playerHeadIcon:setPos(-20,0)
    else
        tipsText[TeachManager.KUAI_SHU_KAI_SHI_TIP] = "欢迎来到博雅四川麻将，点击开始游戏！";
    end
	tipsText[TeachManager.HAUNG_PAI_TIP1] 		= "选择需要更换的两张手牌！";

	self.m_tipsText = tipsText;

	self.m_uping  = false;
end

TeachManager.dtor = function(self)
	DebugLog("TeachManager dtor");
	-- TeachManager.m_Instance = nil;
	delete(self.m_arrowAnim);
	self.m_arrowAnim = nil;
	self:removeAllChildren();
end

function TeachManager.setTeachNotVisible(self)
 	delete(self.m_arrowAnim);
	self.m_arrowAnim = nil;
	self:removeAllChildren();
	self.m_teachLayer = nil;
end 

TeachManager.show = function ( self, tipType)
	-- body
	if not self.m_teachLayer or self.m_config[tipType] == 1  then
		return;
	end
	self.m_teachTip:setText(self.m_tipsText[tipType]);
	self.m_teachLayer:setVisible(true);

	local sx,sy,dx,dy 

	if tipType == TeachManager.KUAI_SHU_KAI_SHI_TIP then
		delete(self.m_arrowAnim);
		self.m_arrowAnim = nil;
		local w, h = 70, 114;
		--self.m_arrowAnim = new(FrameAnim , SpriteConfig.configMap[SpriteConfig.TYPE_TEACH_CLICK]);
		--self.m_arrowAnim:setPos((self.screenW - w) / 2 - self.m_finalX , (self.screenH - h)/2 - self.m_finalY + 100);
		--self.m_teachLayer:addChild(self.m_arrowAnim);

		self.m_arrowAnim = UICreator.createImg(TeachPin_map["clickW.png"],0, 0)
		self.m_arrowAnim:setPos(350, 45)
		self.m_arrowAnim:addPropTranslate(1,kAnimRepeat,1000,0,0,50,0,0)--(self, sequence, animType, duration, delay, startX, endX, startY, endY)
		self.m_teachLayer:addChild(self.m_arrowAnim);
		
		dy = self.m_finalY - 240
		sy = dy
		--self.m_teachLayer:setPos(self.m_finalX, self.m_finalY);

        if HallScene_instance then
            local btn_xzdd = HallScene_instance:getControl(HallScene.s_controls.btn_xzdd);
            --"main_view", "v_1"
            local v_1 = publ_getItemFromTree(HallScene_instance.m_root, {"main_view", "v_1"});
            local x_v_1, _ = v_1:getPos();
            local x, y = btn_xzdd:getPos();
            local viewCover = HallScene_instance.m_more_view
            local file_path = "Hall/hallComon/btn_xzdd.png";
            local mask_path = "Hall/hallComon/btn_xzdd.png";
            local mask = new(Mask,file_path,mask_path)
            mask:setAlign(kAlignRight)

            mask:setPos(x+x_v_1, y )
            viewCover.mask = mask;
	        viewCover:addChild(mask)
        end
	end

	self:down(dx , dy, sx, sy);
	self.m_config[tipType] = 1;

	self:writeConfig(self.m_config);
	self:isNeedGuide();
end

TeachManager.hide = function ( self )
	-- body
	self:up();
end

TeachManager.down = function ( self,dx,dy,sx,sy )

	if not self.m_teachLayer then
		return;
	end

 	local screenW = System.getScreenWidth() / System.getLayoutScale();

	local w, h = self.m_teachLayer:getSize();

	if not DrawingBase.checkAddProp(self.m_teachLayer, 1) then 
		self.m_teachLayer:removeProp(1);
	end

	self.m_teachLayer:setPos(sx or screenW, sy or self.m_finalY);

	self.animDown = self.m_teachLayer:addPropTranslate(1, kAnimNormal, 200, 0, 0, self.m_finalX - screenW, 0, 0);
	self.animDown:setEvent(self, function (self)
		self.m_teachLayer:removeProp(1);
		self.m_teachLayer:setPos(dx or self.m_finalX,  dy or self.m_finalY);
	end);

	self.m_uping = false;
end

TeachManager.up = function ( self )
	if self.m_uping or not self.m_teachLayer then
		return;
	end
	local x, y = self.m_teachLayer:getPos();
	local w, h = self.m_teachLayer:getSize();
	if not DrawingBase.checkAddProp(self.m_teachLayer, 1) then 
		self.m_teachLayer:removeProp(1);
	end
	self.m_teachLayer:setPos(x, y);
	local screenW = System.getScreenWidth() / System.getLayoutScale();
	self.animUp = self.m_teachLayer:addPropTranslate(1, kAnimNormal, 200, 0, 0, screenW - x, 0, 0);		
	self.animUp:setEvent(self, function (self)
		self.m_teachLayer:removeProp(1);
		self.m_teachLayer:setPos(screenW, self.m_finalY);
		self.m_teachLayer:setVisible(false);
		if self.m_arrowAnim then
			delete(self.m_arrowAnim);
			self.m_arrowAnim = nil;
		end
		self.m_uping = false;
	end);

	self.m_uping = true;
end

TeachManager.isNeedGuide = function (self)
	-- body
	local player = PlayerManager.getInstance():myself();
	local lose 	 = player.losetimes or 0;
	local win 	 = player.wintimes or 0;
	local draw 	 = player.drawtimes or 0;
	
	if lose + win + draw >= 10 then
		return false;
	end

	if self.m_config == nil then
		self.m_config = self:readConfig();
	end

	for i, v in pairs(self.m_config) do
		if tonumber(v) == 0 then
			return true;
		end
	end

	return false;
end

TeachManager.isNeedHallGuide = function (self)
	return self.m_config[TeachManager.KUAI_SHU_KAI_SHI_TIP] ~= 1;
end

TeachManager.readConfig = function ( self )
	-- body
	local config = {};

	local player = PlayerManager.getInstance():myself();
	local file 	= new(Dict, "teach"..player.mid);
	file:load();
	for i = 1, 10 do
		config[i] = file:getInt(tostring(i), 0);
	end
	--file:delete();
	delete(file);
	file = nil;
	return config;
end

TeachManager.writeConfig = function ( self, config )
	local player = PlayerManager.getInstance():myself();
	local file 	= new(Dict, "teach"..player.mid);
	file:load();
	for k, v in pairs(config) do
		file:setInt(tostring(k), v);
	end
	file:save();
	--file:delete();
	delete(file);
	file = nil;
end

