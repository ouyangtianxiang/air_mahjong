local fmrFinalResultView = require(ViewLuaPath.."fmrFinalResultView");
require("MahjongRoom/FriendMatchRoom/FMRFinalResultItem")
--------好友对战最终结算界面
FMRFinalResultWin = class(SCWindow)

function FMRFinalResultWin:ctor( data )
 	self:initView(data)
end 



function FMRFinalResultWin:accessBigWin( )
	if not self._data or #self._data < 1 then 
		return 
	end 

	table.sort( self._data, function ( a , b )
		return a.money > b.money
	end )

	local maxMoney = self._data[1].money
	if maxMoney <= 0 then 
		return 
	end 

	for i=1,#self._data do
		if maxMoney == self._data[i].money then 
			self._data[i].isBigWin = true
		end 
	end	
end

function FMRFinalResultWin:initView( data )
	self._data   = data
	--isBigWin
	self:accessBigWin()
	-- body
	self._layout = SceneLoader.load(fmrFinalResultView);
	self:addChild(self._layout)

	self.bg = publ_getItemFromTree(self._layout,{"bg"})
	self:setWindowNode( self.bg );
	self:setCoverEnable( false );-- 允许点击cover

	self.closeBtn    = publ_getItemFromTree(self._layout,{"bg","close"})
	self.closeBtn:setOnClick(self,function( self )
		self:hideWnd()
	end)

	local x,y,offx,offy = 35,120,410,150
	for i=1,#data do
		local item = new(FMRFinalResultItem,data[i])
		item:setPos(x + (i+1)%2 * offx , y + math.floor( (i-1)/2 ) *offy)
		self.bg:addChild(item)
	end

	publ_getItemFromTree(self._layout,{"bg","shareBtn"}):setOnClick(self,function ( self )
		self:share()
	end)

	if not PlatformFactory.curPlatform:needToShareWindow() then 
    	publ_getItemFromTree(self._layout,{"bg","shareBtn"}):setVisible(false);
    end

end


function FMRFinalResultWin:share( )
	--self:hideWnd()
	if not isPlatform_Win32() then
		if GameConstant.curGameSceneRef then
            if GameConstant.curGameSceneRef.myBroadcast then
                GameConstant.curGameSceneRef.myBroadcast:setVisible(false);
            end
            self:screenShot();
            
		end 
	end 
end

function FMRFinalResultWin:screenShot( )
    if true then--not self.isScreenShot then
        --self.isScreenShot = true;
        DebugLog("FMRFinalResultWin.screenShot 发送截图请求");
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

        local shareData = {d = self._data, share = data, t = GameConstant.shareConfig.friendMatch, b = true };
        global_screen_shot(shareData); 
    end
end



function FMRFinalResultWin:dtor( )

	self._data = nil 

end

