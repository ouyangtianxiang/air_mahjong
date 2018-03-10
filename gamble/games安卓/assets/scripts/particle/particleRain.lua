
require("particle/particleBase");

--ParticleRain --粒子类
ParticleRain = class(ParticleBase);

ParticleRain.liveTime = 6;    --粒子生命时长
ParticleRain.colortable = {{1.0,0.435,0.482,0.5},{1.0,0.243,0.0,0.5},{1.0,0.702,0.0,0.5},{0.5,0.596,1.0,0.5},{0.322,1.0,0.0,0.5},{1.0,0.267,0.8510,0.5}};


ParticleRain.init = function(self, len, index, node)
    self.m_fade = math.random()/50.0 +0.05;--衰减速度
    self.m_active  = true;      --是否激活状态
    self.moredata = Copy(node:getMoreData())
    if self.moredata.rotation and math.random()>0.5 then
        self.moredata.rotation=-self.moredata.rotation;
    end
    self.m_live = self.moredata.liveTime or ParticleRain.liveTime;--粒子生命
    self.m_frame = math.ceil(self.m_live/self.m_fade);
    local h = self.moredata.h;
    local w = self.moredata.w;
    self.m_yi = 3.5;
    self.m_xi = math.random()*0.2*(math.random()>0.5 and 1 or -1);
    -- 加速度
    self.m_xg = math.random()*0.1*(math.random()>0.5 and 1 or -1);
    self.m_yg = -math.random()*0.02;
    self.m_alpha = 1.0;
    --移动速度/方向
    self.m_y0 = math.random(h/3)-30;
    self.m_x = math.random(w);
    self.m_y = self.m_y0;
    self.m_scale = self.moredata.scale or 1.0;
    self.m_tick = 0;
    -- node:setParPos(self.m_x, self.m_y, self.m_scale, len);
    -- node:setParColor(ParticleRain.colortable, self.m_alpha, len);
    self.m_rotation = 0;

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
ParticleRain.update = function(self)
    if self.m_active then
        self.m_tick = self.m_tick + 1;
        if self.m_tick>self.m_frame then self.m_tick = self.m_frame;end
        self.m_alpha = 1.2-self.m_tick/self.m_frame;
        
        --重新设定粒子在屏幕的位置
        self.m_x = self.m_x + self.m_xi; 
        self.m_y = self.m_y + self.m_yi; 
        -- 更新X,Y轴方向速度大小
        self.m_xi = self.m_xi + self.m_xg;
        self.m_yi = self.m_yi + self.m_yg;
        if self.m_xi>2 then self.m_xg = -0.1;end
        if self.m_xi< -2 then self.m_xg = 0.1;end
     
        self.m_rotation = self.m_rotation+(self.moredata.rotation or 0);


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
