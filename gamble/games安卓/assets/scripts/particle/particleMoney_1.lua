require("particle/particleBase");

--ParticleMoney --粒子类
ParticleMoney = class(ParticleBase);

ParticleMoney.liveTime = 8;    --粒子生命时长

ParticleMoney.init = function(self, len, index, node)
    local moredata = node:getMoreData();
    self.m_fade = math.random()/100.0+0.05;--衰减速度
    self.m_active = true;--是否激活状态
    self.m_orgRot = moredata.rotation;
    if self.m_orgRot and math.random()>0.5 then
        self.m_orgRot=-self.m_orgRot;
    end
    self.m_live = moredata.liveTime or ParticleMoney.liveTime;--粒子生命
    self.m_frame = math.ceil(self.m_live/self.m_fade);
    --移动速度
    self.m_yi = System.getLayoutScale()*(math.random(17)+21);
    self.m_xi = 0;
    -- 加速度
    self.m_xg = 0;
    self.m_yg = 0.2;
    self.m_alpha = 1.0;
    --初始位置
    local h = moredata.h;
    local w = moredata.w;
    self.m_maxH = System.getScreenHeight();
    self.m_x = math.random(w);
    self.m_y = -math.random(h*1.5);
    self.m_scale = (math.random(70)+30)/50.0*System.getLayoutScale();
    self.m_tick = 0;
    self.m_dropFlag = true;
    self.m_rotation = math.random(3.14);
    self.m_maxIndex = moredata.maxIndex;
    if self.m_maxIndex then 
    	self.m_index = 1+math.random(1000023)%self.m_maxIndex;
    	self.m_indexStep = self.m_index;
    end
end

ParticleMoney.update = function(self)
    if self.m_active then
        self.m_tick = self.m_tick + 1;
        if self.m_tick>self.m_frame then self.m_tick = self.m_frame;end
        self.m_alpha = 1.2-self.m_tick/self.m_frame;
        
        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x; 
        self.m_y = self.m_y + self.m_yi; 
        -- 更新X,Y轴方向速度大小
        self.m_yi = self.m_yi + self.m_yg;
        if self.m_y>=self.m_maxH and self.m_dropFlag then 
        	self.m_yi=-self.m_yi/2;
        	self.m_yg = 0.8;
        	self.m_dropFlag = false;
        end
        if self.m_maxIndex then self.m_indexStep = self.m_indexStep+0.2;end
        if self.m_maxIndex and self.m_indexStep>=self.m_maxIndex+1 then
        	self.m_indexStep = 1;
        end
        if self.m_maxIndex then self.m_index = math.floor(self.m_indexStep);end
        self.m_rotation = self.m_rotation+(tonumber(self.m_orgRot) or 0);
        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        -- 如果粒子生命小于0
        if self.m_live < 0.0 or (not self.m_dropFlag and self.m_y>=self.m_maxH+30)then
            self.m_active = false;
            self.m_scale = 0;
        end
        -- if not self.m_active then
        --     print("del")
        -- end
    end


--     self.m_Image:setTransparency(self.m_alpha);

--     local rad = math.rad(self.m_rotation or 0);         --角度转弧度
--     local cosA = math.cos(rad);
--     local sinA = math.sin(rad);

--     local w, h = self.m_Image:getSize();
--     w = w / 2 * self.m_scale;
--     h = h / 2 * self.m_scale;
--     -- setForceMatrix的旋转点为父节点位置.如果要绕Image中心点旋转，则需要先平移-w, -h，之后再旋转，再平移w,h
--     --下面是x,y最终结果
--     local x = -w*cosA + h*sinA + w + self.m_x;
--     local y = -w*sinA - h*cosA + h + self.m_y;
    
--     -- self.m_Image:setForceMatrix(self.m_scale*cosA,  self.m_scale*sinA, 0, 0,
--     --                             -self.m_scale*sinA, self.m_scale*cosA, 0, 0,
--     --                             0,     0,    1, 0,
--     --                             x,     y,    0, 1);
--    --test
--     local _attr = {
--       [Widget.ATTR_X] = x,
--       [Widget.ATTR_Y] = y,
--       [Widget.ATTR_SCALEX] = self.m_scale,
--       [Widget.ATTR_SCALEY] = self.m_scale,
--       [Widget.ATTR_ROTATION] = self.m_rotation,
--       [Widget.ATTR_OPACITY] = self.m_alpha,
--       --[Widget.ATTR_VISIBLE] = true,

--   };
-- --   --self.m_Image:getWidget():set_attributes(_attr)
-- --   --local ret = {w = self.m_Image, attr = _attr}
--  return _attr;


    
end
