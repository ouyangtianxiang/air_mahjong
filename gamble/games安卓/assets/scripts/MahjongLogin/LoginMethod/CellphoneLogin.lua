--[[
	className    	     :  CellphoneLogin
	Description  	     :  登录类-子类(手机登录))
	create-time 	     :  3-21-2016
	create-author        :  NoahHan
--]]
require("MahjongLogin/LoginMethod/BaseLogin");
local CellphoneLoginViewXml = require(ViewLuaPath.."CellphoneLoginViewXml");
require("MahjongSocket/socketManager");
require("EngineCore/ui");

local l_zorder_cellphone_view = 10005;
local l_dict = {["name"] = "cellphoneLogin_dict",
                ["keyIsRememberPwd"] = "keyIsRememberPwd",
                ["keyOpenCounts"] = "keyOpenCounts",
                ["keyAccount"] = "keyAccount",
                ["keyPassword"] = "keyPassword",
                ["keyBindAccount"] = "keyBindAccount",
                ["keyBindpassword"] = "keyBindpassword",
};

-- 界面索引
local l_view_type = {["login"] = 1, ["regist"] = 2, ["findpwd"] = 3};
local l_title_str = {[l_view_type.login] = "手机登录",
                    [l_view_type.regist] = "手机注册",
                    [l_view_type.findpwd] = "找回密码",
                    ["bind"] = "绑定手机"};
local l_editText_type = {["account"] = 1, ["pwd"] = 2, ["verify"] = 3};
local l_hint_text = {[l_editText_type.account] = "请输入11位手机号码", 
                    [l_editText_type.pwd] = "请输入密码",
                    [l_editText_type.verify] = "请输入验证码"};

local l_verify_remain_max = 60;
--字符串常量
local l_const_str = {
    ["getVerify"] = "获取验证码",
    ["ac_nil"] = "手机号码不能为空",
    ["ac_not_number"] = "输入必须是数字",
    ["ac_not_int"] = "手机号码必须是数字",
    ["ac_num_less_11"] = "手机号码必须是11位",
    ["pwd_nil"] = "密码不能为空",
    ["verify_nil"] = "验证码不能为空",
    ["ac_registed"] = "帐号已经注册过了",
    ["verify_sec"] = " S",
    ["other"] = "error No. is: ",
    ["regist"] = "注册",
    ["bind"] = "绑定",
    ["had_wideChar"] = "不能含有中文字符",
    };
--错误码
local l_error = {
    ok = 0, --无错误
    ac_nil = 1,--输入的手机帐号为空
    ac_num_less_11 = 2,--手机号码必须是11位
    ac_not_number = 3,--手机号码必须是数字
    ac_not_int = 4,--手机号码必须是整数
    pwd_nil = 5,--输入的密码格式错误
    verify_nil = 6, --输入的验证码错误
    ac_registed = 7,--帐号已经注册过了
    other = 100, --default
    had_wideChar = 8, --不能含有中文字符
};


--判断字符中是否有汉字
local function isHadWidChar(str)
    str = str or "";
    local lenInByte = #str
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte > 127 then
            return true;
        end
    end
    return false;
end


--加载字典
local LoadDict = function (self)
    l_data_dict = new(Dict, l_dict.name);
    l_data_dict:load();
    local dictOpenCounts = l_data_dict:getInt(l_dict.keyOpenCounts);
    --dictOpenCounts < 1则字典第一次被创建
    if dictOpenCounts < 1 then
        l_data_dict:setInt(l_dict.keyOpenCounts, dictOpenCounts+1);
        --默认为保存密码
        l_data_dict:setBoolean(l_dict.keyIsRememberPwd, true);
        l_data_dict:save();
    end 
end




CellphoneLogin = class(BaseLogin);
CellphoneLogin.ctor = function (self)
    DebugLog("[CellphoneLogin :ctor]");
    self.m_loginMethod = PlatformConfig.CellphoneLogin
    LoadDict();
end

CellphoneLogin.dtor = function (self)
    DebugLog("[CellphoneLogin :dtor]");
    delete(l_data_dict);
end

CellphoneLogin.getLoginType = function(self)
	return PlatformConfig.CellphoneLogin;
end

CellphoneLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityCellphone;
end

CellphoneLogin.login = function ( self, ... )
    DebugLog("[CellphoneLogin :login]");

	umengStatics_lua(kUmengBoyaaLogin);
	local params = ...;
	self.m_data = kCellphoneLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.CellphoneLogin);

   if GameConstant.lastLoginType and GameConstant.lastLoginType ~= self:getLoginType() then 
		local sitemid = g_DiskDataMgr:getAppData(kLoginSid .. self:getLoginType(), "");
		local token = g_DiskDataMgr:getAppData(kToken .. self:getLoginType(), "");
	
		if token ~= "" and token ~= "" then 
            self.m_view = nil;
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
			return;
		end
	end

    
	if GameConstant.isDisplayView then 
        self.m_view = new(CellphoneLoginWindow, self);
        self.m_view:setOnWindowHideListener(self, function (self)
            self.m_view = nil;
        end);
	    if HallScene_instance and HallScene_instance.m_mainView and self.m_view then
		    HallScene_instance.m_mainView:addChild(self.m_view);
	    end
    else
        self.m_view = nil;
        self:OnRequestLoginPHP(self:setSendLoginPHPdata());
    end
end

CellphoneLogin.setSendLoginPHPdata = function (self, bRegist)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
    
    local ac, pwd ="", ""
    local isRememberPassword = l_data_dict:getBoolean(l_dict.keyIsRememberPwd);
    if isRememberPassword == true then
        ac, pwd = GlobalDataManager.getInstance():getLoginSuccessAcPwd();
    end
    --php
    local send_data = {};
	send_data.phoneno = ac or ""--GameConstant.name;
	--send_data.verifycode = "";
	send_data.pwd = pwd or "";

	return send_data;
end

CellphoneLogin.setSendBindPHPdata = function (self, bRegist)
	local send_data = {};
    
    --php字段给之前，暂时先提交以下参数
    local send_data = {};
    
	return send_data;
end

----获取验证码
--CellphoneLogin.setGetVerifyPHPdata = function (self, data)
--	local send_data = {};

--    --php字段给之前，暂时先提交以下参数
--    local send_data = {};

--	return send_data;
--end

CellphoneLogin.clearGameData = function(self)

--GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
--GameConstant.bid = nil; 
--GameConstant.email =nil;
--GameConstant.phone = nil;
--GameConstant.deviceType = nil;
--GameConstant.sig = nil; 
--GameConstant.avatar = nil;
--GameConstant.city = nil;
--GameConstant.code = nil;
--GameConstant.country = nil;
--GameConstant.gender = nil;
--GameConstant.province = nil;
--GameConstant.imei = nil;
--GameConstant.name = nil;
--GameConstant.saveBid = nil;

	self.super.clearGameData( self );
end

--http 数据回调
CellphoneLogin.requestLoginCallBack = function (self, isSuccess, data)
	DebugLog("[CellphoneLogin.requestLoginCallBack]")
	GameConstant.requestLogin = false;
    
    local funLoginFail = function (self)
        if not self then
            return;
        end
        --登录失败
        --GlobalDataManager.getInstance():setLoginSuccessAcPwd("", "");
        g_DiskDataMgr:setAppData(kLoginSid .. self:getLoginType() , "");
		g_DiskDataMgr:setAppData(kToken .. self:getLoginType() , "");
		GameConstant.isLogin = kNoLogin;
    end

	PlatformFactory.curPlatform:setAPI(PlatformConfig.CellphoneLogin);
	if isSuccess and data then 
		mahjongPrint(data)
		local msg;
        if 1 == tonumber(data.status or 0) then    
           --手机帐号登录不显示bind提示
            if self.m_view then
                self.m_view:hideWnd();
            end
            GameConstant.isDisplayView = false;
            GlobalDataManager.getInstance():setIsCellAcccountLogin(true);

			GameConstant.isLogin = kAlreadyLogin;
            local ac, pwd = self.cellAc, self.cellPwd 
            if not ac then
                local sitemid = g_DiskDataMgr:getAppData(kLoginSid .. self:getLoginType(), "");
		        local token = g_DiskDataMgr:getAppData(kToken .. self:getLoginType(), "");

                ac, pwd = sitemid, token ;
            end
            GlobalDataManager.getInstance():setBindCellAcccount(ac);
            local isRememberPassword = l_data_dict:getBoolean(l_dict.keyIsRememberPwd);
            if isRememberPassword then
                GlobalDataManager.getInstance():setLoginSuccessAcPwd(ac, pwd)
            end
            
			g_DiskDataMgr:setAppData(kLoginSid .. self:getLoginType() , ac or "");
			g_DiskDataMgr:setAppData(kToken .. self:getLoginType() , pwd or "");
			GameConstant.lastLoginType = self:getLoginType();
            DebugLog("...............:"..ac);
            GlobalDataManager.getInstance():setCellBindAccount(ac);
            --通知大厅
            EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
		else
            funLoginFail(self);
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			DebugLog("---------------:"..tostring(msg));
            Banner.getInstance():showMsg(msg);
		end

		if data.userinfo and data.userinfo.visitorBounded then
			self.visitorBounded = tonumber(data.userinfo.visitorBounded) == 1;
		end
       
	else
        funLoginFail(self);
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
end
CellphoneLogin.getLoginIdentityIcon = function(self)
	return "Login/cellIcon.png";
end

CellphoneLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end














CellphoneLoginWindow = class(SCWindow);

CellphoneLoginWindow.m_data = {};

CellphoneLoginWindow.ctor = function ( self, delegate)
    DebugLog("[CellphoneLoginWindow :ctor]");

    --初始化
    self:init(delegate);
    --显示界面
    self:showWnd();
end

CellphoneLoginWindow.dtor = function (self)
    DebugLog("[CellphoneLoginWindow :dtor]");
    EditTextGlobal = nil;
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

--获取本地手机号码
CellphoneLoginWindow.getCellphoneNumber = function(self)
   
    local number = GameConstant.phone;
    return number;
end

--初始化控件
CellphoneLoginWindow.initWidgets = function(self)
    self.m_layout = SceneLoader.load(CellphoneLoginViewXml);
    self:addChild(self.m_layout);

    self.m_bg = publ_getItemFromTree(self.m_layout, {"bg"});
    self:setWindowNode( self.m_bg );
	self:setCoverEnable(true)
    self:setLevel(l_zorder_cellphone_view);

    self.m_viewLogin = publ_getItemFromTree(self.m_layout, {"bg", "view_login"});
    self.m_viewRegist = publ_getItemFromTree(self.m_layout, {"bg", "view_regist"});
    self.m_viewFindPwd = publ_getItemFromTree(self.m_layout, {"bg", "view_find_password"});
    self.m_btnClose = publ_getItemFromTree(self.m_layout, {"bg", "btn_close"});
    self.m_viewTitle = publ_getItemFromTree(self.m_layout, {"bg", "title"});

    self.m_widgetsLogin = {};
    self.m_widgetsRegist = {};
    self.m_widgetsFindPwd = {};

    --关闭按钮
    local btnClose = publ_getItemFromTree(self.m_layout, {"bg", "btn_close"});
    self.m_title = publ_getItemFromTree(self.m_layout, {"bg", "title"});

    btnClose:setOnClick(self, function(self)
			                    DebugLog("[CellphoneLoginWindow press btn close..]");
			                    self:hideWnd();
		                    end);

    --lgoin界面
    --账户
    self.m_widgetsLogin.textAccount = publ_getItemFromTree(self.m_viewLogin, {"account", "img", "edit_text"});
    --密码
    self.m_widgetsLogin.textPwd = publ_getItemFromTree(self.m_viewLogin, {"password", "img", "edit_text"});
    --错误提示
    self.m_widgetsLogin.textError = publ_getItemFromTree(self.m_viewLogin, { "text_error"});
    --记住密码
    self.m_widgetsLogin.cbGroupRememberPwd = publ_getItemFromTree(self.m_viewLogin, {"third_line", "cb_group"});
    self.m_widgetsLogin.cbRememberPwd = publ_getItemFromTree(self.m_viewLogin, {"third_line", "cb_group", "cb"});
    --忘记密码
    self.m_widgetsLogin.findPwd = publ_getItemFromTree(self.m_viewLogin, {"third_line", "find_pwd"});
    --注册按钮
    self.m_widgetsLogin.btnRegist = publ_getItemFromTree(self.m_viewLogin, {"btn_regist"});
    --登录按钮
    self.m_widgetsLogin.btnLongin = publ_getItemFromTree(self.m_viewLogin, {"btn_login"});



    --注册界面
    --账户
    self.m_widgetsRegist.textAccount = publ_getItemFromTree(self.m_viewRegist, {"account", "img", "edit_text"});
    --密码
    self.m_widgetsRegist.textPwd = publ_getItemFromTree(self.m_viewRegist, {"password", "img", "edit_text"});
    --错误提示
    self.m_widgetsRegist.textError = publ_getItemFromTree(self.m_viewRegist, { "text_error"});
    --输入验证码
    self.m_widgetsRegist.inputVerify = publ_getItemFromTree(self.m_viewRegist, {"verify", "img", "edit_text"});
    --获取验证码
    self.m_widgetsRegist.getVerify = publ_getItemFromTree(self.m_viewRegist, {"verify", "img2", "text"});
    --注册按钮
    self.m_widgetsRegist.btnRegist = publ_getItemFromTree(self.m_viewRegist, {"btn_regist"});

    --找回密码界面
    --账户
    self.m_widgetsFindPwd.textAccount = publ_getItemFromTree(self.m_viewFindPwd, {"account", "img", "edit_text"});
    --密码
    self.m_widgetsFindPwd.textPwd = publ_getItemFromTree(self.m_viewFindPwd, {"password", "img", "edit_text"});
    --错误提示
    self.m_widgetsFindPwd.textError = publ_getItemFromTree(self.m_viewFindPwd, { "text_error"});
    --输入验证码
    self.m_widgetsFindPwd.inputVerify = publ_getItemFromTree(self.m_viewFindPwd, {"verify", "img", "edit_text"});
    --获取验证码
    self.m_widgetsFindPwd.getVerify = publ_getItemFromTree(self.m_viewFindPwd, {"verify", "img2", "text"});
    --注册按钮
    self.m_widgetsFindPwd.btnOk = publ_getItemFromTree(self.m_viewFindPwd, {"btn_ok"});

    local maxlen = 11;
    self.m_widgetsLogin.textAccount:setMaxLength(maxlen);
    self.m_widgetsRegist.textAccount:setMaxLength(maxlen);
    self.m_widgetsFindPwd.textAccount:setMaxLength(maxlen);
    maxlen = 11;
    self.m_widgetsLogin.textPwd:setMaxLength(maxlen);
    self.m_widgetsRegist.textPwd:setMaxLength(maxlen);
    self.m_widgetsFindPwd.textPwd:setMaxLength(maxlen);
    maxlen = 11;
    self.m_widgetsRegist.inputVerify:setMaxLength(maxlen);
    self.m_widgetsFindPwd.inputVerify:setMaxLength(maxlen);
end

--设置edittext的ontextchange方法
CellphoneLoginWindow.EditTextSetOnTextChange = function (self, widget, editTextType)
    if not typeof(widget, EditText) then
        DebugLog("widget is not editText..");
        return
    end
    DebugLog("EditTextSetOnTextChange -- ");

    widget:setOnTextChange(self, function ( self )
	    local str = publ_trim(widget:getText());
	    local len = string.len(str);
        
   

        --判断传入的字符是否有效
        local bInvalid, errorNum = self:VerifyStrInvalid(str, editTextType);
        --显示错误文本
        self:ShowError(errorNum);



        --设置输入文本
	    if len ~= 0 and not bInvalid then
            --密码转**显示
            if editTextType == l_editText_type.pwd then
                self.m_data.pwd = str;
                str = "";
                for i=1,len do 
			        str = str .. "*";
                end
		    end 
		    widget:setText(str);
	    else
            widget:setText("");
		    widget:setHintText(l_hint_text[editTextType]);
	    end
	end);
end

--设置edittext的文本
CellphoneLoginWindow.EditTextSetText = function (self, widget, editTextType, str)
    if not typeof(widget, EditText) then
        DebugLog("widget is not editText..");
        return
    end
    local strTmp = "";
    --密码转**显示
    if editTextType == l_editText_type.pwd then
        local len = string.len(str);
        
        for i=1,len do 
			strTmp = strTmp .. "*";
        end
    else
        strTmp = str;
	end
    widget:setText(strTmp);
    local len = string.len(strTmp);
    if len == 0 then
		widget:setHintText(l_hint_text[editTextType]);
	end
end


--checkbox触摸事件
CellphoneLoginWindow.EventCheckBoxOnChange = function ( self )
    DebugLog("[CellphoneLoginWindow checkbox on change]");
    self:setIsRememberPwd(not self:getIsRememberPwd());

end

--事件 显示注册界面
CellphoneLoginWindow.EventShowViewRegist = function(self)
    DebugLog("[btn touch show view regist]");
    self:setCurrentViewType(l_view_type.regist);
    self:RefreshView();
end

--事件 发送php bind请求
CellphoneLoginWindow.EventDoBind = function (self)
    local ret, widget = self:VerifyOkDataBeforeSendHttp(l_view_type.regist, false);
    --send data
    if  ret and widget then
        local param = {};
        param.phoneno = widget.textAccount:getText();
        param.verifycode = (widget.inputVerify and widget.inputVerify:getText()) or "";
        param.pwd   = self.m_data.pwd or "";
        
        self.bindAccount = param.phoneno;
        self.bindPwd = param.pwd;
        SocketManager.getInstance():sendPack(PHP_CMD_REQUSET_CEllPHONE_BIND, param)
    end

end

--注册和登录公用
CellphoneLoginWindow.uitiFunLogin = function (self, loginType)--bRegist)
    loginType = loginType or l_view_type.login;
    local t = loginType;

    local ret, widget = self:VerifyOkDataBeforeSendHttp(t, true);
    --send data
    if  ret and widget then
        local param = {};
        param.phoneno = widget.textAccount:getText();
        param.verifycode = (widget.inputVerify and widget.inputVerify:getText()) or "";
        param.pwd   = self.m_data.pwd or "";

        if self.m_loginDelegate  
           and self.m_loginDelegate.OnRequestLoginPHP 
           and self.m_loginDelegate.setSendLoginPHPdata then
                self.m_loginDelegate.cellAc = param.phoneno;
                self.m_loginDelegate.cellPwd = param.pwd;
                self.m_loginDelegate:OnRequestLoginPHP(param);
        end     
    end
end

--事件 发送登录请求
CellphoneLoginWindow.EventDoLogin = function(self)
    DebugLog("[btn touch do login]");
    self:uitiFunLogin(l_view_type.login);
end

--事件 发送注册请求
CellphoneLoginWindow.EventDoRegist = function(self)
    DebugLog("[btn touch do regist]");
    if self.m_isBind then
        self:EventDoBind();
    else
        self:uitiFunLogin(l_view_type.regist);
    end
end

--事件 忘记密码 发送请求
CellphoneLoginWindow.EventDoFindPwd = function(self)
    DebugLog("[btn touch  Do FindPwd]");
    local ret, widget = self:VerifyOkDataBeforeSendHttp(l_view_type.findpwd, false);
    --send data
    if  ret and widget then
        local param = {};
        param.phoneno = widget.textAccount:getText();
        param.verifycode = widget.inputVerify:getText();
        param.pwd   = self.m_data.pwd or "";

        SocketManager.getInstance():sendPack(PHP_CMD_REQUSET_CEllPHONE_FIND_PASSWORD, param)
        --	param.loginType = PlatformConfig.CellphoneLogin; 
        --	param.type = "-1"; -- 忘记密码
        --HttpModule.getInstance():execute(HttpModule.s_cmds.requestGetVerify, param, self.m_phpEventVerify);
        --native_muti_login(param);       
    end
end

--事件 获取验证码
CellphoneLoginWindow.EventGetVerify = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    
    if kFingerUp == finger_action then
        
        DebugLog("[btn touch get verify]");

        local ret, widget = self:VerifyOkDataBeforeSendHttp(self:getCurrentViewType(), true);--l_view_type.regist, true);
        --send data
        if  ret and widget then
            --开启定时60s
            self:StartTimerGetVerify();

            local param = {};
            param.phoneno = widget.textAccount:getText();
            -- reg:注册  pwd:找回密码  remove为解绑
            param.act   = (self.m_viewType == l_view_type.regist and "reg") or "pwd";
            SocketManager.getInstance():sendPack(PHP_CMD_REQUSET_GET_VERIFY, param) 
        end


    end
end

--事件 显示界面忘记密码
CellphoneLoginWindow.EventShowViewFindPwd = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if kFingerUp == finger_action then
	    DebugLog("[btn touch show view find password]");
        self:setCurrentViewType(l_view_type.findpwd);
        self:RefreshView();
    end
end

--初始化视图内控件的触摸事件
CellphoneLoginWindow.initWidgetsEvent = function(self)

    self:setPasswordTouchEvent(self.m_widgetsLogin.textPwd);
    self:setPasswordTouchEvent(self.m_widgetsRegist.textPwd);
    self:setPasswordTouchEvent(self.m_widgetsFindPwd.textPwd);

    --设置editText改变时的操作
    self:EditTextSetOnTextChange(self.m_widgetsLogin.textAccount, l_editText_type.account);
    self:EditTextSetOnTextChange(self.m_widgetsLogin.textPwd, l_editText_type.pwd);

    self:EditTextSetOnTextChange(self.m_widgetsRegist.textAccount, l_editText_type.account);
    self:EditTextSetOnTextChange(self.m_widgetsRegist.textPwd, l_editText_type.pwd);
    self:EditTextSetOnTextChange(self.m_widgetsRegist.inputVerify, l_editText_type.verify);

    self:EditTextSetOnTextChange(self.m_widgetsFindPwd.textAccount, l_editText_type.account);
    self:EditTextSetOnTextChange(self.m_widgetsFindPwd.textPwd, l_editText_type.pwd);
    self:EditTextSetOnTextChange(self.m_widgetsFindPwd.inputVerify, l_editText_type.verify);

    --设置按钮事件
    self.m_widgetsLogin.btnLongin:setOnClick(self,CellphoneLoginWindow.EventDoLogin);
    self.m_widgetsLogin.btnRegist:setOnClick(self,CellphoneLoginWindow.EventShowViewRegist);
    self.m_widgetsLogin.findPwd:setEventTouch(self, CellphoneLoginWindow.EventShowViewFindPwd)

    self.m_widgetsRegist.btnRegist:setOnClick(self,CellphoneLoginWindow.EventDoRegist);
    self.m_widgetsRegist.getVerify:setEventTouch(self, CellphoneLoginWindow.EventGetVerify);

    self.m_widgetsFindPwd.btnOk:setOnClick(self,CellphoneLoginWindow.EventDoFindPwd);
    self.m_widgetsFindPwd.getVerify:setEventTouch(self, CellphoneLoginWindow.EventGetVerify); 
    
    --设置checkbox触摸事件
    self.m_widgetsLogin.cbGroupRememberPwd:setOnChange(self, CellphoneLoginWindow.EventCheckBoxOnChange); 
    
end

--
CellphoneLoginWindow.setPasswordTouchEvent = function (self, widgetPwd)

    local obj = {w = widgetPwd, o = self};
    widgetPwd:setEventTouch(self, function ( self, finger_action, x, y, drawing_id_first, drawing_id_current )
        if finger_action == kFingerDown then
            widgetPwd.m_startX = x;
            widgetPwd.m_startY = y;
            widgetPwd.m_touching = true;
        elseif finger_action == kFingerUp then
            if not widgetPwd.m_touching then return end;

            widgetPwd.m_touching = false;

            local diffX = math.abs(x - widgetPwd.m_startX);
            local diffY = math.abs(y - widgetPwd.m_startY);
            if diffX > widgetPwd.m_maxClickOffset
                or diffY > widgetPwd.m_maxClickOffset
                or (not widgetPwd.m_enable)
                or (drawing_id_first ~= drawing_id_current) then
                return
            end

            EditTextGlobal = widgetPwd;
            local x,y = widgetPwd:getAbsolutePos();
            local actualX= x * System.getLayoutScale();
            local actualY= y * System.getLayoutScale();


            local w,h = widgetPwd:getSize();
            local actualW= w * System.getLayoutScale();
            --local actualH= h * System.getLayoutScale();
            local actualH = 0;
            if System.getPlatform() == kPlatformAndroid then 
	   		    actualH = (h+12) * System.getLayoutScale();
		    else 
	            actualH = h * System.getLayoutScale();
		    end

            widgetPwd:setVisible(false);
            local textStr = self.m_data.pwd or ""--EditText.getText(widgetPwd)
            if self.m_viewType == l_view_type.regist then
               textStr = ""; 
            end 

		    dict_set_int(EditText.s_ex_dict_table_name,"inputMode",widgetPwd.m_inputMode);
		    dict_set_int(EditText.s_ex_dict_table_name,"inputFlag",widgetPwd.m_inputFlag);
		    dict_set_int(EditText.s_ex_dict_table_name,"returnType", kKeyboardReturnTypeDone);

		    ime_open_edit(textStr,
			    "",
			    widgetPwd.m_inputMode,
			    widgetPwd.m_inputFlag,
			    kKeyboardReturnTypeDone,
			    widgetPwd.m_maxLength or -1,"global",widgetPwd.m_fontName or "",(widgetPwd.m_res.m_fontSize or 24)* System.getLayoutScale(),
                widgetPwd.m_textColorR,widgetPwd.m_textColorG,widgetPwd.m_textColorB,
                actualX,actualY,actualW,actualH);
		    EditTextGlobal.setText(EditTextGlobal,"");
        end
    end);
end

--重置数据
CellphoneLoginWindow.resetData = function(self)
    self.bindObj = nil;
    self.m_data.errorText = "";
    self.m_data.account = "";
    self.m_data.pwd = "";
    self.m_data.inputVerify = "";
    self.m_data.getVerify = "";
    self.m_data.isHadSendVerify = false;
    self.m_data.eventIdGetVerify = nil;
    self.m_data.verifyRemain = l_verify_remain_max;

end

--初始化数据
CellphoneLoginWindow.initData = function(self)
    --设置默认界面为登录界面,如果未绑定过则进入注册界面
--    if GlobalDataManager.getInstance():getIsCellAcccountBind() then
--        self.m_viewType = l_view_type.login;
--    else
--        self.m_viewType = l_view_type.regist;
--    end
    self.m_viewType = l_view_type.login;
    self.m_isBind = false;
    --重置数据
    self:resetData();
    --加载本类所用的字典
    LoadDict();
end

--更新数据
CellphoneLoginWindow.updateData = function(self)
    --重置数据
    self:resetData();
    local ac, pwd = GlobalDataManager.getInstance():getLoginSuccessAcPwd();
    self.m_data.account = ac or "";
    if self:getIsRememberPwd() then
        self.m_data.pwd = pwd or "";
    else
        self.m_data.pwd = "";
    end
    local len = string.len(publ_trim(ac));
    if len <= 1 then
        self.m_data.pwd = "";
    end

    if self.m_viewType == l_view_type.login then
    elseif self.m_viewType == l_view_type.regist then
    elseif self.m_viewType == l_view_type.findpwd then
    end
end



--获取是否记住密码的状态
CellphoneLoginWindow.getIsRememberPwd = function (self)
    local isRememberPassword = l_data_dict:getBoolean(l_dict.keyIsRememberPwd);
    return isRememberPassword;
end

--set是否记住密码的状态
CellphoneLoginWindow.setIsRememberPwd = function (self, bRemember)
    --不接受nil或者非boolean变量 
    if bRemember == nil or not type(bRemember) == "boolean" then 
        return 
    end
    l_data_dict:setBoolean(l_dict.keyIsRememberPwd, bRemember);
    l_data_dict:save();
end





--初始化
CellphoneLoginWindow.init = function(self, loginDelegate)

    --初始化控件
    self:initWidgets();
    --初始化控件事件
    self:initWidgetsEvent();
    --初始化数据
    self:initData();

    self.m_loginDelegate = loginDelegate;
    -- php注册回调事件
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    --禁止窗外关闭
    --self:setCoverEnable(false);
    --刷新界面
    self:RefreshView();
end

--获取当前视图的id
CellphoneLoginWindow.getCurrentViewType = function(self)
    return self.m_viewType;
end

--设置当前视图的id
CellphoneLoginWindow.setCurrentViewType = function(self, t)
    if not self:VerifyViewTypeInvalid(t) then
        self.m_viewType = t;
    end
end

--刷新界面
CellphoneLoginWindow.RefreshView = function(self)
    
    --设置标题
    if self.m_isBind and self.m_viewType == l_view_type.regist then
        self.m_viewTitle:setText(l_title_str.bind);
    else
        self.m_viewTitle:setText(l_title_str[self.m_viewType] or "");
    end
    
    --设置界面显隐
    self.m_viewLogin:setVisible(self.m_viewType == l_view_type.login);
    self.m_viewRegist:setVisible(self.m_viewType == l_view_type.regist);
    self.m_viewFindPwd:setVisible(self.m_viewType == l_view_type.findpwd);
    
    --更新数据
    self:updateData();
        
    --刷新界面
    if self.m_viewType == l_view_type.login then
        self:RefreshViewLogin();
    elseif self.m_viewType == l_view_type.regist then
        self:RefreshViewRegist();
    elseif self.m_viewType == l_view_type.findpwd then
        self:RefreshViewFindPwd();
    end
end

--刷新登录界面
CellphoneLoginWindow.RefreshViewLogin = function(self)

    self:EditTextSetText(self.m_widgetsLogin.textAccount, l_editText_type.account, self.m_data.account);
    self:EditTextSetText(self.m_widgetsLogin.textPwd, l_editText_type.pwd, self.m_data.pwd);
    self.m_widgetsLogin.textError:setText(self.m_data.errorText);
    self.m_widgetsLogin.cbRememberPwd:setChecked(self:getIsRememberPwd());  
end

--刷新注册界面
CellphoneLoginWindow.RefreshViewRegist = function(self)
    self:EditTextSetText(self.m_widgetsRegist.textAccount, l_editText_type.account, "");--self.m_data.account);
    self:EditTextSetText(self.m_widgetsRegist.textPwd, l_editText_type.pwd, "");--self.m_data.pwd);
    self:EditTextSetText(self.m_widgetsRegist.inputVerify, l_editText_type.verify, self.m_data.inputVerify);
    self.m_widgetsRegist.textError:setText(self.m_data.errorText);
    self:resetTextGetVeirfy();

    local text = publ_getItemFromTree(self.m_widgetsRegist.btnRegist,{"title"}); 
    if self.m_isBind and self.m_viewType == l_view_type.regist then
        text:setText(l_const_str.bind);
    else
        text:setText(l_const_str.regist);
    end
end

--刷新找回密码界面
CellphoneLoginWindow.RefreshViewFindPwd = function(self)
    self:EditTextSetText(self.m_widgetsFindPwd.textAccount, l_editText_type.account, "");--self.m_data.account);
    self:EditTextSetText(self.m_widgetsFindPwd.textPwd, l_editText_type.pwd, "")--;self.m_data.pwd);
    self:EditTextSetText(self.m_widgetsFindPwd.inputVerify, l_editText_type.verify, self.m_data.inputVerify);
    self.m_widgetsFindPwd.textError:setText(self.m_data.errorText);
    self:resetTextGetVeirfy();
end

--判断传入的视图id是否有效
CellphoneLoginWindow.VerifyViewTypeInvalid = function(self, t)
    if not t then
        DebugLog("[CellphoneLoginWindow :IsViewTypeInvalid] t is nil");
        return true
    end
    for _, v in pairs(l_view_type) do
        if v == tonumber(t) then
            return false;
        end
    end
    return true;
end

--判断传入的字符串是否有效
CellphoneLoginWindow.VerifyStrInvalid = function(self, str, strType)
    local ret, errorNum = false, l_error.ok;
    if strType == l_editText_type.account then
        ret, errorNum = self:VerifyAccountInvalid(str);
    elseif strType == l_editText_type.pwd then
        ret, errorNum = self:VerifyPwdInvalid(str);
    elseif strType == l_editText_type.verify then
        ret, errorNum = self:VerifyStrVerifyInvalid(str);
    end
    return ret, errorNum;
end

--发送http前先对数据验证下，ok才可以发送
CellphoneLoginWindow.VerifyOkDataBeforeSendHttp = function(self, viewType, bIgnoreVerifyCode)
    local widget = nil;
    if viewType == l_view_type.login then
        widget = self.m_widgetsLogin;
    elseif viewType == l_view_type.regist then
        widget = self.m_widgetsRegist;
    elseif viewType == l_view_type.findpwd then
        widget = self.m_widgetsFindPwd;
    end
    if not widget then
        return false;
    end

    --检查帐号和密码是否符合要求
    local acText = widget.textAccount:getText();
    local bInvalid, errorNo = self:VerifyAccountInvalid(acText);
    if bInvalid then
        self:ShowError(errorNo);
        return false;
    end

    local pwdText = widget.textPwd:getText();
    bInvalid, errorNo = self:VerifyPwdInvalid(pwdText);
    if bInvalid then
        self:ShowError(errorNo);
    end
--    --登录界面没有验证码
--    if widget.inputVerify == nil and viewType == l_view_type.login then
--         return true, widget;
--    end
    if bIgnoreVerifyCode == true then
        return not bInvalid, widget;
    end
    local verifyText = widget.inputVerify:getText();
    bInvalid, errorNo = self:VerifyStrVerifyInvalid(verifyText);
    if bInvalid then
        self:ShowError(errorNo);
        return false;
    end
    return true, widget;
end

--判断手机号是否有效
CellphoneLoginWindow.VerifyAccountInvalid = function(self, account)
    local ret, errorNum = false, l_error.ok;
    local acTrim = publ_trim(account);
    local strLen = string.len(acTrim);
    --不能为空
    if not account or strLen < 1 then
        return true, l_error.ac_nil;
    end

    --必须是数字
    local ac = tonumber(account);
    if not ac then
        return true, l_error.ac_not_number;
    end

    --不能是小数
    local temp = math.mod(ac,1)
    if temp>0 then
        return true, l_error.ac_not_int;
    end

    --数字必须是11位      18676543221
    local const_11 = 10000000000;    
    temp = ac /const_11;
    if temp < 1 or (ac /(const_11*10) >= 1 )then
        return true, l_error.ac_num_less_11;
    end
    return ret, errorNum;
end

--判断密码是否有效
CellphoneLoginWindow.VerifyPwdInvalid = function(self, pwd)
    local ret, errorNum = false, l_error.ok;
    local pwdTrim = publ_trim(pwd);
    local strLen = string.len(pwdTrim);
    if not pwd or strLen < 1 then
        return true, l_error.pwd_nil;
    end
    
    if (isHadWidChar(pwd) == true) then
        return true, l_error.had_wideChar;
    end

    return ret, errorNum;
end

--判断验证码是否有效
CellphoneLoginWindow.VerifyStrVerifyInvalid = function(self, v)
    local ret, errorNum = false, l_error.ok;
    local vTrim = publ_trim(v);
    local strLen = string.len(vTrim);
    if not v or strLen < 1 then
        return true, l_error.verify_nil;
    end
    --必须是数字
    local v = tonumber(v);
    if not v then
        return true, l_error.ac_not_number;
    end
    if (isHadWidChar(pwd) == true) then
        return true, l_error.had_wideChar;
    end
    return ret, errorNum;
end

--重置获取验证码按钮
CellphoneLoginWindow.resetTextGetVeirfy = function (self)
    local target = (self.m_viewType == l_view_type.regist and self.m_widgetsRegist.getVerify) 
                    or self.m_widgetsFindPwd.getVerify;
    if self.m_data.eventIdGetVerify then
        target:removeProp(self.m_data.eventIdGetVerify);
    end
    self.m_data.verifyRemain = l_verify_remain_max;
    target:setText(l_const_str.getVerify);
    target:setColor(0x84,0x3B,0x00);
    local parent = target:getParent();
    if parent then
        parent:setPickable(true);
        parent:setFile("Login/btnVefiry_1.png");
    end
end
--停止获取验证码的定时器
CellphoneLoginWindow.StopTimerGetVerify = function (self)
    self:resetTextGetVeirfy();
end

--获取验证码的定时器的回调
CellphoneLoginWindow.CallbackTimerGetVerify = function (self)
    local target = (self.m_viewType == l_view_type.regist and self.m_widgetsRegist.getVerify) or                                          self.m_widgetsFindPwd.getVerify;
    
    self.m_data.verifyRemain = self.m_data.verifyRemain - 1;
    if self.m_data.verifyRemain <= 0 then
        self:resetTextGetVeirfy();
        return;
    end
    local str = tostring(self.m_data.verifyRemain)..l_const_str.verify_sec;
    target:setText(str);


end

--开始获取验证码的定时器
CellphoneLoginWindow.StartTimerGetVerify = function (self)
    self:StopTimerGetVerify();
    self.m_data.eventIdGetVerify =  EventDispatcher.getInstance():getUserEvent();
    local target = (self.m_viewType == l_view_type.regist and self.m_widgetsRegist.getVerify) or                                          self.m_widgetsFindPwd.getVerify;
    local str = tostring(self.m_data.verifyRemain)..l_const_str.verify_sec;
    target:setText(str);
    target:setColor(0x50,0x50,0x50);
    local parent = target:getParent();
    if parent then
        parent:setPickable(false);
        parent:setFile("Login/btnVerify_2.png");
    end
    local anim = target:addPropTranslate(self.m_data.eventIdGetVerify, kAnimRepeat, 1000, 0, 0, 0, 0, 0);
    anim:setEvent(self, self.CallbackTimerGetVerify);
end


--window的错误展示
CellphoneLoginWindow.ShowError = function (self, errorId)
    local widget, errorStr = nil, nil;
    if errorId == nil then
        return;
    elseif errorId == l_error.ac_nil then
        errorStr = l_const_str.ac_nil;
    elseif errorId == l_error.pwd_nil then
        errorStr = l_const_str.pwd_nil;
    elseif errorId == l_error.verify_nil then
        errorStr = l_const_str.verify_nil;
    elseif errorId == l_error.ac_not_int then
        errorStr = l_const_str.ac_not_int;
    elseif errorId == l_error.ac_num_less_11 then
        errorStr = l_const_str.ac_num_less_11;
    elseif errorId == l_error.ac_not_number then
        errorStr = l_const_str.ac_not_number;
    elseif errorId == l_error.had_wideChar then
        errorStr = l_const_str.had_wideChar;
    elseif errorId ~= l_error.ok then
        errorStr = l_const_str.other ..errorId;
    end

--    if widget and errorStr then
--        widget:setText(errorStr);
--    end
    if errorStr then
        Banner.getInstance():showMsg(errorStr);
    end
    
end

--重置错误显示
CellphoneLoginWindow.ClearShowError = function (self)
end


--获取验证码php回调
CellphoneLoginWindow.geVefifyCallback = function ( self, isSuccess, data )
	DebugLog( "[CellphoneLoginWindow:geVefifyCallback]" );
    
	if not isSuccess or not data then
        Banner.getInstance():showMsg(tostring(data.msg));
        self:StopTimerGetVerify();
		return;
	end

	if 1 ~= tonumber(data.status or 0) then
        Banner.getInstance():showMsg(tostring(data.msg));
        self:StopTimerGetVerify();
		return;
	end
end

--http帐号bind回调
CellphoneLoginWindow.bindCallback = function ( self, isSuccess, data )
	DebugLog( "[CellphoneLoginWindow:bindCallback]" );

    

	if not isSuccess or not data then
        self:StopTimerGetVerify();
        Banner.getInstance():showMsg(data.msg or "绑定失败");
		return;
	end

    local msg = data.msg 
	if 1 ~= tonumber(data.status or 0) then
        self:StopTimerGetVerify();
        if msg then
            Banner.getInstance():showMsg(msg);
        end
		return;
	end
    if 1 == tonumber(data.status or 0) then
        if msg then
            --Banner.getInstance():showMsg(msg);
        end
        --清除 大厅和设置界面的bind标记
        GlobalDataManager.getInstance():setIsCellAcccountLogin(true);
        
        --绑定成功，则设置绑定的密码
        GlobalDataManager.getInstance():setBindCellAcccount(self.bindAccount);
        if self:getIsRememberPwd() then
            GlobalDataManager.getInstance():setLoginSuccessAcPwd(self.bindAccount, self.bindPwd)
        end
        
        if HallScene_instance then
		    HallScene_instance.m_topLayer:displayUpdateTip()
	    end
        GlobalDataManager.getInstance():setCellBindAccount(self:getBindAccountPwd());
--        --增加金币
--        local money = tonumber(data.data.bindReward or 0);
--        PlayerManager.getInstance():myself():addMoney(money);

--        --金币掉落动画
--        showGoldDropAnimation();
--        AnimationAwardTips.play("绑定成功，恭喜获得"..tostring(money).."金币。");
        
        if HallScene_instance and HallScene_instance.m_bottomLayer.taskWindow then
            HallScene_instance.m_bottomLayer.taskWindow:setBenefitBindItemStateAward();
        end

        self:hideWnd();
    end
    
    



end

--http找回密码回调
CellphoneLoginWindow.findPwdCallback = function ( self, isSuccess, data )
	DebugLog( "[CellphoneLoginWindow:findPwdCallback]" );
	if not isSuccess or not data then
        Banner.getInstance():showMsg(tostring(data));
		return;
	end

	if 1 ~= tonumber(data.status or 0) then
		Banner.getInstance():showMsg(data.msg or "修改密码失败");
		return;
	end
    local msg = tostring(data.msg) or "修改密码成功";
    Banner.getInstance():showMsg(msg);

    self:StopTimerGetVerify();

    --自动登录
    self:uitiFunLogin(l_view_type.findpwd);

end

CellphoneLoginWindow.showViewBind = function (self)
    local view = new(CellphoneLoginWindow, nil);
    view.m_isBind = true;
    view:setCurrentViewType(l_view_type.regist);
    view:RefreshView();
	if HallScene_instance and HallScene_instance.m_mainView and view then
		HallScene_instance.m_mainView:addChild(view);
	end
end



--showExchangeIfNoBind
CellphoneLoginWindow.showExchangeIfNoBind = function (self, obj)
    self.bindObj = obj;
    local text = "该帐号需要绑定手机后方可兑换实物奖励";
    local view = PopuFrame.showNormalDialog( "温馨提示", text, GameConstant.curGameSceneRef, nil,nil,true, false,"绑定手机","取消");
		view:setConfirmCallback(self, function ( self )
			self:showViewBind();
		end);
end


CellphoneLoginWindow.getBindAccountPwd = function (self)
    local ac = l_data_dict:getString(l_dict.keyBindAccount) or "";
    local pwd = l_data_dict:getString(l_dict.keyBindpassword) or "";
    return ac, pwd;
end
CellphoneLoginWindow.setBindAccount = function (self, ac, pwd)
    l_data_dict:setString(l_dict.keyBindAccount, ac);
    l_data_dict:setString(l_dict.keyBindpassword, pwd);
end

CellphoneLoginWindow.onPhpMsgResponse = function( self, param, cmd, isSuccess)
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end


CellphoneLoginWindow.phpMsgResponseCallBackFuncMap =
{
    [PHP_CMD_REQUSET_GET_VERIFY] = CellphoneLoginWindow.geVefifyCallback,
    [PHP_CMD_REQUSET_CEllPHONE_BIND] = CellphoneLoginWindow.bindCallback,
    [PHP_CMD_REQUSET_CEllPHONE_FIND_PASSWORD] = CellphoneLoginWindow.findPwdCallback,
};


--global parameters to request the http,saving for a map.
CellphoneLogin.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_LOGIN] = CellphoneLogin.requestLoginCallBack,
};


