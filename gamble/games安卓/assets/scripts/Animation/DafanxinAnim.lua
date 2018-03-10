-- FileName: DaFanXinAnim.lua
-- Author: YifanHe
-- Date: 2013-04-15
-- Last modification : 2013-11-12
-- Description: 动画类，播放胡牌时显示的大番型动画,使用方法如下:
--      		dafanxin = new(DaFanXin, 1, 0, root);
--     			dafanxin:play();

DaFanXin = class();

DaFanXin.msStep1 = 100; 
DaFanXin.msStep2 = 50;
DaFanXin.msStep3 = 150;
DaFanXin.msStep4 = 400;
DaFanXin.msStep5 = 300;
DaFanXin.msStep6 = 50;
DaFanXin.msStep7 = 500;


--动画对应路径
DaFanXin.tianhuPath        = "Room/dafanxin/tianhu.png";
DaFanXin.dihuPath          = "Room/dafanxin/dihu.png";
DaFanXin.longqiduiPath     = "Room/dafanxin/longqidui.png";
DaFanXin.qingqiduiPath     = "Room/dafanxin/qingqidui.png";
DaFanXin.qinglongqiduiPath = "Room/dafanxin/qinglongqidui.png";
DaFanXin.qingyaojiuPath    = "Room/dafanxin/qingyaojiu.png";
DaFanXin.qingduiPath 	   = "Room/dafanxin/qingdui.png";
DaFanXin.jiangduiPath      = "Room/dafanxin/jiangdui.png";

-- 传入动画编号
DaFanXin.textNum = {
	[1] = 	DaFanXin.tianhuPath,
	[2] = 	DaFanXin.dihuPath,
	[3] = 	DaFanXin.qinglongqiduiPath,
	[4] = 	DaFanXin.longqiduiPath,
	[5] = 	DaFanXin.qingqiduiPath,
	[6] = 	DaFanXin.qingyaojiuPath,
	[7] = 	DaFanXin.qingduiPath,
	[8] = 	DaFanXin.jiangduiPath
};

---------------------costruct function  -------------------------------------------------
--Parameters: 	daFanXinNum 		-- 需要显示的番型编号
									-- 天胡1  地胡2  清龙七对3  龙七对4  清七对5  清幺九6
-- 				player	            -- 动画移动到哪个玩家 自己0 下家1 对家2 上家3
--Return 	:   no return
-----------------------------------------------------------------------------------------
DaFanXin.ctor = function(self, daFanXinStr, player, root)
	local daFanXinNum = tonumber(daFanXinStr);
	if not daFanXinNum then -- 是字符串
		local regularStr = string.match(daFanXinStr, "[\128-\254]+");
		for k,v in pairs(GameConstant.DaFanAnimMap) do
			if GameString.convert2Platform(regularStr) == GameString.convert2Platform(v) then
				daFanXinNum = k;
				break;
			end
		end
	end
	self.player = player;
	self.root = root;
	self.bgPath = "Room/dafanxin/accountBg.png";
	self.textPath = DaFanXin.textNum[daFanXinNum];
	self.playing = false;
	self.darkBg = nil;
	if daFanXinNum and player then
		if self.textPath == nil then
			self.errorFlag = true;
		end
		if player < kSeatMine or player > kSeatLeft then
			self.errorFlag = true;
		end
	else
		self.errorFlag = true;
	end
end

---------------------destructor function  -----------------------------------------------
--Parameters: 	no Parameters
--Return 	:   no return
-----------------------------------------------------------------------------------------
DaFanXin.dtor = function(self)
	self.daFanXinNum = nil;
 	self.player = nil;
  	self.bgPath = nil;
  	self.textPath = nil;
  	self.playing = nil;

  	self.darkBg = nil;
  	self.textBg = nil;
  	self.textImage = nil;

  	self.errorFlag = nil;
end

------------------------ function play --------------------------------------------------
--Parameters: 	no Parameters
--Return 	:   no return
-- Description: 调用此方法开始显示动画
-----------------------------------------------------------------------------------------
DaFanXin.play = function(self)
	if not self.errorFlag then
		self.darkBg = UICreator.createImg("Room/dafanxin/zhezhao.png", 0, 0);
		self.darkBg:setSize(System.getScreenWidth() / System.getLayoutScale(), System.getScreenHeight() / System.getLayoutScale() );
		self.root:addChild(self.darkBg);

		--图片大小
		self.textBgWidth  = 426;
		self.textBgHeight = 320;

		self.textBg = UICreator.createImg(self.bgPath,  (System.getScreenWidth() / System.getLayoutScale() - self.textBgWidth) / 2, 
										 				(System.getScreenHeight() / System.getLayoutScale() - self.textBgHeight) / 2);
		self.root:addChild(self.textBg);

		self.textImage = UICreator.createImg(self.textPath, 68, 114);
		self.textBg:addChild(self.textImage);

		self.animStep1 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep1);
		self.animStep1:setEvent(self, DaFanXin.step1);
		--第一段 缓慢变大且变亮出现
		self.scaleAnim1 = new(AnimDouble, kAnimNormal, 0.3, 1.1, DaFanXin.msStep1, 0);
		self.scaleProp1 = new(PropScale, self.scaleAnim1, self.scaleAnim1, kCenterXY, self.textBgWidth /2 * System.getLayoutScale(), self.textBgHeight / 2 * System.getLayoutScale());
		self.textBg:addProp(self.scaleProp1, 1);

		self.animLight1 = new(AnimDouble, kAnimNormal, 0.0, 1.0, DaFanXin.msStep1, 0);
		self.light1 = new(PropTransparency, self.animLight1);
		self.textBg:addProp(self.light1, 0);
	end
end


--------------------------  private function  ----------------------------------------------
------------------------ 以下为私有方法请勿调用 --------------------------------------------
--------------------------------------------------------------------------------------------

DaFanXin.step1 = function(self)

	self.animStep2 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep2);
	self.animStep2:setEvent(self, DaFanXin.step2);
	-- 第二段 迅速变大突出
	self.scaleAnim2 = new(AnimDouble, kAnimNormal, 1.0, 1.4, DaFanXin.msStep2, 0);
	self.scaleProp2 = new(PropScale, self.scaleAnim2, self.scaleAnim2, kCenterXY, self.textBgWidth /2 * System.getLayoutScale(), self.textBgHeight / 2 * System.getLayoutScale());
	self.textBg:addProp(self.scaleProp2, 2);
end

DaFanXin.step2 = function(self)

	self.animStep3 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep3);
	self.animStep3:setEvent(self, DaFanXin.step3);
	-- 第三段 匀速缩小
	self.scaleAnim3 = new(AnimDouble, kAnimNormal, 1.0, 0.8, DaFanXin.msStep3, 0);
	self.scaleProp3 = new(PropScale, self.scaleAnim3, self.scaleAnim3, kCenterXY, self.textBgWidth /2 * System.getLayoutScale(), self.textBgHeight / 2 * System.getLayoutScale());
	self.textBg:addProp(self.scaleProp3, 3);
end

DaFanXin.step3 = function(self)
	self.animStep4 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep4);
	self.animStep4:setEvent(self, DaFanXin.step4);
	--第四段 静止展示一小段时间
end

DaFanXin.step4 = function(self)

	self.animStep5 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep5);
	self.animStep5:setEvent(self, DaFanXin.step5);
	-- 第五段 移动到侧边并且缩小
	self.darkBg:setVisible(false); -- 背景遮罩取消

	self.anim4 = new(AnimDouble, kAnimNormal, 1.0, 0.5, DaFanXin.msStep5, 0);
	self.scaleProp4 = new(PropScale, self.anim4, self.anim4, kCenterXY, self.textBgWidth /2 * System.getLayoutScale(), self.textBgHeight / 2 * System.getLayoutScale());
	self.textBg:addProp(self.scaleProp4, 4);

	
	local scale = 1.1 * 1.4 * 0.8 * 0.5;

	--屏幕坐标
	local startX, startY = System.getScreenWidth() /2 , System.getScreenHeight() / 2 ;
	local endX, endY = RoomCoor.daFanXinCoor[self.player][1] * System.getLayoutScale() , RoomCoor.daFanXinCoor[self.player][2] * System.getLayoutScale();
	local offsetX = (endX - startX) / scale;
	local offsetY = (endY - startY) / scale;

	self.textAnimTranslateX = new(AnimDouble , kAnimNormal, 0 , offsetX, DaFanXin.msStep5 , 0);
	self.textAnimTranslateY = new(AnimDouble , kAnimNormal, 0 , offsetY, DaFanXin.msStep5 , 0);
    self.propTranslate = new(PropTranslate , self.textAnimTranslateX , self.textAnimTranslateY);
    self.textBg:addProp(self.propTranslate, 5);

end

DaFanXin.step5 = function(self)
	
	self.animStep6 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep6);
	self.animStep6:setEvent(self, DaFanXin.step6);
	-- 第六段 变大
	self.scaleAnim5 = new(AnimDouble, kAnimNormal, 1.0, 1.10, DaFanXin.msStep6, 0);
	self.scaleProp5 = new(PropScale, self.scaleAnim5, self.scaleAnim5, kCenterXY, self.textBgWidth /2 * System.getLayoutScale(), self.textBgHeight / 2 * System.getLayoutScale());
	self.textBg:addProp(self.scaleProp5, 6);

end

DaFanXin.step6 = function(self)
	self.animStep7 = new(AnimInt, kAnimNormal, 0, 1, DaFanXin.msStep7);
	self.animStep7:setEvent(self, DaFanXin.stop);
	-- 第七段 变暗消失
	self.anim6 = new(AnimDouble, kAnimNormal, 1.0, 0.0, DaFanXin.msStep7, 0);
	self.transparency = new(PropTransparency, self.anim6);
	self.textBg:addProp(self.transparency, 7);

end

DaFanXin.stop = function(self)
	if not self.stoped then
		delete(self.animStep1);
		self.animStep1 = nil;
		delete(self.animStep2);
		self.animStep2 = nil;
		delete(self.animStep3);
		self.animStep3 = nil;
		delete(self.animStep4);
		self.animStep4 = nil;
		delete(self.animStep5);
		self.animStep5 = nil;
		delete(self.animStep6);
		self.animStep6 = nil;
		delete(self.animStep7);
    	self.animStep7 = nil;
		delete(self.scaleAnim1);
		self.scaleAnim1 = nil;
		delete(self.scaleAnim2);
		self.scaleAnim2 = nil;
		delete(self.scaleAnim3);
		self.scaleAnim3 = nil;
		delete(self.anim4);
		self.anim4 = nil;
		delete(self.scaleAnim5);
		self.scaleAnim5 = nil;
		delete(self.textAnimTranslateX);
		self.textAnimTranslateX = nil;
		delete(self.textAnimTranslateY);
		self.textAnimTranslateY = nil;
		delete(self.anim6);
		self.anim6 = nil;
		delete(self.animLight1);
		self.animLight1 = nil;
		delete(self.scaleProp1);
		self.scaleProp1 = nil;
		delete(self.scaleProp2);
		self.scaleProp2 = nil;
		delete(self.scaleProp3);
		self.scaleProp3 = nil;
		delete(self.scaleProp4);
		self.scaleProp4 = nil;
		delete(self.propTranslate);
		self.propTranslate = nil;
		delete(self.scaleProp5);
		self.scaleProp5 = nil;
		delete(self.transparency);
		self.transparency = nil;
		delete(self.light1);
		self.light1 = nil;

		delete(self.textBg);
		self.textBg = nil;
		delete(self.darkBg);
		self.darkBg = nil;
		self.stoped = true;
		delete(self);
	end
end

