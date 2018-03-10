
AnimCurve = {};

--[[生成抛物线，p1,p3为起点和终点，h为抛物线高度，num为生成点的个数]]
function AnimCurve.createParabolaCurve(p1, p3, h, num)
	
	local pnum = num or 100;
	local step = (p3.x - p1.x)/num;	-- 默认100点
	local arryPos = {};

	local b = ( (p1.y-p3.y)*(p1.x^2-((p1.x+p3.x)/2)^2) - (p1.y-p3.y/2-h)*(p1.x^2-p3.x^2) ) 
	/ ( (p1.x-p3.x)*(p1.x^2-((p1.x+p3.x)/2)^2) - ((p1.x-p3.x)/2)*(p1.x^2-p3.x^2) );

	local a = ( (p1.y-p3.y/2-h)-b*((p1.x-p3.x)/2) )/(p1.x^2-((p1.x+p3.x)/2)^2);

	local c = p1.y - a*p1.x^2 - b*p1.x;

	for i=1,num+1 do
		arryPos[i] = {};
		arryPos[i].x = p1.x + (i-1)*step;
		arryPos[i].y = a*arryPos[i].x^2 + b*arryPos[i].x + c;
	end
	return arryPos;
end


--[[ 生成直线移动轨迹 ]]
function AnimCurve.createLineCurve( p1, p2 , num)
	local pos = {};
	local a = (p1.x-p2.x)~=0 and ((p1.y-p2.y) / (p1.x-p2.x)) or 0;
	local b = p1.y - a*p1.x;
	local pnum = num or 20;
	local temp = (p2.x-p1.x);
	local flag = false;
	if (p2.x-p1.x) <= 50 then
		temp = p2.y-p1.y;
		flag = true;
	end
	local step = temp/pnum;

	for i=1,pnum do
		pos[i] = {};
		if not flag then
			pos[i].x = p1.x + (i-1)*step;
			pos[i].y = a*pos[i].x + b;
		else
			pos[i].x = p1.x;
			pos[i].y = p1.y + (i-1)*step;
		end
	end
	return pos;
end


