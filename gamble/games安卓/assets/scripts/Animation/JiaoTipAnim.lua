local huTipsPin_map = require("qnPlist/huTipsPin")


JiaoTipAnim = class(Node);

JiaoTipAnim.ctor = function( self, value, x, y, parent,bIsBest )
	self.mahjong_X = x;
	self.mahjong_Y = y;
	self.x = self.mahjong_X + 10;
	self.y = self.mahjong_Y - 90;
	self.isPlaying = false;
	self.animID = 0;
	self.value = value;

	self:setSize( 66, 120 );
	self:setPos( self.x, self.y );
	self:load(bIsBest);
	self:setVisible( false );
	if parent then
		parent:addChild( self );
	else
        if GameConstant.curGameSceneRef and  GameConstant.curGameSceneRef.m_root then
            GameConstant.curGameSceneRef.m_root:addChild(self);
        end
        --self:addToRoot();
          
	end
end

JiaoTipAnim.load = function( self,bIsBest )
	local imageKey = "jiao.png"
	if bIsBest then 
		imageKey = "best.png"
	end 
	self.imgJiao = UICreator.createImg( huTipsPin_map[imageKey] );
	self:addChild( self.imgJiao );
end

JiaoTipAnim.play = function( self )
	self:setVisible( true );
	DebugLog( "JiaoTipAnim.play" );
	self.isPlaying = true;
	self:setAnim();
end

JiaoTipAnim.setAnim = function( self )
	self.anim = new(AnimInt, kAnimRepeat, 0, 1, 30, 0 );
	self.anim:setDebugName("JiaoTipAnim.setAnim");
	local y = 0;
	local dir = 0;
	self.anim:setEvent( self, function( self )
		if y > 15 and dir == 0 then
			dir = 1;
		end

		if y < 0 and dir == 1 then
			dir = 0;
		end

		if dir == 0 then
			y = y + 1.8;
		else
			y = y - 1;
		end

		self.imgJiao:setPos( 0, y );
	end);
end

JiaoTipAnim.stop = function( self )
    if GameConstant.curGameSceneRef 
       and GameConstant.curGameSceneRef.m_root 
       and HallScene_instance ~= GameConstant.curGameSceneRef then
            DebugLog("[JiaoTipAnim]:stop");
            GameConstant.curGameSceneRef.m_root:removeChild(self, true);
	        --self:removeFromSuper();
    end
end

JiaoTipAnim.dtor = function( self )
	self:setVisible( false );
	delete( self.anim );
	self.anim = nil;
	delete( self.imgJiao );
	self.imgJiao = nil;
	self:removeAllChildren();
end