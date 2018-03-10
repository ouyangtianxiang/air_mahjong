
local cardRecordView = require(ViewLuaPath.."cardRecordView");
local cardRecordListItem = require(ViewLuaPath.."cardRecordListItem");

CardRecordWindow = class(SCWindow);

function CardRecordWindow:ctor( data )
	-- body
end

function CardRecordWindow:dtor(  )
	
end


function CardRecordWindow:initView(  )

	self._layout = SceneLoader.load(cardRecordView);
	self:addChild(self._layout)

	local winBg = publ_getItemFromTree(self._layout, {"bg"});
	self:setWindowNode( winBg );
	self:setCoverEnable( true );-- 允许点击cover

	publ_getItemFromTree(self._layout,{"bg","closeBtn"}):setOnClick(self,function ( self )
		self:hideWnd()
	end)
	self.scrollView    = publ_getItemFromTree(self._layout,{"bg","ScrollView1"})
	self.noContentText = publ_getItemFromTree(self._layout,{"bg","nocontent"})
end


function CardRecordWindow:loadItemsFromData( data )
	self.scrollView:removeAllChildren(true)

	if not data or #data <= 0 then 
		self.noContentText:setVisible(true)
		return 
	else 
		self.noContentText:setVisible(false)
	end 

	local item,leftLabel,midLabel
	local x,y,w,h = 0,0,0,0
	for i=1,#data do
		item 			= SceneLoader.load(cardRecordListItem)
		leftLabel		= publ_getItemFromTree(item,{"left","time"})
		midLabel	    = publ_getItemFromTree(item,{"mid" ,"wanfa_di"})
		rightLabel      = publ_getItemFromTree(item,{"right","win"})

		leftLabel:setText("") 
		midLabel:setText("")
		rightLabel:setText("")

		item:setPos(x,y)
		self.scrollView:addChild(item)
		y = y + 65     
	end
end

-- 遮罩点击消息响应函数
function CardRecordWindow.onCoverClick( self )
	DebugLog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end