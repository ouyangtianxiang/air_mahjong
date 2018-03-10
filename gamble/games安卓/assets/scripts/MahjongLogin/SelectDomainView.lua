
local selectDomainLayout = require(ViewLuaPath.."selectDomainLayout");
require("MahjongLogin/SelectDomainItem");



SelectDomainView = class(CustomNode);

SelectDomainView.ctor = function ( self , root)
	DebugLog("SelectDomainView ctor");
	self.root = root;
	self.layout = SceneLoader.load(selectDomainLayout);
	self:addChild(self.layout);

	self.btn_save = publ_getItemFromTree(self.layout , {"btn_save"});
	self.btn_save:setOnClick(self , function ( self )
		self:btn_saveOnClick();
	end);

	self.btn_cancel = publ_getItemFromTree(self.layout , {"btn_cancel"});
	self.btn_cancel:setOnClick(self , function ( self )
		self.root:removeChild(self , true);
	end);


	--不能由空白地方点击消失
	self.cover:setEventTouch(self , function (self)
		
	end);
	self.cover:setFile("Loading/load_Bg.jpg");


	self.list_all = publ_getItemFromTree(self.layout , {"list_all"});
	self.list_all:setSize(self.list_all:getSize());

	local listData = nil--MahjongCacheData_getDictKey_StringValue(kNotClearDict,kNotClearDictKey_Value.LoaclDomain,"nil");
	if listData and listData ~= "nil" then
		listData = json.mahjong_decode_node(listData);
	else
		listData = {};
	end

	self.allDomain = {};

	local list_allDomain = {};
	for k , v in pairs(AllCustomDomain) do
		table.insert(list_allDomain , v);
	end

	for k , v in pairs(listData) do
		table.insert(self.allDomain , v);
		table.insert(list_allDomain , v);
	end

	self.list_allData = {};
	for k , v in pairs(list_allDomain) do
		local data = {};
		data.domain = v;
		data.viewRef = self;
		table.insert(self.list_allData , data);
	end

	self.adapter = new(CacheAdapter, SelectDomainItem, self.list_allData);
	self.list_all:setAdapter(self.adapter);
	self.list_all:setDirection(kVertical);
	self.list_all:setMaxClickOffset(5);
	self.list_all:setScrollBarWidth(0);

	self.edit_domain = publ_getItemFromTree(self.layout , {"btn_edit" , "edit_domain"});
	-- self.edit_domain:setOnTextChange(self, self.onTextChange);
end

SelectDomainView.dtor = function ( self )
	DebugLog("SelectDomainView dtor");
	self:removeAllChildren();
	self.allDomain = {};
end

SelectDomainView.btn_saveOnClick = function ( self )
	DebugLog("SelectDomainView btn_saveOnClick");
	local str = self.edit_domain:getText();
	if str and str ~= "" and str ~= " " and getStringLen(str) > 0 then
		if not string.find(str , "http://") then
			str = "http://"..str.."/mahjong_weibo/application/";
		end
		local flag = false;
		for k , v in pairs(self.allDomain) do
			if str == v then
				flag = true;
			end
		end
		if not flag then
			table.insert(self.allDomain , str);
		end
		GameConstant.CommonUrl = str;
	end
	local dict = json.encode(self.allDomain);
	if 0 == #self.allDomain then
		dict = "nil";
	end
	--MahjongCacheData_setDictKey_StringValue(kNotClearDict,kNotClearDictKey_Value.LoaclDomain,dict,true);
	self.root:removeChild(self , true);
end

SelectDomainView.removeADomain = function ( self , domain )
	for k , v in pairs(self.list_allData) do
		if domain == v.domain then
			table.remove(self.list_allData , k);
			break;
		end
	end
	for k , v in pairs(self.allDomain) do
		if domain == v then
			table.remove(self.allDomain , k);
			break;
		end
	end
	self.adapter:changeData(self.list_allData);
end

SelectDomainView.selectADomain = function ( self , domain )
	self.edit_domain:setText(domain);
end


