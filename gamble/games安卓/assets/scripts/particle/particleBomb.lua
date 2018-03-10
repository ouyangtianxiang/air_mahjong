require("particle/particleBase");

--ParticleBomb --粒子类
--爆炸喷发
ParticleBomb = class(ParticleBase);

ParticleBomb.liveTime = 4;  --粒子生命时长
ParticleBomb.dir = {{1,1};{1,-1};{-1,1};{-1,-1};}

ParticleBomb.init = function(self, len, index, node)

    local moredata = node:getMoreData();
    self.m_fade = 0.1; --衰减速度
    self:doActive(true); --是否激活状态
    self.m_h = moredata.h;
    self.m_w = moredata.w;

    self.m_live = moredata.liveTime or ParticleBubble.liveTime;--粒子生命
    self.m_frame = math.ceil(ParticleBomb.liveTime/self.m_fade);
    local random = math.random;
    index = len%4+1;

    self.m_yi = ParticleBomb.dir[index][1]*random(50, self.m_h)/self.m_frame*3;
    self.m_xi = ParticleBomb.dir[index][2]*random(50, self.m_w)/self.m_frame*3;

    self.m_tick = 0;
    self.m_period = self.m_frame/3;
    --移动速度/方向
    self.m_x, self.m_y0 = node.m_x0, node.m_y0;
    self.m_y = self.m_y0;
    self.m_scale = random(10)/10+0.5;

    self.m_rotation = random(90);

    self._instruction = Rectangle(Rect(0,0,self.unit[self.unit_index+1].size.x * System.getLayoutScale(),self.unit[self.unit_index+1].size.y* System.getLayoutScale()), Matrix(), self.unit[self.unit_index+1].uv_rect)
    self._instruction.colorf = Colorf(1.0,1.0,1.0,1.0)
    self._mat = Matrix()
    self.translate_mat = Matrix()
    self.translate_inverse_mat = Matrix()

    self.width = self.unit[self.unit_index+1].size.x *self.m_scale
    self.height = self.unit[self.unit_index+1].size.y *self.m_scale
    
end


local Rad = math.rad
local Cos = math.cos
local Sin = math.sin
ParticleBomb.update = function(self)
    if self.m_active then
        self.m_tick = self.m_tick+1;
        self.m_rotation = self.m_rotation+5;

        if self.m_period>self.m_tick then
            self.m_x = self.m_x + self.m_xi;
            self.m_y = self.m_y + self.m_yi; 
        end

        -- 如果粒子生命小于0
        -- self._instruction.rect = Rect(self.m_x,self.m_y,unit[self.unit_index+1].size.x,unit[self.unit_index+1].size.y)
        -- self._instruction.colorf = Colorf(1.0,1.0,1.0,self.m_alpha)
        -- self._instruction.uv_rect = self.unit[self.unit_index+1].uv_rect
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

        if self.m_tick>self.m_frame then
            self.m_active = false;
            self.m_scale = 0;
            self.m_tick = self.m_frame;
            self._instruction:release()
            return
        else
            return  self._instruction
        end
    
        
    end
end