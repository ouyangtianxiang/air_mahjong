require("core/drawing")

if AnimBase ~= nil then
    AnimBase.pause = function(self)
        if anim_set_pause ~= nil then
            anim_set_pause(self.m_animID,1);
        end
    end

    AnimBase.resume = function(self)
        if anim_set_pause ~= nil then
            anim_set_pause(self.m_animID,0);
        end
    end
end

if DrawingBase then 

DrawingBase.removePropEase = function(self, sequence)
    if drawing_prop_remove(self.m_drawingID, sequence) ~= 0 then
    	return false;
    end

	if self.m_props[sequence] then
		delete(self.m_props[sequence]["prop"]);
		for _,v in pairs(self.m_props[sequence]["anim"]) do 
			delete(v);
		end
		for _,v in pairs(self.m_props[sequence]["res"]) do 
			delete(v);
		end 
		self.m_props[sequence] = nil;
	end
	return true;
end

DrawingBase.removePropEaseByID = function(self, propId)
	if drawing_prop_remove_id(self.m_drawingID, propId) ~= 0 then
		return false;
	end

	for k,v in pairs(self.m_props) do 
		if v["prop"]:getID() == propId then
			delete(v["prop"]);
			for _,anim in pairs(v["anim"]) do 
				delete(anim);
			end
			for _,res in pairs(v["res"]) do 
				delete(res);
			end 
			self.m_props[k] = nil;
			break;
		end
	end
	
	return true;
end

---------------------------------------------------------------------------------------
--------------------------function addPropEase-----------------------------------------
---------------------------------------------------------------------------------------
DrawingBase.addPropColorEase = function(self, sequence, animType, EaseType,duration, delay, rStart, rEnd, gStart, gEnd, bStart, bEnd)
	return DrawingBase.addAnimPropEase(self,sequence,PropColor,nil,nil,nil,animType,EaseType,duration,delay,rStart,rEnd,gStart,gEnd,bStart,bEnd);
end

DrawingBase.addPropTransparencyEase = function(self, sequence, animType,EaseType, duration, delay, startValue, endValue)
	return DrawingBase.addAnimPropEase(self,sequence,PropTransparency,nil,nil,nil,animType,EaseType,duration,delay,startValue,endValue);
end

DrawingBase.addPropScaleEase = function(self, sequence, animType,EaseType, duration, delay, startX, endX, startY, endY, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimPropEase(self,sequence,PropScale,center, x, y,animType,EaseType,duration,delay,startX,endX,startY,endY)
end 

DrawingBase.addPropRotateEase = function(self, sequence, animType, EaseType,duration, delay, startValue, endValue, center, x, y)
	local layoutScale = System.getLayoutScale();
	x = x and x * layoutScale or x;
	y = y and y * layoutScale or y;
	return DrawingBase.addAnimPropEase(self,sequence,PropRotate,center, x, y,animType,EaseType,duration,delay,startValue,endValue);
end

DrawingBase.addPropTranslateEase = function(self,sequence,animType,EaseType,duration,delay,startX,endX,startY,endY)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	return DrawingBase.addAnimPropEase(self,sequence,PropTranslate,nil,nil,nil,animType,EaseType,duration,delay,startX,endX,startY,endY)
end 

DrawingBase.addPropTranslateJump = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,times,height)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	height = height and height * layoutScale or height;
	return DrawingBase.addAnimPropJump(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,times,height)
end 

DrawingBase.addAnimPropJump = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,times,height)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resJump = {};
	local anims = {};

	resJump[1] = new(ResDoubleArrayJumpX,duration,startX,endX,times,height)
	resJump[2] = new(ResDoubleArrayJumpY,duration,startY,endY,times,height)

	anims[1] = new(AnimIndex,animType,0,resJump[1]:getLength()-1,duration,resJump[1],delay);
	anims[2] = new(AnimIndex,animType,0,resJump[2]:getLength()-1,duration,resJump[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resJump[1],resJump[2]) then
		return anims[1],anims[2];
	end
end 


DrawingBase.addPropTranslateEllipse = function(self,sequence,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
	local layoutScale = System.getLayoutScale();
	centerX = centerX and centerX * layoutScale or centerX;
	centerY = centerY and centerY * layoutScale or centerY;
	axisX = axisX and axisX * layoutScale or axisX;
	axisY = axisY and axisY * layoutScale or axisY;
	return DrawingBase.addAnimPropEllipse(self,sequence,PropTranslate,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
end 

DrawingBase.addAnimPropEllipse = function(self,sequence,propClass,animType,duration,delay,centerX,centerY,axisX,axisY,angle)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resEllipse = {};
	local anims = {};

	resEllipse[1] = new(ResDoubleArrayEllipseX,duration,centerX,axisX,angle)
	resEllipse[2] = new(ResDoubleArrayEllipseY,duration,centerY,axisY,angle)

	anims[1] = new(AnimIndex,animType,0,resEllipse[1]:getLength()-1,duration,resEllipse[1],delay);
	anims[2] = new(AnimIndex,animType,0,resEllipse[2]:getLength()-1,duration,resEllipse[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resEllipse[1],resEllipse[2]) then
		return anims[1],anims[2];
	end
end 


DrawingBase.addPropTranslateCurve = function(self,sequence,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	local layoutScale = System.getLayoutScale();
	startX = startX and startX * layoutScale or startX;
	endX = endX and endX * layoutScale or endX;
	startY = startY and startY * layoutScale or startY;
	endY = endY and endY * layoutScale or endY;
	controlX = controlX and controlX * layoutScale or controlX;
	controlY = controlY and controlY * layoutScale or controlY;
	return DrawingBase.addAnimPropCurve(self,sequence,PropTranslate,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
end 

DrawingBase.addAnimPropCurve = function(self,sequence,propClass,animType,duration,delay,startX,endX,startY,endY,controlX,controlY)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local resCurve = {};
	local anims = {}

	resCurve[1] = new(ResDoubleArrayCurve,duration,startX,endX,controlX);
	resCurve[2] = new(ResDoubleArrayCurve,duration,startY,endY,controlY);

	anims[1] = new(AnimIndex,animType,0,resCurve[1]:getLength()-1,duration,resCurve[1],delay);
	anims[2] = new(AnimIndex,animType,0,resCurve[2]:getLength()-1,duration,resCurve[2],delay);

	local prop = new(propClass,anims[1],anims[2]);
	if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resCurve[1],resCurve[2]) then
		return anims[1],anims[2];
	end
end 

DrawingBase.createAnimEase = function(self, animType, EaseType,duration, delay, startValue, endValue)
	local resEase,anim;
	if startValue and endValue then
		resEase = new(EaseType,duration,startValue,endValue);
		anim = new(AnimIndex,animType,0,resEase:getLength()-1,duration,resEase,delay);
		return resEase,anim; 
	end 
end 

DrawingBase.addAnimPropEase = function(self,sequence,propClass,center,x,y,animType,EaseType,duration,delay,...)
	if not DrawingBase.checkAddProp(self,sequence) then 
		return;
	end

	delay = delay or 0;

	local nAnimArgs = select("#",...);
	local nAnims = math.floor(nAnimArgs/2);

	local anims = {};
	local resEase = {};

	for i=1,nAnims do 
		local startValue,endValue = select(i*2-1,...);
		resEase[i],anims[i] = DrawingBase.createAnimEase(self,animType,EaseType,duration,delay,startValue,endValue);
	end

	if nAnims == 1 then
		local prop = new(propClass,anims[1],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],resEase[1]) then
			return anims[1];
		end
	elseif nAnims == 2 then
		local prop = new(propClass,anims[1],anims[2],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],resEase[1],resEase[2]) then
			return anims[1],anims[2];
		end
	elseif nAnims == 3 then
		local prop = new(propClass,anims[1],anims[2],anims[3],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],anims[3],resEase[1],resEase[2],resEase[3]) then
			return anims[1],anims[2],anims[3];
		end
	elseif nAnims == 4 then
		local prop = new(propClass,anims[1],anims[2],anims[3],anims[4],center,x,y);
		if DrawingBase.doAddPropEase(self,prop,sequence,anims[1],anims[2],anims[3],anims[4],resEase[1],resEase[2],resEase[3],resEase[4]) then
			return anims[1],anims[2],anims[3],anims[4];
		end
	else
		for _,v in pairs(anims) do 
			delete(v);
		end
		for _,v in pairs(resEase) do
			delete(v);
		end 
		error("There is not such a prop that requests more than 4 anims");
	end

end 

DrawingBase.doAddPropEase = function(self,prop,sequence, ...)
	local nums = select("#",...) / 2;
	local anims = {};
	local reses = {};
	for i = 1,nums do 
		local anim = select(i,...);
		table.insert(anims,anim);
		local res = select(nums + i,...);
		table.insert(reses,res);
	end 
	if DrawingBase.addProp(self,prop,sequence) then 
		self.m_props[sequence] = {["prop"] = prop;["anim"] = anims;["res"] = reses};
		return true;
	else
		delete(prop);
		for _,v in pairs(anims) do 
			delete(v);
		end 
		for _,v in pairs(reses) do 
			delete(v);
		end 
		return false;
	end 
end 


end 