
local roomSetting = require(ViewLuaPath.."roomSetting");

RoomSettingWindow = class(SCWindow);

RoomSettingWindow.ctor = function ( self , _delegate)
	self.delegate = _delegate;
	self.cover:setFile("Commonx/blank.png"); -- 透明底图
	self.layout = SceneLoader.load(roomSetting);
	self:addChild(self.layout);

	self:setWindowNode( self.layout );
	self:setCoverEnable( true );

	self.sichuaneseBtn = publ_getItemFromTree(self.layout, {"languageFrame", "sichuaneseBtn"});
	self.sichuaneseChecked = publ_getItemFromTree(self.layout, {"languageFrame", "sichuaneseBtn", "checked"});
	self.mandarinBtn = publ_getItemFromTree(self.layout, {"languageFrame", "mandarinBtn"});
	self.mandarinChecked = publ_getItemFromTree(self.layout, {"languageFrame", "mandarinBtn", "checked"});
	self.voiceSider = publ_getItemFromTree(self.layout, { "voiceSlider"});
	self.musicSlider = publ_getItemFromTree(self.layout, { "musicSlider"});

	self.sichuaneseBtn:setOnClick(self, function( self )
		self.sichuaneseChecked:setVisible(true);
		self.mandarinChecked:setVisible(false);
		--self.language = kSichuanese;  --四川话
		GameConstant.language = kSichuanese;
		g_DiskDataMgr:setAppData("language", GameConstant.language)
		switchLanguageAudio(GameConstant.language);
	end);
	self.mandarinBtn:setOnClick(self, function( self )
		self.sichuaneseChecked:setVisible(false);
		self.mandarinChecked:setVisible(true);
		--self.language = kMandarin;  --普通话
		GameConstant.language = kMandarin;
		g_DiskDataMgr:setAppData("language", GameConstant.language)
		switchLanguageAudio(GameConstant.language);
	end);

    self.mandarinBtn:setEnable(GameConstant.soundDownload == 1);
    
	self.v1 = publ_getItemFromTree(self.layout, { "v1"});
	self.v2 = publ_getItemFromTree(self.layout, { "v2"});
	self.m1 = publ_getItemFromTree(self.layout, { "m1"});
	self.m2 = publ_getItemFromTree(self.layout, { "m2"});
	
	self:initComponentAction();

	if PlatformConfig.platformWDJ == GameConstant.platformType or 
	   PlatformConfig.platformWDJNet == GameConstant.platformType then 
       publ_getItemFromTree(self.layout, {"bgImg"}):setFile("Login/wdj/Hall/Commonx/pop_window_small.png");
       publ_getItemFromTree(self.layout, {"languageFrame"}):setFile("Login/wdj/setting/room_set_bg.png");
       self.sichuaneseChecked:setFile("Login/wdj/setting/room_set_btn.png");
       self.mandarinChecked:setFile("Login/wdj/setting/room_set_btn.png");
    end
end

RoomSettingWindow.initComponentAction = function ( self )
	self.voiceSider:setOnChange(self, RoomSettingWindow.voiceChange);
	self.musicSlider:setOnChange(self, RoomSettingWindow.musicChange);
	self.v1:setEventTouch(self, function ( self )
		self:voiceChange(0);
		self.voiceSider:setProgress(0);
	end);
	self.v2:setEventTouch(self, function ( self )
		self:voiceChange(1);
		self.voiceSider:setProgress(1);
	end);
	self.m1:setEventTouch(self, function ( self )
		self:musicChange(0);
		self.musicSlider:setProgress(0);
	end);
	self.m2:setEventTouch(self, function ( self )
		self:musicChange(1);
		self.musicSlider:setProgress(1);
	end);
end

RoomSettingWindow.voiceChange = function(self,pos)
   self.voice = pos;
   GameEffect.getInstance():setVolume(pos);
end

RoomSettingWindow.musicChange = function(self,pos)
   self.music = pos;
   GameMusic.getInstance():setVolume(pos);
end

RoomSettingWindow.show = function ( self )
	self:showWnd();
	local language = g_DiskDataMgr:getAppData("language", kSichuanese)
	GameConstant.language = language;
	if language == kMandarin then
		self.sichuaneseChecked:setVisible(false);
		self.mandarinChecked:setVisible(true);
	else
		self.sichuaneseChecked:setVisible(true);
		self.mandarinChecked:setVisible(false);
	end
	-- 设置当前音效、音乐音量
	self.voice = g_DiskDataMgr:getAppData('voice',0.5)
	self.music = g_DiskDataMgr:getAppData('music',0.5)
	self.voiceSider:setProgress(self.voice);
	self.musicSlider:setProgress(self.music);
end

RoomSettingWindow.dtor = function ( self )
	self.delegate.settingWnd = nil;

	g_DiskDataMgr:setAppData("language", GameConstant.language)
	-- 保存一次音乐、音效值
	g_DiskDataMgr:setAppData('music',self.music)
	g_DiskDataMgr:setAppData('voice',self.voice)

    -- if isSwitch and GameConstant.soundDownload == 1 then
    -- 	switchLanguageAudio(GameConstant.language);
    -- end
	self:removeAllChildren();
end

