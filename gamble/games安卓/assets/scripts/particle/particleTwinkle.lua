require("particle/particleBase");

--ParticleTwinkle --粒子类
--星星一闪一闪亮晶晶
ParticleTwinkle = class(ParticleBase);

ParticleTwinkle.liveTime = 4;	--粒子生命时长
ParticleTwinkle.posMap = {{10,0},{40,10},{20,12},{30,5},{4,15},{50,0},{0,10},{10,40},{4,75},{12,20},{15,60},{5,30},{15,4},{0,50}};
ParticleTwinkle.posIndex = 1;

ParticleTwinkle.init = function(self, len, index, node)
    local moredata = node:getMoreData();
	self.m_active  = true;		--是否激活状态
    self.m_scaleMax = math.abs(0.5-math.random())+2.5;
 	self.m_live = moredata.liveTime or ParticleTwinkle.liveTime;--粒子生命
 	local h = moredata.h;
    local w = moredata.w;

	--移动速度/方向
    local pos = {{0,0,1,1}, {w,0,-1,1}, {0,h,1,-1}, {w,h,-1,-1}};
    local i = ParticleTwinkle.posIndex%4+1;
    local offsetX = ParticleTwinkle.posMap[ParticleTwinkle.posIndex%#ParticleTwinkle.posMap+1][1]*pos[i][3];
	self.m_x = pos[i][1]+offsetX;

	self.m_scaleStep = 0.04;
    self.m_scaleUI = -math.random()*2;
    self.m_scale = self:getScale();

    local offsetY = ParticleTwinkle.posMap[ParticleTwinkle.posIndex%#ParticleTwinkle.posMap+1][2]*pos[i][4];
    self.m_y = pos[i][2]+offsetY;

    -- node:setParPos(self.m_x, self.m_y, self.m_scale, len);

    ParticleTwinkle.posIndex = ParticleTwinkle.posIndex% (#ParticleTwinkle.posMap*4)+1;

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
ParticleTwinkle.update = function(self)
    if self.m_active then  --激活
        self.m_scaleUI = self.m_scaleUI+self.m_scaleStep;
        if self.m_scaleStep>0 and self.m_scaleUI>self.m_scaleMax then
            self.m_scaleStep = -self.m_scaleStep;
        elseif self.m_scaleStep<0 and self.m_scaleUI<0 then
            self.m_live = -10;
        end
        self.m_scale = self:getScale();

         -- 减少粒子的生命值
        self._instruction.colorf = Colorf(math.random(),math.random(),math.random(),self.m_alpha)
        self._instruction.uv_rect = self.unit[self.unit_index+1].uv_rect
        
        

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

ParticleTwinkle.getScale = function(self)
    local ret = self.m_scaleUI;
    ret = ret>self.m_scaleMax and self.m_scaleMax or ret;
    ret = ret<0 and 0 or ret;
    return ret;
end
