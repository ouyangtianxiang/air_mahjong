--[[
	className    	     :  ViewPushMoreGame
	Description  	     :  界面：互推，更多游戏；
	create-time 	     :  4-1-2016
	create-author        :  NoahHan
--]]

--    self.m_layout = SceneLoader.load(CellphoneLoginViewXml);
--    self:addChild(self.m_layout);

local moreGamesViewXml = require(ViewLuaPath.."moreGamesViewXml");
local moreGameListItemXml = require(ViewLuaPath.."moreGameListItemXml");

 --1未下载，2下载中，3下载完成，4已经安装
l_btn_state = {
                unDownload = 1,
                downloading = 2,
                install = 3,
                installed = 4;
                reward = 5,
                open = 6,
                installing = 7,--安装中
                rewarding = 8,
};

l_btn_config = {
[l_btn_state.unDownload] = {text = "下载", btnFile = "Commonx/green_small_btn.png", touchEnable = true},
[l_btn_state.downloading] = {text = "下载中", btnFile = "Commonx/green_small_btn.png", touchEnable = false},
[l_btn_state.install] = {text = "安装", btnFile = "Commonx/green_small_btn.png", touchEnable = true},
[l_btn_state.open] = {text = " 打开", btnFile = "Commonx/yellow_small_btn.png", touchEnable = true},
[l_btn_state.installed] = {text = "安装完成", btnFile = "Commonx/yellow_small_btn.png", touchEnable = true},
[l_btn_state.reward] = {text = "领奖", btnFile = "Commonx/yellow_small_btn.png", touchEnable = true},
[l_btn_state.installing] = {text = "安装中", btnFile = "Commonx/yellow_small_btn.png", touchEnable = false},
[l_btn_state.rewarding] = {text = "领奖中", btnFile = "Commonx/yellow_small_btn.png", touchEnable = false},
};

local l_img_default = {};
l_img_default.icon = "Hall/task/icon_default.png";

local l_all_btn ={};

local l_all_icon_widget = {};
local l_data_downloadImgs = {};

--展示二维码图片
local function create_QrCodeWnd(imgName)
    local share_game_layout = require(ViewLuaPath.."share_game_layout");
    --imgName = "Commonx/green_small_btn.png";
    DebugLog("create_QrCodeWnd:imgName:"..imgName);

    local window = new(SCWindow);

    window:addToRoot();
    window:setCoverEnable(true)

    local view = SceneLoader.load(share_game_layout);
    window:addChild(view);
    view:setPos(100,0);

    local imgParent = publ_getItemFromTree(view, {"bg"});

    window:setWindowNode(view);
    window:showWnd();
    local img = new(Image, imgName);
    if img then
        img:setAlign(kAlignTop);
        img:setPos(0, 25)
        imgParent:addChild(img);
    end
end

local function update_btn_state(btn, state)
    DebugLog("update_btn_state:"..(state or -1));
    if not btn or not state then
        return;
    end
    DebugLog("update_btn_state:"..state);
    local config = l_btn_config[state];
    if config and btn then
        btn.btnState = state;
        btn:setFile(config.btnFile);
        publ_getItemFromTree(btn, {"text"}):setText(config.text);
        btn:setPickable(config.touchEnable);
        --btn:setIsGray(not config.touchEnable);
    end
end

--数据初始化控件
local function util_set_widget(w, d, bLeft)
    if bLeft == nil then
        bLeft = false;
    end
    if not w or not d then
        return;
    end
    w.title:setText(d.name);
    w.detail:setText((bLeft and d.detail) or d.title);
    w.packageSize:setText(d.awards);--(tostring(d.pkgsize).."M");
    table.insert(l_all_icon_widget, w.icon);
    table.insert(l_data_downloadImgs, d.icon);
    w.icon.debugName = d.name;
    local isExist , localDir = NativeManager.getInstance():downloadImage(d.icon);
    w.icon.imageName = localDir
	if isExist then -- 图片已下载
        DebugLog("util_set_widget:localDir"..localDir);
		w.icon:setFile(localDir);
    else
        w.icon:setFile(l_img_default.icon);
	end
    update_btn_state(w.btn, d.btnState);

    local obj = {btn = w.btn, data = d};
    table.insert(l_all_btn, obj);
end

--
local function util_convert_pkgsize(size)
    local pkgsize = size or 0;
    pkgsize = pkgsize/(1024*1024);
    if pkgsize <= 0 then
        return math.ceil(pkgsize);
    end

    if math.ceil(pkgsize) == pkgsize then
        pkgsize = math.ceil(pkgsize);
    else
        pkgsize = math.ceil(pkgsize) - 1;
    end
    return pkgsize;
end

local function util_set_data(dataDec, dataSrc)
    if not (dataDec and dataSrc) then
        return;
    end
    --dataDec.realPkgSize = dataSrc.pkgsize;
    DebugLog("hyq111111111111:"..(dataSrc.pkgsize or -1));
    dataDec.pkgsize = dataSrc.pkgsize;--util_convert_pkgsize(dataSrc.pkgsize);
    dataDec.pkgname = dataSrc.pkgname;
    dataDec.gameid = dataSrc.gameid;--gameid
    dataDec.icon = dataSrc.icon;--cion
    dataDec.name = dataSrc.gname;--名字
    dataDec.title = dataSrc.shortdesc;--简短介绍
    dataDec.detail = dataSrc.desc;--详细描述
    dataDec.sortIndex = tonumber(dataSrc.sort);--排序
    dataDec.awards = dataSrc.awards.."金币";--奖励
    dataDec.downloadUrl = dataSrc.dl;--下载地址
    dataDec.qrCode = dataSrc.url;--二维码
    dataDec.hasBeenAwarded = tonumber(dataSrc.hasBeenAwarded) or 0;
end

--
local function find_btn_by_pkgname ( pkgname)
    DebugLog("ViewPushMoreGame:find_btn_by_pkgname:"..(pkgname or "-1"));
    if not pkgname then
        return nil;
    end

    for k,v in pairs(l_all_btn) do
        DebugLog("l_all_btn:name:"..tostring(v.data.name or -1));
        if v.data.pkgname == pkgname then
            DebugLog("find_btn_by_pkgname return :name:"..tostring(v.data.name or -1));
            return v;
        end
    end
     DebugLog("ViewPushMoreGame:find_btn_by_pkgname:return nil");
    return nil;
end


--
local function get_my_api()
    local strApi = string.format("%#x", tostring(GameConstant.api))
    strApi = string.sub(strApi, 3,5);
    local api = tonumber(strApi);
    api = api or -1;

    return api;
end


--调用java接口获取当前app的按钮状态
local function native_get_app_state(pkgname, bHadRecvAward)
    DebugLog("ViewPushMoreGame:native_get_app_state:"..(pkgname or "-1"));

    if not pkgname then
        return l_btn_state.unDownload;
    end
    local state = l_btn_state.unDownload;
    if not isPlatform_Win32() then
        local data = {};
        data.name = pkgname or "";
        local strJson = json.encode(data);
        native_to_get_value(kGetDownloadPackageStatus, strJson);
        --1未下载，2下载中，3下载完成，4已经安装

        state = dict_get_string(kGetDownloadPackageStatus, kGetDownloadPackageStatus .. kResultPostfix)--, "1")
    end
    state =  state or l_btn_state.unDownload;
    state = tonumber(state);
    if state == l_btn_state.installed then
        --如果已经领过奖励了，显示打开
        DebugLog("native_get_app_state:bHadRecvAward"..bHadRecvAward);
        return bHadRecvAward == 1 and l_btn_state.open or l_btn_state.reward;
    else

    end

    DebugLog("native_get_app_state:"..pkgname.." state:"..state);
    return tonumber(state);
end

--java接口下载
local function native_do_download(pkgname, downloadUrl, pkgsize)
    DebugLog("ViewPushMoreGame:native_do_download:"..(pkgname or "-1").." :"..(downloadUrl or "-1"));
    if isPlatform_Win32() or not pkgname or not downloadUrl then
        return;
    end
    local data = {};
	data.name = pkgname or "";
	data.url = downloadUrl or ""
    --data.pkgsize = pkgsize;

    DebugLog("native_do_download pkgname:"..data.name.." downloadUrl"..data.url);

	local json = json.encode(data)
	native_to_java(kDownloadPackage, json)
end

--java 接口 安装
local function native_do_install(pkgname)

    DebugLog("ViewPushMoreGame:native_do_install:"..(pkgname or "-1"));
    if isPlatform_Win32() or not pkgname then
        return;
    end
	local data = {}
	data.name = pkgname or "";

    DebugLog("native_do_install pkgname:"..data.name);

	local json = json.encode(data)
	native_to_java(kInstallPackage, json)
end

--java 接口 打开
local function native_do_open(pkgname)
    DebugLog("ViewPushMoreGame:native_do_open");
    if isPlatform_Win32() or not pkgname then
        return;
    end
	local data = {}
	data.name = pkgname or "";

    DebugLog("native_do_open pkgname:"..data.name);

	local json = json.encode(data)
	native_to_java(kOpenPackage, json)
end

--展示2维码图片
local function native_do_show_qrCode( downloadUrl)
    DebugLog("native_do_show_qrCode:downloadUrl:"..(downloadUrl or -1));
    local param = {}
	param.url = downloadUrl;
	local jsonStr = json.encode(param)
	native_to_java(kCreateQr, jsonStr)

end

--获取是否已下载
local function check_app_is_download(pkgname, hasBeenAwarded)
    if not pkgname then
        return false;
    end
    DebugLog("ViewPushMoreGame:check_app_is_download");
    local state = native_get_app_state(pkgname, hasBeenAwarded);
    return not (state == l_btn_state.unDownload);
end

--调用java接口 检测app是否已经安装
local function check_app_is_install(gameid)
    return false;
end

--php请求： 领奖
local function require_get_awards(gameid)
    gameid = gameid or -1;
	Loading.showLoadingAnim("正在领奖:".. gameid);
    local param_data = {};
    param_data.gameid = gameid;--gameid
	SocketManager.getInstance():sendPack(PHP_CMD_REQUSET_MORE_GAMES_GET_AWARDS, param_data)
end

--list item
local MoreGameListItem = class(Node);

MoreGameListItem.ctor = function (self, data)

    self:initData(data);
    self:initWidgets();
    util_set_widget(self, self.m_data, false);
end

MoreGameListItem.dtor = function (self)
    self:removeAllChildren();

end

--初始化数据
MoreGameListItem.initData = function (self, data)
    self.m_data = data;
end

--初始化widget
MoreGameListItem.initWidgets = function (self)
    --local api = get_my_api();
    --设置视图 align
    self:setAlign(kAlignTopLeft);
    self:setPos(0,0);

    self.m_layout = SceneLoader.load(moreGameListItemXml);
    self:addChild(self.m_layout);
    self:setSize(self.m_layout:getSize());

    self.icon = publ_getItemFromTree(self.m_layout, {"bg", "icon"});
    self.title = publ_getItemFromTree(self.m_layout, {"bg", "text_title"});
    self.detail = publ_getItemFromTree(self.m_layout, {"bg", "text_detail"});
    self.packageSize = publ_getItemFromTree(self.m_layout, {"bg", "text_size"});
    self.btn = publ_getItemFromTree(self.m_layout, {"bg", "btn"});

    --
    self.icon:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if kFingerUp == finger_action then
            native_do_show_qrCode(self.m_data.qrCode);
        end
    end);

    --领奖
    local obj = {bLeft = false, o = self };
    self.btn:setOnClick(obj,ViewPushMoreGame.btnOnClick);

end

--刷新控件
MoreGameListItem.update = function(self)

end


ViewPushMoreGame = class(Node);

ViewPushMoreGame.ctor = function (self, data)

    --初始化控件
    self:initWidgets();
    --初始化数据
    self:initData(data);
    --刷新视图
    self:update();
end

ViewPushMoreGame.dtor = function (self)
    DebugLog("[ViewPushMoreGame dtor]");

    l_all_btn = {};
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);

end

--初始化控件
ViewPushMoreGame.initWidgets = function (self)
    --设置视图 align
    self:setAlign(kAlignCenter);
    self:setPos(0,0);

    self.m_layout = SceneLoader.load(moreGamesViewXml);
    self:addChild(self.m_layout);
    --self:setSize(self.m_layout:getSize());
    --
    self.m_leftPart = publ_getItemFromTree(self.m_layout, {"bg", "node"});
    self.m_leftPart.icon = publ_getItemFromTree(self.m_leftPart, { "icon"});
    self.m_leftPart.title = publ_getItemFromTree(self.m_leftPart, { "text_title"});
    self.m_leftPart.packageSize = publ_getItemFromTree(self.m_leftPart, { "text_size"});
    self.m_leftPart.title = publ_getItemFromTree(self.m_leftPart, {"text_title"});
    self.m_leftPart.detail = publ_getItemFromTree(self.m_leftPart, { "text_detail"});
    self.m_leftPart.btn = publ_getItemFromTree(self.m_leftPart, { "btn"});

    --其实这只是一张图片
    self.btn_more_game = publ_getItemFromTree(self.m_layout, {"bg", "btn_more_game"})
    self.btn_more_game:setPickable(false);

    --listview
    self.m_listview = publ_getItemFromTree(self.m_layout, {"bg", "ListView"});
    self.m_listview:setAdapter(nil);

    -- php注册回调事件
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    --图片下载的监听
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);

    self.m_leftPart.icon:setEventTouch(self, function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
        if kFingerUp == finger_action then
	        DebugLog("[btn touch icon]");
            native_do_show_qrCode(self.m_data[1].qrCode);
        end
    end);

    local obj = {bLeft = true, o = self};
    self.m_leftPart.btn:setOnClick(obj,ViewPushMoreGame.btnOnClick);

end

--获得按钮的状态
ViewPushMoreGame.getBtnState = function (self, pkgname, hasBeenAwarded)

    local state = native_get_app_state(pkgname, hasBeenAwarded);
    return state;
end

--按钮事件
ViewPushMoreGame.btnOnClick = function (obj)
--    local gameid = self.m_data[1].gameid;

    local data = nil;
    if obj.bLeft then
        data = obj.o.m_data[1];
    else
        data = obj.o.m_data;
    end

    if not data then
        return
    end;

    local btn = nil
    if obj.bLeft then
        btn = obj.o.m_leftPart.btn;
    else
        btn = obj.o.btn;
    end

    --
    local state = btn.btnState;--native_get_app_state(data.pkgname, data.hasBeenAwarded);
    DebugLog("[ViewPushMoreGame.btnOnClick]:state "..state.." data.pkgname "..data.pkgname);
    --返回游戏后再获取次状态

    if state == l_btn_state.unDownload then
        ---DebugLog("GameConstant.net..: "..tostring(GameConstant.net).." :"..tonumber(GameConstant.net or -1));
        if GameConstant.iosDeviceType>0 then
          native_do_download(data.pkgname, data.downloadUrl, data.pkgsize);
          return;
        end
        if "wifi" ~= GameConstant.net then

            local view = PopuFrame.showNormalDialog( "下载", "      您当前处于非wifi环境，是否要继续下载？",
                GameConstant.curGameSceneRef, nil, nil, false );
	        view:setConfirmCallback(obj, function ( obj )
                update_btn_state(btn, l_btn_state.downloading);
                native_do_download(data.pkgname, data.downloadUrl, data.pkgsize);
	        end);
	        view:setCallback(view, function ( view, isShow )
		        if not isShow then
			        
		        end
	        end);
	        view:setHideCloseBtn(true);
        else
            update_btn_state(btn, l_btn_state.downloading);
            native_do_download(data.pkgname, data.downloadUrl, data.pkgsize);
        end

    elseif state == l_btn_state.install then
        update_btn_state(btn, l_btn_state.installing);
        native_do_install(data.pkgname);

    elseif state == l_btn_state.reward then
        DebugLog("领奖 gameid:"..(data.gameid));
        update_btn_state(btn, l_btn_state.open);
        require_get_awards(data.gameid);

    elseif state == l_btn_state.open then
        native_do_open(data.pkgname);
    end
end

--判断是不是当前包
ViewPushMoreGame.isCurrentPackage = function (self, gameid)
    local api = get_my_api();
    gameid = gameid or -1;

    return api == tonumber(gameid);
end

--初始化数据
ViewPushMoreGame.initData = function (self, data)
    data = data or {};
    self.m_data = {};
    l_data_downloadImgs = {};
    l_all_icon_widget = {};
    if not (data and type(data)=="table") then
        return;
    end
    local t_unDownload = {};
    local t_other = {};
    --copy data
    for i = 1, #data do
        if self:isCurrentPackage(data[i].gameid) == false then
            local d = {};
            util_set_data(d, data[i]);

            d.btnState = self:getBtnState(d.pkgname, d.hasBeenAwarded);
            if not check_app_is_download(d.pkgname, d.hasBeenAwarded) then
                table.insert(t_unDownload, d);
            else
                table.insert(t_other, d);
            end
        end
    end
    local funSort = function (t)
        if #t < 1 then
            return;
        end
        table.sort(t, function (t1, t2)
            return t1.sortIndex < t2.sortIndex;
        end);
    end
    --sort
    funSort(t_unDownload);
    funSort(t_other);

    local funCopy = function (dec, src)
        if src and #src < 1 then return end;
        for i = 1, #src do
            table.insert(dec, src[i]);
        end
    end
    --insert
    funCopy(self.m_data, t_unDownload);
    funCopy(self.m_data, t_other);
end

--刷新视图
ViewPushMoreGame.update = function(self)
    self.m_layout:setVisible(false);
    local data = self.m_data;
    if not (data and data[1]) then
        return;
    end
    self.m_layout:setVisible(true);

    --根据数据设置控件
    util_set_widget(self.m_leftPart, data[1], true);

    --table.remove(data,1);
    local dd = {};
    for i = 2, #data do
        table.insert(dd, data[i]);
    end
    if #dd > 0 then
        local adapter = new(CacheAdapter, MoreGameListItem, dd);
        self.m_listview:setAdapter(adapter);
    end

end

--刷新icon界面
ViewPushMoreGame.updateIcon = function(self)
    DebugLog("ViewPushMoreGame:updateIcon");
    local data = l_data_downloadImgs;
    for i = 1, #data  do
        local node =  l_all_icon_widget[i];
        if node then
            DebugLog("ViewPushMoreGame.updateIcon:localDir"..i.. node.debugName);
            local isExist , localDir = NativeManager.getInstance():downloadImage(data[i]);
	        if publ_isFileExsit_lua(localDir ) then -- 图片已下载
               DebugLog("ViewPushMoreGame.updateIcon:localDir"..localDir);
		       node:setFile(localDir);
            else
                DebugLog("ViewPushMoreGame.updateIcon:localDir==default");
                node:setFile(l_img_default.icon);
	        end
        end
    end
end

--判断接收的java回调的下载图片是不是当前界面下载的
ViewPushMoreGame.isInDowndingImgs =function (self, imgName)
    local imgs = l_data_downloadImgs or {};
    for i = 1, #imgs do
        if imgName == imgs[i] then
            return true;
        end
    end
    return false;
end
--java --> lua回调
ViewPushMoreGame.nativeCallEvent = function ( self, param, json_data )

    local name, ret = nil, nil;
    DebugLog("test-----:param:"..param or "-1`");
    DebugLog("test-----:json_data:"..(json_data and tostring(json_data) or "-1`"));
    if not json_data then
        return;
    end

	ret = json_data.result or 0   --0表示失败，1表示成功
	DebugLog("[test-----:]ret:"..ret);

    --二维码
    if param == kCreateQr then
		local imageName = (json_data.name or "-1");
        imageName = imageName..".png";
		create_QrCodeWnd(imageName);
        return
	end
    if kDownloadImageOne == param then      --下载图片
        local imageName = json_data
        for k, v in ipairs(l_data_downloadImgs) do
            if imageName ~= nil and imageName == l_all_icon_widget[k].imageName then
                l_all_icon_widget[k]:setFile(imageName)
            end
        end
        return
    end

    if not (param == kInstallPackage or param == kDownloadPackage or param == kOpenPackage) then
        return;
    end

    name = json_data.name or "-1";
    DebugLog("[test-----:]ret:"..ret.." name:"..name);

    local obj = find_btn_by_pkgname(name);
    --下载： 1成功 0失败
    --安装：1正常安装 2已经安装 3找不到安装包 4取消安装 5安装包有问题
    --打开：1成功 0失败
    if not obj then
        DebugLog("[ViewPushMoreGame callEvent] obj:"..(obj or -1));
        return;
    end

	if param == kInstallPackage then--安装
        if ret == 1 then
            update_btn_state(obj.btn, (obj.data.hasBeenAwarded == 1) and l_btn_state.open or l_btn_state.reward);
        elseif ret == 4 then--取消
            update_btn_state(obj.btn, l_btn_state.install);
        else-- 失败
            update_btn_state(obj.btn, l_btn_state.unDownload);
        end

    elseif param == kDownloadPackage then--下载
        if ret == 1 then
           update_btn_state(obj.btn, l_btn_state.install);
        else-- 失败
            update_btn_state(obj.btn, l_btn_state.unDownload);
        end
    elseif param == kOpenPackage then--打开
       if ret == 1 then
           update_btn_state(obj.btn, l_btn_state.open);
        else-- 失败
            update_btn_state(obj.btn, l_btn_state.install);
        end
	end
end

--http 数据回调
ViewPushMoreGame.requesGetAwardsCallBack = function (self, isSuccess, data)
	DebugLog("[ViewPushMoreGame requesGetAwardsCallBack]")
    if isSuccess and data then
		mahjongPrint(data)

        if 1 ~= tonumber(data.status or 0) then
            Banner.getInstance():showMsg(data.msg or "");
            return;
	    end
        local recvData = {};
        local money = data.data.money
        local player = PlayerManager.getInstance():myself();
        player:addMoney(money);
        Banner.getInstance():showMsg(data.msg or "");
    end

end



ViewPushMoreGame.onPhpMsgResponse = function( self, param, cmd, isSuccess)
	if self.phpMsgResponseCallBackFuncMap[cmd] then
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

--global parameters to request the http,saving for a map.
ViewPushMoreGame.phpMsgResponseCallBackFuncMap =
{
	[PHP_CMD_REQUSET_MORE_GAMES_GET_AWARDS] = ViewPushMoreGame.requesGetAwardsCallBack,
};


--
