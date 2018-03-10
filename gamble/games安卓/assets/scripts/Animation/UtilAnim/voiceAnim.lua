local voicePin_map = require("qnPlist/voicePin");


VoiceAnim = class(Node);

function VoiceAnim:ctor( viewName)

	local uilayout = require(ViewLuaPath..viewName );--require(ViewLuaPath.."voiceRecordTip");

	self._layout   = SceneLoader.load(uilayout);
	self:addChild(self._layout)


	self._animImg  = publ_getItemFromTree(self._layout, {"bg", "animImg"});
	self._images   = UICreator.createImages(self:getAnimDir());
	self._animImg:addChild(self._images)

	self._curFrame     = 1
	self._perFrameTime = 0.2--s 
	self._costTime     = 0
	self._playTime     = 1.0
end


function VoiceAnim:setPerFrameTime( time )
	-- body
	self._perFrameTime = time or 0.2
end


function VoiceAnim:onPlayPerFrame()
	self._costTime = self._costTime + self._perFrameTime
	if self._costTime >= self._playTime and self._playTime ~= -1 then 
		self:stop()
		return
	end 
	self._curFrame = self._curFrame + 1
	if self._curFrame > self._frameNum then 
		self._curFrame = 1
	end 
	self._images:setImageIndex(self._curFrame)
end


function VoiceAnim:play(time)
	if self._anim then 
		return 
	end 
	self._playTime = time
	self._anim = self._images:addPropTranslate(0, kAnimRepeat, self._perFrameTime*1000, 0, 0, 0, 0, 0);
	self._anim:setEvent(self, self.onPlayPerFrame);
end


function VoiceAnim:stop(frame)
	self._curFrame = frame or 1
	self._images:setImageIndex(self._curFrame)
	
	if not self._images:checkAddProp(0) then 
		self._images:removeProp(0)
		self._anim = nil
	end
end

function VoiceAnim:dtor()
	if self._anim then 
		delete(self._anim)
		self._anim = nil
	end 
end


--------------------

VoiceRecordAnim = class(VoiceAnim);


function VoiceRecordAnim:getAnimDir()
	local imgDirs = {}
	-- body
	for i=1,7 do
		table.insert(imgDirs,voicePin_map["record"..i..".png"])--"upGradeAnim/upgrade_".. string.format("%d.png", i));
	end

	self._frameNum = 7
	return imgDirs
end

function VoiceRecordAnim:onPlayPerFrame()
	self._costTime = self._costTime + self._perFrameTime
	if self._costTime >= self._playTime and self._playTime ~= -1 then 
		self:stop()
		return
	end 
	self._curFrame = math.random(1,self._frameNum)--self._curFrame + 1
	if self._curFrame > self._frameNum then 
		self._curFrame = 1
	end 
	self._images:setImageIndex(self._curFrame)
end



function VoiceRecordAnim:showCancelState( ... )
	publ_getItemFromTree(self._layout, {"bg", "text"}):setVisible(false)
	publ_getItemFromTree(self._layout, {"bg", "left"}):setVisible(false)
	publ_getItemFromTree(self._layout, {"bg", "animImg"}):setVisible(false)
	publ_getItemFromTree(self._layout, {"cancelView"}):setVisible(true)

	self.m_state = "cancel"
end


function VoiceRecordAnim:showRecordState( ... )
	publ_getItemFromTree(self._layout, {"bg", "text"}):setVisible(true)
	publ_getItemFromTree(self._layout, {"bg", "left"}):setVisible(true)
	publ_getItemFromTree(self._layout, {"bg", "animImg"}):setVisible(true)
	publ_getItemFromTree(self._layout, {"cancelView"}):setVisible(false)

	self.m_state = "record"
end

function VoiceRecordAnim:isCancel( ... )
	if self.m_state and self.m_state == "cancel" then 
		return true 
	end 
	return false
end

--------------------

VoicePlayAnim = class(VoiceAnim);

function VoicePlayAnim:ctor( viewName, seatId )
	self._seatId = seatId
	publ_getItemFromTree(self._layout, {"bg"}):setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
		if kFingerUp == finger_action then
			if self:isPlaying() then 
				return 
			end 
			self:play(-1)
			if self._playFunc then 
				self._playFunc(self._playHander,self._curFile,self._seatId)
			end 
		end
	end )
end

function VoicePlayAnim:getAnimDir()
	local imgDirs = {}
	-- body
	for i=1,3 do
		table.insert(imgDirs,voicePin_map[string.format("play%02d.png", i)])--"upGradeAnim/upgrade_".. string.format("%d.png", i));
	end

	self._frameNum = 3
	return imgDirs
end



function VoicePlayAnim:setSeconds( num )
	publ_getItemFromTree(self._layout, {"bg", "right"}):setText((num or 1) .. "''")
end


function VoicePlayAnim:showRedTip( num )
	local str = nil 
	if num and num >= 10 then 
		str = ".."
	elseif num and num > 1 then 
		str = tostring(num)
	end 

	if str then 
		publ_getItemFromTree(self._layout, {"bg", "tip"}):setVisible(true)
		publ_getItemFromTree(self._layout, {"bg", "tip","text"}):setText(str or "1")
	else 
		publ_getItemFromTree(self._layout, {"bg", "tip"}):setVisible(false)
	end 
	
end


function VoicePlayAnim:setFlipX( bvalue )
	publ_getItemFromTree(self._layout, {"bg"}):setMirror(bvalue,false)
	self._animImg:setMirror(bvalue,false)
	self._images:setMirror(bvalue,false)	
	if bvalue then 
		self._animImg:setPos(70,0)--20 0
		publ_getItemFromTree(self._layout, {"bg","right"}):setPos(70,-2)-- 5 -2
		publ_getItemFromTree(self._layout, {"bg","tip"}):setPos(98,-10)-- -10,-10
	else 
		self._animImg:setPos(20,0)--20 0
		publ_getItemFromTree(self._layout, {"bg","right"}):setPos(5,-2)-- 5 -2
		publ_getItemFromTree(self._layout, {"bg","tip"}):setPos(-10,-10)-- -10,-10		
	end 

	--self:play(-1)
end


function VoicePlayAnim:play(time)
	self.super.play(self,time)
	self._animImg:setFile(voicePin_map['play01.png'])

    local tbl = {}
    tbl.filePath = self._curFile or ""
    native_to_java(kStartPlayVoice, json.encode(tbl))	
end


function VoicePlayAnim:stop(frame)
	self.super.stop(self,time)
	self._animImg:setFile(voicePin_map['play03.png'])
end

function VoicePlayAnim:setCurFile( file )
	self._curFile = file
end


function VoicePlayAnim:isPlaying( ... )
	if self._anim then 
		return true 
	end 
	return false
end

function VoicePlayAnim:setPlayCallback( obj, func )
	self._playHander = obj 
	self._playFunc   = func
end