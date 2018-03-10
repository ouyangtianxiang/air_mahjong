require("particle/particleBase");

--ParticleDust --粒子类
ParticleDust = class(ParticleBase);

ParticleDust.liveTime = 4;    --粒子生命时长

ParticleDust.init = function(self, len, index, node)
    local moredata = node:getMoreData();
    self.m_fade = (math.random()*100)/1000.0 +0.1;--衰减速度
    self.m_active  = true;
    self.m_live = moredata.liveTime or ParticleDust.liveTime;--粒子生命
    local h = moredata.h;
    local w = moredata.w;
    local direction = moredata.direction or 1;
    self.m_frame = math.ceil(self.m_live/self.m_fade);
    --移动速度/方向
    self.m_x = 0;
    self.m_y = 0;
   if direction==1 then--down
        self.m_yi = math.random(5);
        self.m_xi = (5-math.random(10))*0.1;
        self.m_x = math.random(w/2)-w/4;
    elseif direction==2 then--up
        self.m_yi = -math.random(5);
        self.m_xi = (5-math.random(10))*0.1;
        self.m_x = math.random(w/2)-w/4;
    elseif direction==3 then--right
        self.m_yi = (5-math.random(10))*0.1;
        self.m_xi = math.random(5);
        self.m_y = math.random(h/2)-h/4;
    elseif direction==4 then--left
        self.m_yi = (math.random(10)*0.1);
        self.m_xi = -math.random(5);
        self.m_y = math.random(h/2)-h/4;
    end
    self.m_alpha = 1.0;
    self.m_scale = 0.5+math.random(1.5);
    self.m_tick = 0;
    -- node:setParPos(self.m_x, self.m_y, self.m_scale, len);
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
ParticleDust.update = function(self)
    if self.m_active then  --激活
        self.m_tick = self.m_tick + 1;
        if self.m_tick > self.m_frame then  self.m_tick = self.m_frame;end
        if self.m_scaleFlag then
            --self.m_scale = self.m_scaleFlag*(1-self.m_tick/self.m_frame);
        end
        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x + self.m_xi;
        self.m_y = self.m_y + self.m_yi; 
        
        self.m_alpha = (self.m_frame*1.5 - self.m_tick)/self.m_frame;
        if self.m_alpha > 1.0 then self.m_alpha = 1.0;end
     
        -- 减少粒子的生命值
        self.m_live = self.m_live - self.m_fade;
        self._instruction.colorf = Colorf(1.0,1.0,1.0,self.m_alpha)
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
