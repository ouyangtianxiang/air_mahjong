require("MahjongData/BroadcastMsgManager");

--公告栏 滚动公告
BroadcastAnimation = class(Node);

local perTime = 5000; 

BroadcastAnimation.BG_FILE_PATH      		= "Hall/broadcast/bg.png"
BroadcastAnimation.TRUMPET_FILE_PATH_PRE    = "Commonx/trumpet"
BroadcastAnimation.PEN_FILE_PATH 			= "Commonx/pen.png"

-- bgwidth must > textwidth
BroadcastAnimation.ctor = function(self, bgWidth, textwidth , bgHeight )
	DebugLog("BroadcastAnimation.ctor args: bgw: " ..tostring(bgWidth) .. "txtwid: " .. tostring(textwidth))
    -- 创建消息队列
	self.m_messageManager = BroadcastMsgManager.getInstance();

	self.m_bgBtn		  = UICreator.createBtn9Grid( self.BG_FILE_PATH,0,0,20,20,18,18 );
	local w,h 			  = self.m_bgBtn:getSize()

	self.m_bgBtn:setAlign(kAlignCenter)
	self:addChild(self.m_bgBtn)

	self.m_bgBtn:setSize(bgWidth,bgHeight or h)
	self:setSize(bgWidth or w, bgHeight or h)

	local trumpetDir = {}
	for i=1,3 do
		table.insert(trumpetDir, self.TRUMPET_FILE_PATH_PRE .. i ..".png");
	end	

	self.m_trumpetImg     = UICreator.createImages( trumpetDir )
	self.m_trumpetImg:setAlign(kAlignLeft)
	self.m_trumpetImg:setPos(40,0)
	self.m_bgBtn:addChild(self.m_trumpetImg)

	self.m_penImg         = UICreator.createImg( self.PEN_FILE_PATH )
	self.m_penImg:setAlign(kAlignRight)
	self.m_penImg:setPos(40,0)
	self.m_bgBtn:addChild(self.m_penImg)

	self.m_textNode       = new(Node)
	self.m_textNode:setSize( textwidth , h)
	self.m_textNode:setAlign(kAlignCenter)
	--self.m_textNode:setPos(0,0)
	self:addChild(self.m_textNode)

	self.translateAnimTable = {};

	self.m_bgBtn:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerDown == finger_action then
			self.m_bgBtn:addPropScaleSolid(1, 1.01, 1.2, kCenterDrawing, 0, 0);
			GameEffect.getInstance():play("BUTTON_CLICK");
		elseif kFingerUp == finger_action then
			self.m_bgBtn:removeProp(1);
			if self.btnObj and self.btnFunc then 
				self.btnFunc(self.btnObj)
			end 
		end
	end );
end

BroadcastAnimation.setOnClickedCallback = function ( self, obj , func )
	self.btnObj = obj
	self.btnFunc = func
end


--参数说明： animType
--			 viewNode  字符所用节点，用于裁剪
--			 mBgImage  背景图
--			 broadcastType  类型   1大厅   2房间
BroadcastAnimation.play = function(self )
	local count = 1;

	if self.m_trumpetImg:checkAddProp(0) then
		self.m_trumpetAnim = self.m_trumpetImg:addPropTranslate(0, kAnimRepeat, 300, 0, 0, 0, 0, 0);
		
		if not self.m_trumpetAnim then 
			return
		end

		self.m_trumpetAnim:setDebugName("BroadcastAnimation|self.trumpetAnim");
		self.m_trumpetAnim:setEvent(self, function(self)
			if 3 < count then
				count = 1;
			end
			--local filename = self.TRUMPET_FILE_PATH_PRE .. tostring(count) .. ".png"
			self.m_trumpetImg:setImageIndex(count-1)
			count = count + 1;
		end);
		self:startAnim();
	end

end



BroadcastAnimation.startAnim = function(self ,notSetVis)

	local info = self.m_messageManager:pop();
	if info and info.msg and info.msg ~= "" then
		self:startPlay(info.msg, info.msgType);
	elseif not notSetVis then
		--self:setVisible(false);
		if not self.m_trumpetImg:checkAddProp(0) then
			self.m_trumpetImg:removeProp(0);
		end
		self.m_trumpetAnim = nil;
	end
end

BroadcastAnimation.startPlay = function(self, msg, msgType)
	DebugLog("msgType : "..(msgType or 0));
	local fontSize = 22 --(1 == self.broadcastType) and 24 or 26;
	local m_text = nil;
	if 1 == msgType then
		m_text = new(Text, msg, 0, 0, kAlignLeft, "", fontSize, 0xff , 0xeb , 0x7e)--255,250,110); -- 黄 系统
	elseif 2 == msgType then
		m_text = new(Text, msg, 0, 0, kAlignLeft, "", fontSize, 0x7a , 0xe9 , 0x34)--120,250,120); -- 绿 公告
	elseif 3 == msgType then
		m_text = new(Text, msg, 0, 0, kAlignLeft, "", fontSize, 0xff , 0xff , 0xff)--255,255,255); -- 白 玩家
	else
		m_text = new(Text, msg, 0, 0, kAlignLeft, "", fontSize, 0xff , 0xff , 0xff)--255,255,255);
	end
    --
	self.m_textNode:setClip( (self.m_bgBtn.m_width - self.m_textNode.m_width)/2, 0 , self.m_textNode.m_width, self.m_textNode.m_height )
	m_text:setAlign(kAlignLeft)
	m_text:setPos( self.m_textNode.m_width + (self.m_bgBtn.m_width - self.m_textNode.m_width)/2, 0 ) --self.mBgImage.m_width , 0);
	self.m_textNode:addChild(m_text);

	local scale = System.getLayoutScale();

	local startPosX = self.m_textNode.m_width + (self.m_bgBtn.m_width - self.m_textNode.m_width)/2
	local dist = self.m_bgBtn.m_width  + m_text.m_width + 15;
	local time = dist / 100 * 1000;
	local preTimeDis = dist / time;
	local translateAnimItem = {};
	translateAnimItem.m_text = m_text;
	translateAnimItem.m_time = time;
	translateAnimItem.m_preTimeDis = preTimeDis;
	translateAnimItem.m_nowx = startPosX;
	translateAnimItem.m_flag = false;
	table.insert(self.translateAnimTable , translateAnimItem);

	if not self.translateAnim then
		self.translateTime = 40;
		self.translateAnim = new(AnimInt , kAnimRepeat , 0 , self.translateTime , self.translateTime , 0);
		self.translateAnim:setDebugName("BroadcastAnimation || translateAnim");
		self.translateAnim:setEvent(self , function( self )
			local tempTable = {};
			for k , v in pairs(self.translateAnimTable) do
				v.m_time = v.m_time - self.translateTime;
				if v.m_time < 0 then
					v.m_text:removeFromSuper();
				else
					v.m_nowx = v.m_nowx - v.m_preTimeDis * self.translateTime;
					--local x,y = v.m_text:getPos()
					v.m_text:setPos(v.m_nowx , 0)-- / scale);
					table.insert(tempTable , v);
				end
			end
			self.translateAnimTable = tempTable;
			for k , v in pairs(self.translateAnimTable) do
				if v.m_preTimeDis * v.m_time <= self.m_bgBtn.m_width * 2 / 3 and not v.m_flag then
					v.m_flag = true;
					self:startAnim(true);
					break;
				end
			end
			if #self.translateAnimTable == 0 then
				delete(self.translateAnim);
				self.translateAnim = nil;
				self:startAnim();
			end
		end);
	end
end

BroadcastAnimation.dtor = function(self)
	DebugLog("BroadcastAnimation.dtor");
	if self.translateAnim then
		delete(self.translateAnim);
		self.translateAnim = nil;
	end
	if self.m_trumpetAnim then
		self.m_trumpetAnim = nil;
	end
	if not self.m_trumpetImg:checkAddProp(0) then
		DebugLog("self.animNode:checkAddProp");
		self.m_trumpetImg:removeProp(0);
	end

	for k , v in pairs(self.translateAnimTable) do
		v.m_text:removeFromSuper();
	end
	self.translateAnimTable = nil;

	-- if self.showAnim then 
	-- 	self.showAnim:stop()
	-- 	self.showAnim = nil
	-- end 

	-- if self.hideAnim then 
	-- 	self.hideAnim:stop()
	-- 	self.hideAnim = nil
	-- end 

end

local function table_remove(tbl, vv)
    for i, v in ipairs(tbl) do
        if v == vv then
            table.remove(tbl, i)
            break
        end
    end
end

function BroadcastAnimation:showAnimation( showType )
		if showType and showType == 1 then 
			self:setPos(0,14)
			self:resetSize( 552,360)---360			
		else --w,h,x,y = 830,630,0,150
			self:setPos(0,150)
			self:resetSize( 830,630)--630
		end 

		self:setVisible(true)

		if GameConstant.switchAnimIsOpen == 0 then 	
			return 
		end 


		local scaleAnim = Anim.keyframes{
			 {0.0, {scale = 0}, Anim.linear},
			 {0.2, {scale = 1}, nil },
		}
		local anim = Anim.Animator(scaleAnim, function ( v )
			if self:getWidget() then 
				self:getWidget().scale = Point(v.scale,v.scale)
			end 
		end, false)		
		table.insert(self._animations, anim)	
		anim.on_stop = function ()
			table_remove(self._animations, anim)
		end
		anim:start() 	

end

function BroadcastAnimation:hideAnimation( )
	if GameConstant.switchAnimIsOpen == 0 then 
		self:setVisible(false)	
		return 
	end 

	self:setVisible(true)
		
	local scaleAnim = Anim.keyframes{
		 {0.0, {scale = 1}, Anim.linear},
		 {0.2, {scale = 0}, nil },
	}
	local anim = Anim.Animator(scaleAnim, function ( v )
			if self:getWidget() then 
				self:getWidget().scale = Point(v.scale,v.scale)
			end 
	end, false)
	table.insert(self._animations, anim)	
	anim.on_stop = function ()
		table_remove(self._animations, anim)
		self:setVisible(false)
	end
	anim:start()	
end




BroadcastAnimation.resetSize = function ( self, bgWidth, textWidth )
	if self.m_bgBtn then 
		local w,h = self.m_bgBtn:getSize()
		self.m_bgBtn:setSize(bgWidth or w, h)

		self:setSize(bgWidth or w, h)
	end 

	if self.m_textNode then 
		local w,h = self.m_textNode:getSize()
		self.m_textNode:setSize(textWidth or w, h)
		self.m_textNode:setClip( (self.m_bgBtn.m_width - self.m_textNode.m_width)/2, 0 , self.m_textNode.m_width, self.m_textNode.m_height )
	end 


	local scale = System.getLayoutScale();
	local startPosX = self.m_textNode.m_width + (self.m_bgBtn.m_width - self.m_textNode.m_width)/2
	local dist = self.m_bgBtn.m_width + 15 -- m_text.m_width;
	local time = 0 --dist / 100 * 1000;
	local preTimeDis = 0 --dist / time;

	if not self.translateAnimTable then 
		return
	end 

	
	while(#self.translateAnimTable > 1)
	do 
		local textnode = self.translateAnimTable[1].m_text
		if textnode then 
			textnode:removeFromSuper()
		end 
		table.remove(self.translateAnimTable,1)
	end 


	for k , v in pairs(self.translateAnimTable) do
		dist = dist + v.m_text.m_width
		time = dist / 100 * 1000
		preTimeDis = dist / time
		
		v.m_time = time
		v.m_preTimeDis = preTimeDis
		v.m_nowx = startPosX
		v.m_flag = false

		v.m_text:setPos(v.m_nowx , 0)-- / scale);
	end	

	
end


