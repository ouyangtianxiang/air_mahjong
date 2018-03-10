require("particle/particleBase");

--ParticleTail --粒子类
ParticleTail = class(ParticleBase);

ParticleTail.liveTime = 4;    --粒子生命时长

ParticleTail.init = function(self, len, index, node)
    if self.m_Image then
        delete(self.m_Image);
        self.m_Image = nil;
    end

    self.m_Image = new(Image, self.m_FileName);
    node:addChild(self.m_Image);


    local moredata = node:getMoreData();
    self.m_fade = (math.random()*100)/1000.0 +0.05;--衰减速度
    self:doActive(true);
    self.m_live = moredata.liveTime or ParticleTail.liveTime;--粒子生命
    local h = moredata.h;
    local w = moredata.w;
    local direction = moredata.direction or 1;
    self.m_frame = math.ceil(self.m_live/self.m_fade);
   if direction==1 then
        self.m_yi = math.random(5);
        self.m_xi = (5-math.random(10))*0.1;
    elseif direction==2 then
        self.m_yi = -math.random(5);
        self.m_xi = (5-math.random(10))*0.1;
    elseif direction==3 then
        self.m_yi = (5-math.random(10))*0.1;
        self.m_xi = math.random(5);
    elseif direction==4 then
        self.m_yi = (math.random(10)*0.1);
        self.m_xi = -math.random(5);
    end
    self.m_alpha = 1.0;
    --移动速度/方向
    self.m_x = 0;
    self.m_y = 0;
    self.m_scale = 1.0;
    
    self.m_tick = 0;
 
end

ParticleTail.update = function(self)
    if not self.m_active then return end
    
    self.m_tick = self.m_tick + 1;
    if self.m_tick > self.m_frame then  self.m_tick = self.m_frame;end

    --重新设定粒子在屏幕的位置
    self.m_x = self.m_x + self.m_xi;
    self.m_y = self.m_y + self.m_yi; 
    
    self.m_alpha = (self.m_frame*1.5 - self.m_tick)/self.m_frame;
    if self.m_alpha > 1.0 then self.m_alpha = 1.0;end
 
    -- 减少粒子的生命值
    self.m_live = self.m_live - self.m_fade;

    -- 如果粒子生命小于0
    if (self.m_live < 0.0) then 
        self:doActive(false);
        self.m_scale = 0;
    end

------------------ 更新粒子的显示 ----------------
    self.m_Image:setTransparency(self.m_alpha);

    local rad = math.rad(self.m_rotation or 0);
    local cosA = math.cos(rad);
    local sinA = math.sin(rad);

    local w, h = self.m_Image:getSize();
    w = w / 2 * self.m_scale;
    h = h / 2 * self.m_scale;
    -- setForceMatrix的旋转点为父节点位置.如果要绕Image中心点旋转，则需要先平移-w, -h，之后再旋转，再平移w,h
    --下面是x,y最终结果
    local x = -w*cosA + h*sinA + w + self.m_x;
    local y = -w*sinA - h*cosA + h + self.m_y;
    
    self.m_Image:setForceMatrix(self.m_scale*cosA,  self.m_scale*sinA, 0, 0,
                                -self.m_scale*sinA, self.m_scale*cosA, 0, 0,
                                0,     0,    1, 0,
                                x,     y,    0, 1);
    
end

ParticleTail.dtor = function (self)
    if self.m_Image then 
        delete(self.m_Image);
        self.m_Image = nil;
    end
end
