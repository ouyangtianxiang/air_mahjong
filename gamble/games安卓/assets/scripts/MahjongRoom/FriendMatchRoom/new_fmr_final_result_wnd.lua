--好友对战 总结算界面
--NoahHan

--require
require("atomAnim/resEx")
require("atomAnim/animEx")
local num_fm_1_map = require("qnPlist/num_fm_1.lua");
local num_fm_2_map = require("qnPlist/num_fm_2.lua");


--界面布局文件
local new_fm_final_result_layout =  require(ViewLuaPath.."new_fm_final_result_layout");

new_fmr_final_result_wnd = class(SCWindow);

--ctor
new_fmr_final_result_wnd.ctor = function (self, data)
    DebugLog("[new_fmr_final_result_wnd]:ctor");

    if not data then
        DebugLog("data is nil");
        return;
    end

    self:init(data);
end

--dtor
new_fmr_final_result_wnd.dtor = function (self)

    DebugLog("[new_fmr_final_result_wnd]:dtor");
    self:unregister_events();
end

--init
new_fmr_final_result_wnd.init = function (self, data)
    DebugLog("[new_fmr_final_result_wnd]:init");
    if not data then
        DebugLog("data is nil");
        return;
    end

    self.m_data = data;
    self.m_data.reward_total_count = 1;
    --初始化控件    
    self:init_widgets();

    --self:setCoverEnable(true);
    --test
    --self:init_test_data();
    --
    self.m_btn_close:setOnClick (self, function (self)
        self:hideWnd();
    end);
    --分享按钮事件
    self.m_btn_share:setOnClick(self, self.event_share);

    --刷新界面
    self:refresh_view();
    
    --title图片下拉动画
    self.m_title:addPropTranslateEase(101, kAnimNormal,ResDoubleArrayBackOut, 500, 400, 0, 0, -150, 0)

    --显示窗口
    --self:showWnd();
    self:setVisible(true);

    --注册事件
    self:register_events();
end

new_fmr_final_result_wnd.init_widgets = function (self)
    --self:addToRoot();
    --self:setVisible(false);
    self.m_layout = SceneLoader.load(new_fm_final_result_layout);
    self:addChild(self.m_layout);

    self.m_title = publ_getItemFromTree(self.m_layout, {"title"});
    
    self.m_btn_close = publ_getItemFromTree(self.m_layout, {"btn_close"});

    self:setWindowNode( self.m_layout );

    --
    self.m_v = {};
    for i = 1, 4 do
        local v = publ_getItemFromTree(self.m_layout, {"v_"..i});
        v.img_rank = publ_getItemFromTree(v, {"rank"});
        v.v = publ_getItemFromTree(v, {"v"});
        v.t_name = publ_getItemFromTree(v, {"v", "name_bg", "t"});
        v.img_head = publ_getItemFromTree(v, {"v", "head"});
        table.insert(self.m_v, v);
    end

    --分享按钮
    self.m_btn_share = publ_getItemFromTree(self.m_layout, {"btn_share"});
end

--注册事件
new_fmr_final_result_wnd.register_events = function (self)
    EventDispatcher.getInstance():register(NativeManager._Event, self, self.nativeCallEvent);
    EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

--消除注册事件
new_fmr_final_result_wnd.unregister_events = function (self)
    EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.nativeCallEvent);
    EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
    EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
end

--客户端测试数据
new_fmr_final_result_wnd.init_test_data = function (self)
    local param = {}
    param.reward_total_count = 1;

	
	param.time  = os.time()  --1470479458
	param.type  = 5--RoomData.getInstance().wanfa
    param.tid   = 1--self._fmrData.tid ;
	local result = {};
    local mids = {[1] = 22434148,[2] = 9089975,[3] = 27511021,[4] = 9090030, };
    local money = {[1] = 10,[2] = 0,[3] = -1,[4] = 0,};
	for i=1, 4 do
        local d = {};
		local mid   = mids[i] 
		d = {}
		--local player = PlayerManager:getPlayerById(mid) or PlayerManager.getInstance():myself();
		--if player then 
			d.name  		 = tostring(mid)--player.nickName
			d.money 		 = money[i]
			d.small_image = ""--player.small_image or ""
			d.sex   		 = 0--player.sex
            d.mid = mid--player.mid;
		--end 
        table.insert(param, d);
	end
    --param.result = result;
	param.ret = 1 --正常结束写1，，提前结束写0

    self.m_data = param;
end

--刷新界面
new_fmr_final_result_wnd.refresh_view = function (self)
    DebugLog("[new_fmr_final_result_wnd]:refresh_view");
   
    if not self.m_data or  #self.m_data < 4 then
       return;
    end
    --排序
    function t_sort(s1 , s2)
	    return (tonumber(s1.money) or 0) > (tonumber(s2.money) or 0)
    end
    table.sort(self.m_data, t_sort);

    --标记排序后的顺序
    for i = 1, 4 do
        self.m_data[i].idx = i;
    end

    --标记是否有并列名次
    for i = 2, 4 do
        if self.m_data[i].money == self.m_data[i-1].money then
            self.m_data[i].idx = self.m_data[i-1].idx
            for j = i +1, 4 do
                if self.m_data[j] and self.m_data[j].idx > 1 then
                    self.m_data[j].idx = self.m_data[j].idx - 1
                end
            end
            
        end
    end
    --组件的配置信息
    local l_config_v = {
        [1] = {v_size = {w = 297, h = 590}, img_size = {w = 297, h = 349}, h_bg = "Hall/friendMatch/final/head_1.png", img_rank = "Hall/friendMatch/final/t_1.png"},
        [2] = {v_size = {w = 297, h = 500}, img_size = {w = 279, h = 260}, h_bg = "Hall/friendMatch/final/head_2.png", img_rank = "Hall/friendMatch/final/t_2.png"},
        [3] = {v_size = {w = 297, h = 457}, img_size = {w = 287, h = 216}, h_bg = "Hall/friendMatch/final/head_3.png", img_rank = "Hall/friendMatch/final/t_3.png"},
        [4] = {v_size = {w = 297, h = 457}, img_size = {w = 287, h = 216}, h_bg = "Hall/friendMatch/final/head_3.png", img_rank = "Hall/friendMatch/final/t_4.png"},
    };
    for i = 1, 4 do
        if not self.m_v[i] then
            break;
        end
        local d = self.m_data[i];
        local w = self.m_v[i];
        w.d = d;
        w:setSize(l_config_v[d.idx].v_size.w, l_config_v[d.idx].v_size.h);

        --排名底图
        w.img_rank:setFile(l_config_v[d.idx].img_rank);
        w.img_rank:setSize(l_config_v[d.idx].img_size.w, l_config_v[d.idx].img_size.h);

        --头像
        --w.img_head:setFile(l_config_v[d.idx].h_bg);
        local isExist, local_dir = NativeManager.getInstance():downloadImage(d.small_image or "");
        w.local_dir = local_dir;
        if isExist then
            DebugLog("img_path:"..tostring(local_dir));
            --w.img_head:setFile(local_dir);
            setMaskImg(w.img_head,"Hall/friendMatch/final/head_mask.png",local_dir)
          else
                setMaskImg(w.img_head,"Hall/friendMatch/final/head_mask.png","Commonx/default_woman.png")
        end
--        local_dir = "Commonx/default_woman.png";
--        setMaskImg(w.img_head,"Hall/friendMatch/final/head_mask.png",local_dir)

        --名字
        local str = stringFormatWithString(d.name or "", 16, false)
        w.t_name:setText(str);

        local node = self:create_num(d.money);
        if node then
            w.img_rank:addChild(node);
        end

        --最大赢家
        if d.idx == 1 and d.money > 0 then
            local img = new(Image, "Hall/friendMatch/win.png");
            img:setAlign(kAlignTopRight);
            img:setPos(-20,0);
            w.v:addChild(img);

        end

        --打赏按钮
        if self:can_reward_display(d) then
--            local reward = new(Image, "Hall/friendMatch/final/reward.png");
--            reward:setAlign(kAlignTopRight);
--            reward:setPos(-18,115);
--            w.v:addChild(reward);
            local reward = new(Button, "Hall/friendMatch/final/reward.png", nil, nil, nil, 0, 0, 0, 0);
            reward:setAlign(kAlignTopRight);
            reward:setPos(-18,115);
            reward.reward_id = d.mid;
            local obj = {o = self, btn = reward };
            reward:setOnClick(obj, self.event_reward);
            w.v:addChild(reward);
        end
        
    end
end

--创建一组积分的数字，返回node和位置
new_fmr_final_result_wnd.create_num = function (self, num)
    local number = tonumber(num);
    if not number then
        return nil;
    end

    local node_size = {w = 0, h = 0};
    local num_map = number >= 0 and num_fm_1_map or num_fm_2_map;
    local node = new(Node);
    node:setAlign(kAlignBottom);
    node:setPos(0, 25);
    --正负 符号
    local symbol = new(Image, num_map["symbol.png"]);
    if symbol then
       symbol:setAlign(kAlignLeft);
       symbol:setPos(0,0);
       local w,h = symbol:getSize();
       node_size.w = node_size.w + w;
       node:addChild(symbol);
    end
    local tmp_map = { 
                    ["0"] = "0.png",
                    ["1"] = "1.png",
                    ["2"] = "2.png",
                    ["3"] = "3.png",
                    ["4"] = "4.png",
                    ["5"] = "5.png",
                    ["6"] = "6.png",
                    ["7"] = "7.png",
                    ["8"] = "8.png",
                    ["9"] = "9.png",
                            };
    if number < 0 then
        number = 0 - number;
    end
    local str_num = tostring(number);
    for i = 1, string.len(str_num) do
        local char = string.sub(str_num, i, i);
        if char and tmp_map[char] then
            local n = new(Image, num_map[tmp_map[char]]);
            if n then
                n:setAlign(kAlignLeft);
                n:setPos(node_size.w,0);
                local w,h = n:getSize();
                node_size.w = node_size.w + w;
                node_size.h = h;
                node:addChild(n);
            end
        end
    end
    node:setSize(node_size.w, node_size.h);
    return node;
end

--是否显示打赏
new_fmr_final_result_wnd.can_reward_display = function(self, data)
    DebugLog("[new_fmr_final_result_wnd] can_reward_display");

    --如果php 开关是关闭的，则不显示
    local config = GlobalDataManager.getInstance().fmRoomConfig;
    if config and not config.m_reward_open or config.m_reward_open == 0  then
        DebugLog(" reward_open is false");
        return false;
    end
--    local p = PlayerManager.getInstance():getPlayerById(data.mid)
--    if not p then
--        return false;
--    end
--    if p.boyaacoin - config

    local score = tonumber(data.money) or 0;

    local myself = PlayerManager.getInstance():myself();
    local b_display = false;
    for i = 1, #self.m_data do
        if self.m_data[i].mid == myself.mid then
            b_display = self.m_data[i].idx == 1 and true or false;
            break;
        end
    end
    if not b_display then
        return false
    end


    return score < 0;
end

--是否可以打赏
new_fmr_final_result_wnd.can_reward = function(self)
    DebugLog("[new_fmr_final_result_wnd]:can_reward");
--    local config = GlobalDataManager.getInstance().fmRoomConfig;
--    if config and not config.m_reward_open  then
--        DebugLog(" reward_open is false");
--        return false;
--    end
    --自己的数据
    local myself = PlayerManager.getInstance():myself();
    --好友对战的配置
    local config = GlobalDataManager.getInstance().fmRoomConfig;
    DebugLog("myboyaacoin:"..tostring(myself.boyaacoin));
    DebugLog("config-- m_num_for_tip:"..tostring(config.m_num_for_tip).." m_min_diamand_for_tip:"..tostring(config.m_min_diamand_for_tip));

    --判断钻石是否满足要求，玩家当前钻石-减去要打赏的钻石 >= 10 --php配置
    if myself.boyaacoin - config.m_num_for_tip < config.m_min_diamand_for_tip then
        Banner.getInstance():showMsg("您的钻石不足，无法打赏。");
        return false;
    end

    --每场比赛结束后最多可以打赏10次--php配置
    if self.m_data.reward_total_count > config.m_max_tiping_times then
        Banner.getInstance():showMsg("您已经打赏很多了，下次再来吧。");
        return false;
    end

    return true;
end

--new_fmr_final_result_wnd.accessBigWin = function (self)
--	if not self.m_data or #self.m_data < 1 then 
--		return 
--	end 

--	table.sort( self.m_data, function ( a , b )
--		return a.money > b.money
--	end )

--	local maxMoney = self.m_data[1].money
--	if maxMoney <= 0 then 
--		return 
--	end 

--	for i=1,#self.m_data do
--		if maxMoney == self.m_data[i].money then 
--			self.m_data[i].isBigWin = true
--		end 
--	end	
--end

--分享按钮事件
new_fmr_final_result_wnd.event_share = function (self)

    DebugLog("[new_fmr_final_result_wnd]:event_share");
    math.randomseed( tonumber(tostring(os.time()):reverse():sub(0,#kShareTextContent)) ) 
	local rand = math.random();
	local index = math.modf( rand*1000%6 );
	local player = PlayerManager.getInstance():myself();

	local data = {};
	data.title = PlatformFactory.curPlatform:getApplicationShareName();
	data.content = kShareTextContent[ index or 1 ];
	data.username = player.nickName or "川麻小王子";
	data.url = GameConstant.shareMessage.url or ""
    --native_to_java( kScreenShot , json.encode( data ) );-- 向java发起截图请求

    local shareData = {d = self.m_data, share = data, t = GameConstant.shareConfig.friendMatch, b = true };
    global_screen_shot(shareData); 
end

--打赏按钮事件
new_fmr_final_result_wnd.event_reward = function (obj)
    DebugLog("[new_fmr_final_result_wnd]:event_reward");
    umengStatics_lua(Umeng_RoomGrantClick)
    if not obj or not obj.o or not obj.btn then
        return;
    end

    if obj.o.can_reward and obj.o:can_reward() then
        --发送命令
        local param = {};

        param.a_uid =  PlayerManager.getInstance():myself().mid;
        param.b_uid = obj.btn.reward_id or 0;
        param.tid = obj.o.m_data.tid or 0;
        param.per_num = 1;
        param.reward_num = GlobalDataManager.getInstance().fmRoomConfig.m_num_for_tip or 0;

        SocketSender.getInstance():send( CLIENT_COMMAND_REWARD_DIAMOND, param);   
    end


end

--钻石移动动画
new_fmr_final_result_wnd.diamond_move = function (self, a_uid, b_uid, reward_num)
    DebugLog("[new_fmr_final_result_wnd]:diamond_move");
    --获取钻石移动的位置
    local fun_get_pos = function(uid)
        for i = 1, #self.m_v do
            if self.m_v[i].d.mid == uid then
                local x, y = self.m_v[i].img_head:getAbsolutePos();
                return x, y, self.m_v[i].img_head;
            end
        end  
    end

    --钻石飘动画
    local fun_move = function (root_node, num)
        if not root_node or not num then
            return;
        end
        local node = new(Node);
        
        local img_diamond = new(Image, "Commonx/diamond.png");
        img_diamond:setAlign(kAlignLeft);
        local w,h = img_diamond:getSize();
        node:addChild(img_diamond);
        root_node:addChild(node);

        local t = new(Text, "+"..tostring(num), 0, 0, kAlignLeft, "", 30, 0xff , 0xff , 0xff)
        t:setAlign(kAlignLeft);
        t:setPos(w, 0);
        node:addChild(t);

        local t_w, t_h = t:getSize();
        node:setAlign(kAlignTop);
        node:setSize(w+t_w,h);
        node:setPos(0, -h/2);
        
        node:moveBy(2, 0,-50, 500, 0, node, function (obj)
            obj:removeFromSuper();                                                           
        end);
    end

    local p_1_x,p_1_y,_ = fun_get_pos(a_uid);
    local p_2_x,p_2_y,_ = fun_get_pos(b_uid);
    if not p_1_x or not p_2_x then
        return;
    end

    local p_1, p_2 = {x = p_1_x, y = p_1_y},{x = p_2_x, y = p_2_y}
    if not p_1 or not p_2 then
       return;
    end
    local diamond = new(Image, "Commonx/diamond.png");
    self:addChild(diamond)

    local w,h = self.m_v[1].img_head:getSize();
    local x,y = p_2.x-p_1.x, p_2.y-p_1.y;
    diamond:setPos(p_1.x+w/2,p_1.y+h/2);
    local obj = {o_diamond = diamond, o_num = reward_num, o_uid = b_uid};
    diamond:moveBy(2, x,y, 500, 0, obj, function (obj)
        obj.o_diamond:removeFromSuper();
        local _, _, img = fun_get_pos(obj.o_uid);
        fun_move(img, obj.o_num);                                                            
    end);
end

--打赏钻石回调
new_fmr_final_result_wnd.reward_diamond_ret = function (self, data)
    DebugLog("new_fmr_final_result_wnd:reward_diamond_ret");
    if not data then
        DebugLog("data is nil");
        return;
    end

    if data.ret == 1 then--成功
        local a_uid = data.a_uid;
        local b_uid = data.b_uid;
        local myself =  PlayerManager.getInstance():myself();

        self.m_data.reward_total_count = data.reward_total_count;
        if a_uid == myself.mid then
            --刷新钻石
            myself.boyaacoin = myself.boyaacoin - (data.reward_num or 0);
        end


        --动画
        self:diamond_move(a_uid, b_uid, data.reward_num);    
    else
        Banner.getInstance():showMsg(data.msg or "");
    end
    local config = GlobalDataManager.getInstance().fmRoomConfig;
    if data.reward_open ~= -1 then
        config.m_reward_open = data.reward_open
    end
    if data.num_for_tip ~= -1 then
        config.m_num_for_tip = data.num_for_tip
    end
    if data.max_tiping_times ~= -1 then
        config.m_max_tiping_times = data.max_tiping_times
    end 
    
    if data.min_diamand_for_tip ~= -1 then
        config.m_min_diamand_for_tip = data.min_diamand_for_tip 
    end
end


--java事件回调
new_fmr_final_result_wnd.nativeCallEvent = function (self, param, _detailData)
	DebugLog("new_fmr_final_result_wnd:nativeCallEvent :"..tostring(_detailData));
	if kDownloadImageOne == param then
        --替换玩家头像
        for i = 1, #self.m_v do
            DebugLog("self.m_v[i].local_dir:"..tostring(self.m_v[i].local_dir ));
            if self.m_v[i].local_dir == _detailData then
                --self.m_v[i].img_head:setFile(_detailData);
                setMaskImg(self.m_v[i].img_head,"Hall/friendMatch/final/head_mask.png",_detailData)
                break;
            end
        end 
	end
end

--服务器回调
new_fmr_final_result_wnd.onSocketPackEvent = function ( self, param, cmd )
	if self.scoketEventFuncMap[cmd] then
		DebugLog(string.format("Room deal socket cmd 0x%x",cmd));
		self.scoketEventFuncMap[cmd](self, param);
	end
end

new_fmr_final_result_wnd.scoketEventFuncMap = 
{
	[CLIENT_COMMAND_REWARD_DIAMOND_RES] = new_fmr_final_result_wnd.reward_diamond_ret,    --打赏钻石回调
}

--php回调
new_fmr_final_result_wnd.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
	if self.phpMsgResponseCallBackFuncMap[cmd] then 
		self.phpMsgResponseCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

--php回调函数列表
new_fmr_final_result_wnd.phpMsgResponseCallBackFuncMap = 
{
	--[PHP_CMD_REQEUST_VETERAN_PALYER_GIFT_AWARD] 		= ,
}
