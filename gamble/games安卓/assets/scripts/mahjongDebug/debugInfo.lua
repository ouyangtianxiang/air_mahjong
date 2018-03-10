
DebugInfo = class()
DebugInfo.m_instance = nil;

DebugTestAllUI = {};

function DebugInfo.getInstance()
	if not DebugInfo.m_instance then
		DebugInfo.m_instance = new(DebugInfo);
	end
	return DebugInfo.m_instance;
end

function DebugInfo.ctor( self )
	DebugLog("DebugInfo ctor");
	self:writeDrawingInfoToTxt();
end

function DebugInfo.dtor( self )
	DebugLog("DebugInfo dtor");
	delete(self.debugAnim);
	self.bg:removeAllChild();
	delete(self.bg);
	self.bg = nil;
	self.text = nil;
	DebugInfo.m_instance = nil;
end

function DebugInfo.showDebugInfo(self)
	require("MahjongUtil/UICreator");
	if self.text then
		return;
	end
	self.text = UICreator.createText( "", 10, 10, 0, 0, kAlignLeft, 36, 0, 255, 0 );
    --self.text:setPos(0, 80);
	self.text:addToRoot();
	self.text:setLevel(20000);

	delete(self.debugAnim);
	if isPlatform_Win32() then
		self.debugAnim = new(AnimInt, kAnimRepeat, 0, 100, 100, 0);
	else
		self.debugAnim = new(AnimInt, kAnimRepeat, 0, 5 * 1000, 5 * 1000, 0);
	end

	require("MahjongData/NativeManager");
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

	self.debugAnim:setDebugName("GameConstant.debugAnim");
	self.debugAnim:setEvent(self, function ( self )
		if isPlatform_Win32() then
			local memory = MemoryMonitor.instance().texture_size--System.getTextureMemory()/(1024 * 1024);
			memory = string.format("%.2f" , memory);
            local fps = Clock.instance().fps;
			local t = "fps:"..fps.."  anim: "..System.getAnimNum().."  memory : "..memory.."M";
			self.text:setText(t);
		else
			NativeManager.getInstance():showAndroidMemroy();
		end
	end);
end

function DebugInfo.nativeCallEvent( self, param, _detailData )
	if param == kShowMemory then
		DebugLog("DebugInfo nativeCallEvent : "..(_detailData or 0));
		if _detailData and self.text then
			local memory = _detailData / 1024;
			memory = string.format("%.2f" , memory);
			local t = "fps:"..System.getFrameRate().."  anim: "..System.getAnimNum().."  memory : "..memory.."M";
			self.text:setText(t);
		end
	end
end

-- 实时回收垃圾内存
function DebugInfo.testCollectMemorey(self)
	delete(self.testAnim);
	self.testAnim = nil;
    self.testAnim = new(AnimInt,kAnimRepeat,0,100,100,0);
    self.testAnim:setEvent(self , function (self)
        collectgarbage("collect");
    end);
end

function DebugInfo.writeDrawingInfoToTxt(self)
	if self.writeAnim then
		return;
	end
	self.writeAnim = new(AnimInt,kAnimRepeat , 0 , 1 , 5000 * 1 , 0);
	self.writeAnim:setEvent(self , function(self)
		DebugLog("DebugInfo writeDrawingInfoToTxt");
		local dictName = "kAllUIDictName";
		local uikey = "kUIKey";
		local uidata = {};
		MahjongCacheData_deleteDict(dictName);
		for k ,v in pairs(DebugTestAllUI) do
			if v.obj.m_visible and v.obj.m_pickable then
				local x , y = v.obj:getAbsolutePos(); 
				local scale = System.getLayoutScale();
				x = x * scale;
				y = y * scale;
				local w , h = v.obj.m_width , v.obj.m_height;
				w = w * scale;
				h = h * scale;
				v.cx = x + (w / 2);
				v.cy = y + (h / 2);
				local flag = true;
				if x + w <= 0 or y + h <= 0 or x >= System.getScreenWidth() or y >= System.getScreenHeight() then
					flag = false;
				end
				if flag then
					local tmp = {};
					tmp.cx = v.cx;
					tmp.cy = v.cy;
					tmp.type = v.type;
					table.insert(uidata , tmp);
				end
			end
		end
		if #uidata > 0 then
			local data = json.encode(uidata);
			MahjongCacheData_setDictKey_StringValue(dictName , uikey , data , true);
		end
	end);
end
