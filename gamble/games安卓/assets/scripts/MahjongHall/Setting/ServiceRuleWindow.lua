require("MahjongHall/hall_2_interface_base")

ServiceRuleWindow = class();

ServiceRuleWindow = class(hall_2_interface_base);

ServiceRuleWindow.userrule = 1 		;--用户条款
ServiceRuleWindow.serviceRule  = 2  ;--服务条款

ServiceRuleWindow.ctor = function ( self , delegate,  ruleNum)
	self.delegate = delegate;
    self.m_ruleNum = ruleNum;

    --设置基类的基础配置
    self:set_tag(GameConstant.view_tag.rules);
    self:set_tab_count(1);

    delegate.m_mainView:addChild(self)
    self:play_anim_enter();

end

ServiceRuleWindow.dtor = function (self)
    DebugLog("[ServiceRuleWindow]:dtor");
    self.super.dtor(self);
end

ServiceRuleWindow.on_enter = function (self)
	
	DebugLog("RUNLENUM" .. self.m_ruleNum)
    self:set_light_tab(1);
    self:set_tab_title({self.m_ruleNum == ServiceRuleWindow.userrule and "用户条款" or "服务条款" });


	if self.m_ruleNum == ServiceRuleWindow.serviceRule then 
		local data = { };
		data.api = HttpModule.postParam("serverRule", "");
		data.url = PlatformConfig.ServiceNotice_URL .. "terms_of_service";
		native_to_java("UserServrice", json.encode(data));
	else
		local data = { };
		data.api = HttpModule.postParam("userRule", "");
		data.url = PlatformConfig.ServiceNotice_URL .. "privacy_policy";
		native_to_java("UserServrice", json.encode(data));
	end

	if PlatformConfig.platformWDJ == GameConstant.platformType or
	   PlatformConfig.platformWDJNet == GameConstant.platformType then  
		self.m_btn_tab[1].img:setFile("Login/wdj/Hall/Commonx/tag_red.png");
    end

    showOrHide_sprite_lua(0);

end

ServiceRuleWindow.on_exit = function (self)
	
	showOrHide_sprite_lua(1);

    GlobalDataManager.getInstance():updateScene();
end

ServiceRuleWindow.on_before_exit = function (self)
    native_to_java("closeService");
    return true;
end


