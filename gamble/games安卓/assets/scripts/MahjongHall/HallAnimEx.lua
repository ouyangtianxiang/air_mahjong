require("MahjongData/MMWordListInfo")

local function l_set_bg_file(file_path)
    if HallScene_instance and HallScene_instance.m_hallImg and file_path then
		HallScene_instance.m_hallImg:setFile(file_path)
    end
end

local function fun_schedule(obj, func, time)
    if not func or not obj then
        return;
    end

    Clock.instance():schedule_once(function()	
        func(obj)	
    end,time+0.05)
end

local function table_remove(tbl, vv)
    for i, v in ipairs(tbl) do
        if v == vv then
            table.remove(tbl, i)
            break
        end
    end
end


--给二级界面添加 进入进出动画接口
function globalAddEnterAnimInterface( target, bgNode, retNode,enterObj, enterFunc)
     
	local bgOriginX,bgOriginY   = bgNode:getPos()
	local retOriginX,retOriginY = retNode:getPos()

	target["preEnterAnim"] = function ()
		bgNode:setPos(bgOriginX, bgOriginY + System.getScreenScaleHeight())
		retNode:setPos(retOriginX, retOriginY - 200)
	end

	target["m_b_invalid_back_event"] = false
	-- body
	target["playEnterAnim"] = function (obj , func)
		if target.m_b_anim_enter_play then 
			return 
		end
        l_set_bg_file("Hall/hallComon/hallBlur.jpg");
		target.m_b_anim_enter_play = true
		--动画打开逻辑
		if GameConstant.switchAnimIsOpen == 0 then
            
			bgNode:setPos(bgOriginX ,   bgOriginY)
			retNode:setPos(retOriginX , retOriginY)
            --下一帧执行
            Clock.instance():schedule_once(function()
			    if func then 
				    func(obj)
				    target.m_b_anim_enter_play = false
				    return 
			    end 
			    if enterFunc then 
				    enterFunc(enterObj)
			    end
                target.m_b_anim_enter_play = false	           
            end)
			return
		end 

		--动画打开逻辑
		
		local move = Anim.keyframes{
			 {0.0, {ry = retOriginY - 200, cy = bgOriginY + System.getScreenScaleHeight()}, Anim.anticipate_overshoot(1.5)},
			 {0.9, {ry = retOriginY,       cy = bgOriginY}, nil },
		}
		local anim = Anim.Animator(move, function ( v )
			bgNode:setPos(bgOriginX , v.cy)
			retNode:setPos(retOriginX , v.ry)
		end, false)

		table.insert(target._animations, anim)
		anim.on_stop = function ()
            

			table_remove(target._animations, anim)
			target.m_b_anim_enter_play = false
			if func then 
				func(obj)
				return 
			end 

			if enterFunc then 
				enterFunc(enterObj)
			end
		end

		anim:start()		
	end
end
function globalAddExitAnimInterface( target, bgNode, retNode,sceneBg,exitObj, exitFunc )
	local bgOriginX,bgOriginY   = bgNode:getPos()
	local retOriginX,retOriginY = retNode:getPos()
	local x,y = sceneBg:getPos()
	-- body
	target["playExitAnim"] = function (obj , func)
        --动画打开逻辑
		if target.m_b_anim_exit_play then 
			return 
		end 

		--动画打开逻辑
		if GameConstant.switchAnimIsOpen == 0 then 
			bgNode:setPos(bgOriginX ,   bgOriginY + System.getScreenScaleHeight())
			retNode:setPos(retOriginX , retOriginY - 200)
			sceneBg:setPos(0, 0)
            --下一帧执行
            Clock.instance():schedule_once(function()
			    if func then 
				    func(obj)
				    target.m_b_anim_enter_play = false
				    return 
			    end 
			    if enterFunc then 
				    enterFunc(enterObj)
			    end
                target.m_b_anim_exit_play = false	           
            end)		
			return
		end 


        local t = 0.4;
		target.m_b_anim_exit_play = true
		local move = Anim.keyframes{
			 {0.0, {ry = retOriginY,       cy = bgOriginY, sx = x}, Anim.pow3_in},
			 {t, {ry = retOriginY - 200, cy = bgOriginY + System.getScreenScaleHeight(), sx = 0}, nil },
		}
		local anim = Anim.Animator(move, function ( v )
			bgNode:setPos(bgOriginX , v.cy)
			retNode:setPos(retOriginX , v.ry)
			sceneBg:setPos(v.sx, 0)
		end, false)
		table.insert(target._animations, anim)
		anim.on_stop = function ()
		    table_remove(target._animations, anim)
		    target.m_b_anim_exit_play = true

			if exitFunc then 
				exitFunc(exitObj)
			end
		end

        fun_schedule(obj, func, t);
		anim:start()		
	end
end

function HallScene:preEnterHallState()
	local gh = self.m_hallGirl._height or 661
	self.m_topLayer:preEnterAnim()
	self.m_topLayer:setPos(0   ,-200)
	self.m_bottomLayer:setPos(0,-100)
    self.m_friend_fight:setPos(60-450 ,0)
	self.m_hallGirl:setPos( self.m_hallGirl.originPos.x, self.m_hallGirl.originPos.y - gh) --bottom left
	self.m_menuView:setPos( 60-450,0)
	self.m_btn_more:setPos(-58,0)

end

function HallScene:preEnterLevelChooseState()
	self.m_topLayer:setPos(0,-200)
	self.m_topLayer:preEnterAnim2()
	self.m_levelChooseLayer.m_bgImg:setPos(34 , 150-System.getScreenScaleHeight())
	self.m_levelChooseLayer.m_returnBtn:setPos(40 , 20-200)
end 

function HallScene:setLevelChooseViewState()
    l_set_bg_file("Hall/hallComon/hallBgMid.jpg")   

	self.m_topLayer:preEnterAnim2()

	self.m_topLayer:setPos(0,0)
	self.m_topLayer:setVisible(true)	
	
	self.m_bottomLayer:setPos(0,-150)--bottom
	self.m_menuView:setPos(60-450,0)
    self.m_friend_fight:setPos(60-450,0);
    self.m_hallGirl:setPos(500, 0-(self.m_hallGirl._height or 661) )
	--self.m_hallGirl:setPos( self.m_hallGirl.originPos.x, self.m_hallGirl.originPos.y -650) --bottom left

	self.m_menuView:setVisible(true)
	self.m_levelChooseLayer:stableView()
end

function HallScene:startButtonAnim()
	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		return
	end 
	--动画打开逻辑
	if not self.btAnim1 then 
	    self.btAnim1 = publ_getItemFromTree(self.m_menuView.menu1,{"swf"})
	    self.btAnim2 = publ_getItemFromTree(self.m_menuView.menu2,{"swf"})
	    self.btAnim3 = publ_getItemFromTree(self.m_menuView.menu3,{"swf"})
	end
    if not self.btAnim1 then
        return;
    end 

    self.btAnim1:play(1,true)
    self.btAnim1:setCompleteEvent(self,function ( self )
        self.btAnim2:play(1,true)
    end)
    self.btAnim2:setCompleteEvent(self,function ( self )
        self.btAnim3:play(1,true)
    end)
    self.btAnim3:setCompleteEvent(self,function ( self )
        self.btAnim1:play(1,true)
    end) 
end

function HallScene:stopButtonAnim()
	-- body
    if self.btAnim1 then
        self.btAnim1:pause(69)
    end

    if self.btAnim2 then
        self.btAnim2:pause(69)
    end

	if self.btAnim3 then
        self.btAnim3:pause(69)
    end
end

--熊猫动画播放逻辑
function HallScene:excutePandaAnimationLogic()
    local createPanda = publ_getItemFromTree(self.m_btn_createRoom,{"swf"})
    local joinPanda   = publ_getItemFromTree(self.m_btn_addRoom,{"swf"})

    if not createPanda or not joinPanda then 
    	return 
    end 

	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 	
		createPanda:pause(1)	
		joinPanda:pause(1)
		return
	end 
	--动画打开逻辑	
    math.randomseed(os.time())
    local randomNum = math.random(1, 100) 
    DebugLog("randomNum:"..randomNum);
    --熊猫1动画 4成概率 熊猫2 6成概率动画
    local bPlayPanda_1 = randomNum >= 60 and true or false;

    if bPlayPanda_1 then 
        joinPanda:play(1,false,-1)
        createPanda:pause(1)
    else 
        createPanda:play(1,false,-1)
        joinPanda:pause(1)
    end  
end


--停止播放熊猫动画
function HallScene:stopPlayPandaAnimation()
    DebugLog("HallScene.stopPlayPandaAnimation");
    local createPanda = publ_getItemFromTree(self.m_btn_createRoom,{"swf"})
    local joinPanda   = publ_getItemFromTree(self.m_btn_addRoom,{"swf"})

    if not createPanda or not joinPanda then 
    	return 
    end     
    createPanda:pause(1)
    joinPanda:pause(1)
end


function HallScene:playEnterHallAnim( obj, func )

    --标记当前界面
    global_set_current_view_tag(GameConstant.view_tag.hall);

    --播放熊猫动画
    self:excutePandaAnimationLogic()

    l_set_bg_file("Hall/hallComon/hallBgMid.jpg")

	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		if self.m_levelChooseLayer then 
			self.m_levelChooseLayer:setVisible(false)
		end 
		self.m_btn_more:setVisible(true)
		self.m_b_hall = true;	
		--
		self.m_topLayer:setPos(0 , 0)
		self.m_bottomLayer:setPos(0, 0)
		self.m_friend_fight:setPos(60,0)
		self.m_menuView:setPos(60,0)
		self.m_hallGirl:setPos(500, 0)
		self.m_btn_more:setPos(0,0)	
		if self.myBroadcast then 
			self.myBroadcast:showAnimation(1)
		end 	
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)
		return
	end 
	--动画打开逻辑
	if self.m_b_anim_enter_play then 
		return
	end 
	if self.m_levelChooseLayer then 
		self.m_levelChooseLayer:setVisible(false)
	end 
	self.m_btn_more:setVisible(true)
	self.m_b_hall = true;
    local t = 0.6;

	local gh = self.m_hallGirl._height or 661
	local move = Anim.keyframes{
		 {0.0, {topy = -200, leftx = 60-450, rightx = 60-450, downy = -200, cy = -gh, btnx = -60}, Anim.anticipate_overshoot()},--Anim.spring(0.4)
		 {t, {topy = 0,    leftx = 60,     rightx = 60,     downy = 0,    cy = 0, btnx = 0}, nil },
	}

	local anim = Anim.Animator(move, function ( v )
        DebugLog("playEnterHallAnim:v.topy"..v.topy);
		self.m_topLayer:setPos(0 , v.topy)
		self.m_bottomLayer:setPos(0, v.downy)
		self.m_friend_fight:setPos(v.leftx,0)
		self.m_menuView:setPos(v.rightx,0)
		self.m_hallGirl:setPos(500, v.cy)
		self.m_btn_more:setPos(v.btnx,0)
	end, false)
	table.insert(self._animations, anim)
	anim.on_stop = function ()
		table_remove(self._animations, anim)
		self.m_b_anim_enter_play = false
		if self.myBroadcast and not self.m_b_anim_exit_play then 
			self.myBroadcast:showAnimation(1)
		end 
		self:startButtonAnim()
--		if func then 
--			func(obj)
--		end
	end

	anim:start()
    self.m_b_anim_enter_play = true 

    fun_schedule(obj, func, t);
	
end

function HallScene:playExitHallAnim( obj, func  )

    if self.m_b_anim_exit_play then
        return;    
    end
    self.m_b_anim_exit_play = true;

	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		self:stopButtonAnim()
		self:stopPlayPandaAnimation()
		self.m_b_hall = false
		if self.myBroadcast then 
			self.myBroadcast:hideAnimation()
		end 	
		--
		self.m_topLayer:setPos(0 , -200)
		self.m_bottomLayer:setPos(0, -200)
		self.m_friend_fight:setPos(60-450,0)
		self.m_menuView:setPos(60-450,0)
		self.m_hallGirl:setPos(500, 0-(self.m_hallGirl._height or 661) )
		self.m_btn_more:setPos(-60, 0)
        
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)
        self.m_b_anim_exit_play = false;
		return
	end 
	--动画打开逻辑
	self:stopButtonAnim()
	self:stopPlayPandaAnimation()
	self.m_b_hall = false
	if self.myBroadcast then 
		self.myBroadcast:hideAnimation()
	end 	
	-- body
	local gh = self.m_hallGirl._height or 661
    local t = 0.4
	local move = Anim.keyframes{
		 {0.0, {topy = 0,    leftx = 60,     rightx = 60,     downy = 0,    cy = 0, btnx = 0}, Anim.pow3_in},--Anim.spring(0.4)
		 {t, {topy = -200, leftx = 60-450, rightx = 60-450, downy = -200, cy = -gh, btnx = -60}, nil },
	}
	local anim = Anim.Animator(move, function ( v )
		self.m_topLayer:setPos(0 , v.topy)
		self.m_bottomLayer:setPos(0, v.downy)
		self.m_friend_fight:setPos(v.leftx,0)
		self.m_menuView:setPos(v.rightx,0)
		self.m_hallGirl:setPos(500, v.cy)
		self.m_btn_more:setPos(v.btnx, 0)
	end, false)
	table.insert(self._animations, anim)
	anim.on_stop = function ()
		table_remove(self._animations, anim)
        self.m_b_anim_exit_play = false;
	end


    fun_schedule(obj, func, t);

    anim:start()

end

function HallScene:playEnterLevelChooseAnim( obj, func  )
    
    back_event_manager.get_instance():add_event(self.m_levelChooseLayer,self.m_levelChooseLayer.onClickedReturnBtn)

    
	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		back_event_manager.get_instance():add_event(self.m_levelChooseLayer,self.m_levelChooseLayer.onClickedReturnBtn) 
		if self.m_levelChooseLayer then 
			self.m_levelChooseLayer:setVisible(true)
		end
		self.m_topLayer:setPos(0 , 0)
		self.m_levelChooseLayer.m_bgImg:setPos(34 , 120)
		self.m_levelChooseLayer.m_returnBtn:setPos(10 , 20)	
		if self.myBroadcast then 
			self.myBroadcast:showAnimation(2)
		end 	
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)	
		return
	end
     
	--动画打开逻辑	
    if self.m_b_anim_enter_play then
        return;
    end
	self.m_b_anim_enter_play = true;

	 
	if self.m_levelChooseLayer then 
		self.m_levelChooseLayer:setVisible(true)
	end 
    local t = 0.6;	
	-- body
	local move = Anim.keyframes{
		 {0.0, {topy = -200,ry = -180, cy = -System.getScreenScaleHeight()}, Anim.anticipate_overshoot()},--Anim.spring(0.4)
		 {t, {topy = 0,ry = 20, cy = 120}, nil },
	}
	local anim = Anim.Animator(move, function ( v )
        DebugLog("playEnterLevelChooseAnim:v.topy"..v.topy);
		self.m_topLayer:setPos(0 , v.topy)
		self.m_levelChooseLayer.m_bgImg:setPos(34 , v.cy)
		self.m_levelChooseLayer.m_returnBtn:setPos(10 , v.ry)
	end, false)
	table.insert(self._animations, anim)
	anim.on_stop = function ()
		table_remove(self._animations, anim)
		if self.myBroadcast and not self.m_b_anim_exit_play then 
			self.myBroadcast:showAnimation(2)
		end 	
        self.m_b_anim_enter_play = false;
		if func then 
			func(obj)
		end
	end
	anim:start()

    fun_schedule(obj, func, t);
end



function HallScene:playExitLevelChooseAnim( obj, func  )
	if self.m_b_anim_exit_play then 
		return
	end 

	self.m_b_anim_exit_play = true	

    if self.myBroadcast then 
		self.myBroadcast:hideAnimation()
	end 

	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		

		self.m_topLayer:setPos(0 , -200)
		self.m_levelChooseLayer.m_bgImg:setPos(34 , 120+System.getScreenScaleHeight())
		self.m_levelChooseLayer.m_returnBtn:setPos(10 , -180)
		self.m_b_anim_exit_play = false
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)	
		return
	end 
	--动画打开逻辑		


    local t = 0.4
	local move = Anim.keyframes{
		 {0.0, {topy = 0,    ry = 20,     cy = 120}, Anim.pow3_in},
		 {t, {topy = -200, ry = -180, cy = 120+System.getScreenScaleHeight()}, nil },
	}
	local anim = Anim.Animator(move, function ( v )
		self.m_topLayer:setPos(0 , v.topy)
		self.m_levelChooseLayer.m_bgImg:setPos(34 , v.cy)
		self.m_levelChooseLayer.m_returnBtn:setPos(10 , v.ry)
	end, false)
	table.insert(self._animations, anim)
	anim.on_stop = function ()
		table_remove(self._animations, anim)
		self.m_b_anim_exit_play = false 

	end

    fun_schedule(obj, func, t);
	anim:start()
end


function HallScene:playExitHallWithMoveBgAnim( moveDirection ,obj, func  )
	if self.m_b_anim_exit_play then 
		return
	end 

	self.m_b_anim_exit_play = true	
	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		self:stopButtonAnim()
		self:stopPlayPandaAnimation()
		self.m_b_hall = false
		if self.myBroadcast then 
			self.myBroadcast:hideAnimation()
		end 	
		--
		self.m_topLayer:setPos(0 ,   -200)
		self.m_bottomLayer:setPos(0, -200)
		self.m_friend_fight:setPos(60-450,0)
		self.m_menuView:setPos(60-450,0)
		self.m_hallGirl:setPos(500, 0-(self.m_hallGirl._height or 661))
		self.m_hallImg:setPos(0,0)
		self.m_btn_more:setPos(-60,0)
		self.m_b_anim_exit_play = false
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)		
		return
	end 
	--动画打开逻辑		

	self:stopButtonAnim()
	self:stopPlayPandaAnimation()
	self.m_b_hall = false
	if self.myBroadcast then 
		self.myBroadcast:hideAnimation()
	end 	
	moveDirection = moveDirection or 1
	local w = self:addExBgByDirection(moveDirection)
	w = moveDirection * w--- right:1 or left:-1
	--DebugLog("exit hall anim:w="..w)
	local gh = self.m_hallGirl._height or 661
    local t = 0.4
	local move = Anim.keyframes{
		 {0.0, {topy = 0,    leftx = 60,     rightx = 60,     downy = 0,    cy = 0, bgx = 0, btnx = 0}, Anim.pow3_in},--Anim.spring(0.4)
		 {t, {topy = -200, leftx = 60-450, rightx = 60-450, downy = -200, cy = -gh, bgx = -w,btnx = -60}, nil },
	}
	local anim = Anim.Animator(move, function ( v )
		self.m_topLayer:setPos(0 , v.topy)
		self.m_bottomLayer:setPos(0, v.downy)
		self.m_friend_fight:setPos(v.leftx,0)
		self.m_menuView:setPos(v.rightx,0)
		self.m_hallGirl:setPos(500, v.cy)
		--self.m_hallImg:setPos(v.bgx,0)
		self.m_btn_more:setPos(v.btnx,0)
		--DebugLog("exit hall anim:bgx="..v.bgx)
	end, false)
	table.insert(self._animations, anim)
	anim.on_stop = function ()
		table_remove(self._animations, anim)
		self.m_b_anim_exit_play = false
	end

    fun_schedule(obj, func, t);
	anim:start()


end


function HallScene:playEnterMoreAnim( obj, func )
	if self.m_b_anim_enter_play then 
		return
	end 

    back_event_manager.get_instance():add_event(self,self.playExitMoreAnim);
	self.m_b_anim_enter_play = true	
	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		self.m_menuView:setPos(60-450,0)
		self.m_btn_more:setPos(-58,0)	

		self.m_more_view:setVisible(true)
		self.m_more_view.btnView:setVisible(true)

		self.m_more_view.btnView:setPos(60, 0)	
		self.m_b_anim_enter_play = false

        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)			
		return
	end 
	--动画打开逻辑		
	
	local exitFrames = Anim.keyframes{
		 {0.0, {menux = 60,    morex = 0}, Anim.linear},--Anim.spring(0.4)
		 {0.3, {menux = 60-450,    morex = -58}, nil },	
	}

	local enterFrames = Anim.keyframes{
		 {0.0, {menux = 60-450}, Anim.anticipate_overshoot()},--Anim.spring(0.4)
		 {0.3, {menux = 60}, nil },	
	}

	local exitAnim = Anim.Animator(exitFrames, function ( v )
		self.m_menuView:setPos(v.menux,0)
		self.m_btn_more:setPos(v.morex,0)
	end, false)
	table.insert(self._animations, exitAnim)

	local enterAnim = Anim.Animator(enterFrames, function ( v )
		self.m_more_view.btnView:setPos(v.menux, 0)
	end)
	table.insert(self._animations, enterAnim)
	enterAnim.on_stop = function ( )
		table_remove(self._animations, enterAnim)
		self.m_b_anim_enter_play = false
		if func then 
			func(obj)
		end 
	end

	exitAnim.on_stop = function ()
		table_remove(self._animations, exitAnim)
		self.m_b_anim_enter_play = false 

	end
	exitAnim:start()
    Clock.instance():schedule_once(function()	
		self.m_more_view:setVisible(true)
		self.m_more_view.btnView:setVisible(true)
		enterAnim:start()  	
    end,0.3)
end

function HallScene:playExitMoreAnim( obj, func )
	if self.m_b_anim_exit_play then 
		return
	end 

    back_event_manager.get_instance():remove_event(self);

	self.m_b_anim_exit_play = true	
	--动画打开逻辑
	if GameConstant.switchAnimIsOpen == 0 then 		
		self.m_more_view.btnView:setPos(60-450, 0)

		self.m_more_view:setVisible(false)
		self.m_more_view.btnView:setVisible(false)	
		
		self.m_menuView:setPos(60,0)
		self.m_btn_more:setPos(0,0)			
		self.m_b_anim_exit_play = false
        --下一帧执行
        Clock.instance():schedule_once(function()
		    if func then 
			    func(obj)
		    end            
        end)			
		return
	end 
	--动画打开逻辑		


	local exitFrames = Anim.keyframes{
		 {0.0, {menux = 60}, Anim.linear},--Anim.spring(0.4)
		 {0.3, {menux = 60-450}, nil },	
	}

	local enterFrames = Anim.keyframes{
		 {0.0, {menux = 60-450,    morex = -58}, Anim.anticipate_overshoot()},--Anim.spring(0.4)
		 {0.3, {menux = 60,        morex = 0}, nil },	
	}

	local exitAnim = Anim.Animator(exitFrames, function ( v )
		self.m_more_view.btnView:setPos(v.menux, 0)
	end, false)

	local enterAnim = Anim.Animator(enterFrames, function ( v )
		self.m_menuView:setPos(v.menux,0)
		self.m_btn_more:setPos(v.morex,0)
	end)

	table.insert(self._animations, exitAnim)
	table.insert(self._animations, enterAnim)
	enterAnim.on_stop = function ( )
		table_remove(self._animations, enterAnim)
		self.m_b_anim_exit_play = false
		if func then 
			func(obj)
		end 
	end

	exitAnim.on_stop = function ()
		table_remove(self._animations, exitAnim)

	end
	exitAnim:start()
    Clock.instance():schedule_once(function()	
		self.m_more_view:setVisible(false)
		self.m_more_view.btnView:setVisible(false)
		enterAnim:start()  	
    end,0.3)
	
end

-------------------------------------------------------------------------------------------------------------------------
function HallScene:addExBgByDirection(direction)
	direction = direction or 1
	if direction == 1 then 
		return self:addRightBg()
	else 
		return self:addLeftBg()
	end 
end 
function HallScene:addLeftBg()
	local bg = self.m_hallImg
    if  bg.leftBg == nil then 
        bg.leftBg = new(Image , "Hall/hallComon/hallBgLeft.jpg");
        bg.leftBg:setLevel(-1)
        bg.leftBg:setFillParent(false, true)
        bg:addChild(bg.leftBg)

        local scale = System.getLayoutScale();
        bg.leftBg:setSize(System.getScreenWidth()*0.5/scale,System.getScreenScaleHeight());
	    local w = bg.leftBg:getSize()----30
	    bg.leftBg:setPos(-w,0)
	    bg.leftBg:setVisible(true)        
    end 

    return bg.leftBg:getSize()
end

function HallScene:addRightBg()
	local bg = self.m_hallImg
    if  bg.rightBg == nil then 
        bg.rightBg = new(Image , "Hall/hallComon/hallBgRight.jpg");
        bg.rightBg:setLevel(-1)
        bg.rightBg:setFillParent(false, true)
        bg:addChild(bg.rightBg)

        local scale = System.getLayoutScale();
        bg.rightBg:setSize(System.getScreenWidth()*0.5/scale,System.getScreenScaleHeight());
	    local w = bg.rightBg:getSize()----30
	    bg.rightBg:setPos(w*2,0)
	    bg.rightBg:setVisible(true)        
    end 
    return bg.rightBg:getSize()
end


function HallScene:initGirlAnim()

	local faceAnim = publ_getItemFromTree(self.m_hallGirl, {"face"});
	local eyeAnim  = publ_getItemFromTree(self.m_hallGirl, {"eye"});

	self.m_hallGirl.textBg   = publ_getItemFromTree(self.m_hallGirl, {"textBg"})
	self.m_hallGirl.textView = publ_getItemFromTree(self.m_hallGirl, {"textBg","textView"})

	faceAnim:pause(83)
	eyeAnim:pause(40)

	self.m_hallGirl.textBg:setVisible(false)
	faceAnim:setVisible(false)
	eyeAnim:setVisible(true)

	self.m_hallGirl.faceAnim = faceAnim
	self.m_hallGirl.eyeAnim  = eyeAnim

    self.m_hallGirl:setEventTouch(self , function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
			if kFingerUp == finger_action then
				self:randomPlayGirlAnimOnce()
			end
	end );

	self.mmWordList = new(MMWordListInfo)	
end

function HallScene.randomPlayGirlAnimOnce( self )
	if self.m_hallGirl and self.m_hallGirl._isPlaying then 
		return 
	end 

	local config = self.mmWordList:getConfig()
	local rand   = nil
	local randType   = nil
	if not config or #config < 1 then 
		self.m_hallGirl.textBg:setVisible(false)
		randType = math.random(1,2);
		DebugLog("math.random randType="..randType)
	else 
		self.m_hallGirl.textBg:setVisible(true)
		rand = math.random(1,#config);
		randType = tonumber(config[rand].type or 1) or 1
		DebugLog("math.random rand="..rand)
		DebugLog("randType="..randType)
		self.m_hallGirl.textView:setText(config[rand].text)
	end 
	self.m_hallGirl._isPlaying = true
	if randType == 2 then--2是害羞 1眨眼睛 

		self.m_hallGirl.faceAnim:play(1,false)
		self.m_hallGirl.faceAnim:setFrameEvent(self.m_hallGirl.faceAnim,function ( sender )
			sender:pause(83)
			self.m_hallGirl.textBg:setVisible(false)
			self.m_hallGirl._isPlaying = nil
		end,83)
		self.m_hallGirl.eyeAnim:setVisible(false)
		self.m_hallGirl.faceAnim:setVisible(true)
	else 
		self.m_hallGirl.eyeAnim:play(1,false)
		self.m_hallGirl.eyeAnim:setFrameEvent(self.m_hallGirl.eyeAnim,function ( sender )
			sender:pause(40)
			self.m_hallGirl.textBg:setVisible(false)
			self.m_hallGirl._isPlaying = nil
		end,40)
		self.m_hallGirl.faceAnim:setVisible(false)
		self.m_hallGirl.eyeAnim:setVisible(true)
	end 

end


function HallScene:clearSwfAnims( ... )
	local faceAnim = publ_getItemFromTree(self.m_hallGirl, {"face"});
	local eyeAnim  = publ_getItemFromTree(self.m_hallGirl, {"eye"});

	if faceAnim and eyeAnim then 
		faceAnim:setFrameEvent(nil,nil,83)
		eyeAnim:setFrameEvent(nil,nil,40)
		faceAnim:removeFromSuper()
		eyeAnim:removeFromSuper()	
	end 	

    local createPanda = publ_getItemFromTree(self.m_btn_createRoom,{"swf"})
    local joinPanda   = publ_getItemFromTree(self.m_btn_addRoom,{"swf"})
    if createPanda and joinPanda then 
    	joinPanda:removeFromSuper()
		createPanda:removeFromSuper()
    end 


    if self.btAnim1 then 
	    self.btAnim1:setCompleteEvent()
	    self.btAnim2:setCompleteEvent()
	    self.btAnim3:setCompleteEvent()   

	    self.btAnim1:removeFromSuper()
	    self.btAnim2:removeFromSuper()
	    self.btAnim3:removeFromSuper()
	    self.btAnim1 = nil 
	    self.btAnim2 = nil 
	    self.btAnim3 = nil 

	end  



end