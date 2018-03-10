require("particle/particleBase");

--ParticleRadialLine --粒子类
--辐射光线

ParticleRadialLine = class(ParticleBase);
ParticleRadialLine.liveTime = 5;	--粒子生命时长
ParticleRadialLine.colortable = {{1.0,1.0,1.0,1.0}};

ParticleRadialLine.init = function(self, len, index, node)
    local moredata = node:getMoreData();
	self.m_fade = 0.2;--衰减速度
	self.m_active = true;		--是否激活状态
 	self.m_live = ParticleRadialLine.liveTime;--粒子生命
 	self.m_rotation = (15*len)%360;
	if self.m_rotation%45==15 then
	 	self.m_rotation=self.m_rotation-5;
	elseif self.m_rotation%45==30 then
	 	self.m_rotation=self.m_rotation+5;
 	end
 	
 	local r = moredata.r or 10
 	
 	self.m_frame = math.ceil(self.m_live/self.m_fade);
 	self.m_yi = math.sin(math.rad(self.m_rotation))*r/self.m_frame;
--	if math.random(10) > 5 then self.m_yi = -self.m_yi;end 
	self.m_alpha = 0.0;
	--移动速度/方向
    self.m_x, self.m_y0 = 0,0
	self.m_y = self.m_y0;
	if self.m_rotation%45==0 then
		self.m_x=math.cos(math.rad(self.m_rotation))*18;
		self.m_y=math.sin(math.rad(self.m_rotation))*18;
	end
	self.m_scale = 1;
	self.m_tick = 0;
    -- node:setParPos(self.m_x, self.m_y, self.m_scale, len);
    -- node:setParColor(ParticleRadialLine.colortable, self.m_alpha, len);
 	self.m_xi = math.cos(math.rad(self.m_rotation))*r/self.m_frame;

    self.unit_index = math.random(10000)%(#self.unit)

    self._instruction = Rectangle(Rect(0,0,self.unit[self.unit_index+1].size.x * System.getLayoutScale(),self.unit[self.unit_index+1].size.y* System.getLayoutScale()), Matrix(), self.unit[self.unit_index+1].uv_rect)
    self._instruction.colorf = Colorf(1.0,1.0,1.0,1.0)
    self._mat = Matrix()
    self.translate_mat = Matrix()
    self.translate_inverse_mat = Matrix()

    self.width = self.unit[self.unit_index+1].size.x *self.m_scale
    self.height = self.unit[self.unit_index+1].size.y *self.m_scale
    self._instruction.rect = Rect(self.m_x,self.m_y,self.width,self.height)
end

local Rad = math.rad
local Cos = math.cos
local Sin = math.sin
ParticleRadialLine.update = function(self)
    if self.m_active then  --激活
        -- 返回X，Y轴的位置
        local x = self.m_x;
        local y = self.m_y;
        self.m_tick = self.m_tick + 1;
        if self.m_tick > self.m_frame then  self.m_tick = self.m_frame;end
        
        --重新设定粒子在屏幕的位置
        x = x + self.m_xi ;
        y = y + self.m_yi ;
    	self.m_x, self.m_y = x, y; 
    	--self.m_scale = self.m_tick/self.m_frame;
    	self.m_alpha =( self.m_frame*1.5 - self.m_tick)/self.m_frame;
    	if self.m_alpha > 1.0 then self.m_alpha = 1.0;end
    	local temp=1/3.0*ParticleRadialLine.liveTime;
    	if temp<=self.m_live then self.m_alpha = (ParticleRadialLine.liveTime-self.m_live)/temp/2;
    	else self.m_alpha = self.m_live/temp;end

        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        self._instruction.colorf = Colorf(math.random(),math.random(),math.random(),self.m_alpha)
        self._instruction.uv_rect = self.unit[self.unit_index+1].uv_rect
        self._instruction.rect = Rect(self.m_x,self.m_y,self.width,self.height)
        

        self.translate_mat:loadIdentity()
        self.translate_inverse_mat:loadIdentity()
        self._mat:loadIdentity()

        self.translate_mat:translate((self.m_x + self.width/2),(self.m_y+ self.height/2), 0)
        self._mat:rotate(self.m_rotation or 0, 0, 0, 1)
        self.translate_inverse_mat:translate(-(self.m_x + self.width/2),-(self.m_y+ self.height/2), 0)
        self.translate_mat:mul(self._mat)
        self.translate_mat:mul(self.translate_inverse_mat)
        self._instruction.matrix = self.translate_mat

        if self.m_live < 0.0 then
            self.m_active = false;
            self.m_scale = 0;
            self._instruction:release()
            return
        else
            return  self._instruction
        end
    end
end
