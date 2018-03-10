
-- particleSystem.lua
-- Author: Williamwu
-- Date: 2013-04-10
-- Last modification : 2015-01-30
-- Description: Particle Manager

require("core/drawing");
require 'particle/customRender'

ParticleSystem = class();

kParticleTypeForever = 1;
kParticleTypeBlast	 = 2;

ParticleSystem.s_instance = nil;

-- ----------------------------interface
--得到唯一实例对象
ParticleSystem.getInstance = function()
	if not ParticleSystem.s_instance then 
		ParticleSystem.s_instance = new(ParticleSystem);
	end
	return ParticleSystem.s_instance;
end

--释放唯一实例对象
ParticleSystem.releaseInstance = function()
    delete(ParticleSystem.s_instance);
    ParticleSystem.s_instance = nil;
end

--调用生成一类粒子,返回ParticleNode
ParticleSystem.create = function(self, file, particle, x0, y0, color, parType,maxNum, moredata)
	if not file or not particle then 
		return nil;
	end
 	local index = table.maxn(self.m_pars)+1;

 	self.m_pars[index] = new(ParticleNode, index, file, particle, x0, y0, color, parType,maxNum, moredata);

 	return self.m_pars[index];	
end

--停止喷射粒子
ParticleSystem.stopAll = function(self)
	self.m_isStoped = true;
end

--恢复stopAll之前状态
ParticleSystem.startAll = function(self)
	self.m_isStoped = false;
end

--暂停刷新粒子
ParticleSystem.pauseAll = function(self)
	self.m_isPaused = true;
end

--恢复pauseAll之前状态
ParticleSystem.resumeAll = function(self)
	self.m_isPaused = false;
end

-------------------------private
ParticleSystem.ctor = function(self)
    self.m_pars = {};
	self.m_tick = 0;
    self.m_isStoped = false;
	self.m_isPaused = false;

	-- self.m_anim = new(AnimDouble, kAnimRepeat, 0, 1, 1, 0);
	-- self.m_anim:setDebugName("AnimDouble|ParticleSystem.ctor");
	-- self.m_anim:setEvent(self, self.update);
end

ParticleSystem.dtor = function(self)
	delete(self.m_anim);
	self.m_anim = nil;

	for k, v in pairs(self.m_pars or {}) do
		local parent = v:getParent();
		if parent then
			parent:removeChild(v);
		end
		delete(v);
	end
	self.m_pars = nil;
end

ParticleSystem.remove = function(self, index)
	self.m_pars[index] = nil;
end

ParticleSystem.update = function(self, _, _, repeat_or_loop_num)
	
    local a = Clock.now()
    --print(a)


    if self.m_isPaused then 
		return;
	end
	self.m_tick = (self.m_tick + 1)%100000;
	local pos ,par,t_vtx,particles,imgW,imgH,num;
	for index, v in pairs(self.m_pars) do
		local activeNum = 0;
		-- if not v.m_isPaused then
		-- 	particles = v.m_particles;
		-- 	for loop = 1, #particles do 
		-- 		--激活状态
		--         if particles[loop].m_active then 
		--             activeNum = activeNum+1;
		--         	par = particles[loop]; 
		--         	pos = (loop-1);
		--         	par:update(v, pos);
		        	
		-- 					t_vtx = v.m_vertexArr;
		-- 					imgW = v.m_texW;
		-- 					imgH = v.m_texH;
		-- 					local parPos = pos*8;

		-- 					if par.m_rotation then
		-- 						imgW = imgW/2;
		-- 						imgH = imgH/2;
		-- 						local rad = math.rad(par.m_rotation);
		-- 						local cosA = math.cos(rad);
		-- 						local sinA = math.sin(rad);
		-- 						local cs_w = cosA*( imgW);
		-- 						local sn_h = sinA*( imgH);
		-- 						local sn_w = sinA*( imgW);
		-- 						local cs_h = cosA*( imgH);
		-- 						t_vtx[parPos+1] = par.m_scale*(-cs_w+sn_h)+par.m_x + imgW;-- needs offset
		-- 						t_vtx[parPos+2] = par.m_scale*(-sn_w-cs_h)+par.m_y + imgH;
		-- 						t_vtx[parPos+3] = par.m_scale*(cs_w+sn_h) +par.m_x + imgW;
		-- 						t_vtx[parPos+4] = par.m_scale*(sn_w-cs_h) +par.m_y + imgH;
		-- 						t_vtx[parPos+5] = par.m_scale*(cs_w-sn_h) +par.m_x + imgW;
		-- 						t_vtx[parPos+6] = par.m_scale*(sn_w+cs_h) +par.m_y + imgH;
		-- 						t_vtx[parPos+7] = par.m_scale*(-cs_w-sn_h)+par.m_x + imgW;
		-- 						t_vtx[parPos+8] = par.m_scale*(-sn_w+cs_h)+par.m_y + imgH;
		-- 					else
		-- 						local offsetX = par.m_scale*imgW/2;
		-- 						local offsetY = par.m_scale*imgH/2;
		-- 						t_vtx[parPos+1],t_vtx[parPos+3],t_vtx[parPos+5],t_vtx[parPos+7] = par.m_x-offsetX,par.m_x+offsetX,par.m_x+offsetX,par.m_x-offsetX;
		-- 						t_vtx[parPos+2],t_vtx[parPos+4],t_vtx[parPos+6],t_vtx[parPos+8] = par.m_y-offsetY,par.m_y-offsetY,par.m_y+offsetY,par.m_y+offsetY;
		-- 					end

		-- 					if v.m_texType==3 and par.m_index then
		-- 						for i = 1, 8 do
		-- 							v.m_coordArr[parPos+i] = v.m_texCoordArr[par.m_index][i];
		-- 						end
		-- 					end

		-- 				if v.m_color and par.m_alpha and par.m_colorChanged then
		-- 					parPos = parPos*2;
		-- 					local arr = v.m_colorArr;
		-- 					local ac = 1;
		-- 					for i = 0, 3 do
		-- 						arr[parPos+i*4+1],arr[parPos+i*4+2],arr[parPos+i*4+3],arr[parPos+i*4+4] = par.m_r*ac,par.m_g*ac,par.m_b*ac,par.m_alpha;
		-- 					end
	 --            			par.m_colorChanged = false;
		-- 				end
	 --        end
		--     end	

  --           --print(inspect(v.m_vertexArr))
		-- 	res_set_double_array2(v.m_vertexResId, v.m_vertexArr);
		-- 	if v.m_texType==3 then 
		-- 		res_set_double_array2(v.m_coordResId, v.m_coordArr);
		-- 	end
		-- 	if v.m_color then 
		-- 		res_set_double_array2(v.m_colorResId, v.m_colorArr);
		-- 	end
		--     if self.m_tick%2==1 and not (v.m_isStoped or self.m_isStoped) then
		--     	if v.m_type == kParticleTypeBlast then 
		--     		-- for i = 1, v.m_maxNum do
		-- 	     --    	v:generate(repeat_or_loop_num);
		--     		-- end
		--     		v.m_isStoped = true;
		-- 	    elseif activeNum < v.m_maxNum then 
		-- 			num, v.m_newNum = math.modf(v.m_newNum+v.m_stepNum);
		--     		for i = 1, num do
		-- 	        	v:generate(repeat_or_loop_num);
		-- 	        end
		-- 	    end
		-- 	end
		-- end
	end


    local b = Clock.now()
    --print(b)
    DebugLog("update:  "..tostring(b-a))

end

--------------------
ParticleNode = class(DrawingEmpty);
ParticleNode.defaultCoord = {0.0,1.0,1.0,1.0,1.0,0.0,0.0,0.0};

ParticleNode.ctor = function(self, index, file, particle, x0, y0, color, parType, maxNum, moredata)
	self.m_index = index;
 	self.m_fileName = file;
 	self.m_particle = particle;
	self.m_x0 = x0;
 	self.m_y0 = y0;
 	self.m_color = color;
	self.m_type = parType==kParticleTypeBlast and kParticleTypeBlast or kParticleTypeForever;
	self.m_maxNum = maxNum or 40;
 	self.m_moredata = moredata;
 	self.m_newNum = 0;
 	self.m_stepNum = moredata and moredata.stepNum or 3;

 	self.m_particles = {};
 	self.m_isStoped = true;
 	-- self.m_isPaused = false;

 	self.m_vertexResId = res_alloc_id();
 	self.m_vertexArr = {};
	res_create_double_array2(0,self.m_vertexResId,self.m_vertexArr);
 	self.m_indexResId = res_alloc_id();
 	self.m_indexArr = {};
	res_create_ushort_array2(0,self.m_indexResId,self.m_indexArr);
 	self.m_coordResId = res_alloc_id();
 	self.m_coordArr = {};
	res_create_double_array2(0,self.m_coordResId,self.m_coordArr);
	if color then 
	 	self.m_colorResId = res_alloc_id();
	 	self.m_colorArr = {1};
		res_create_double_array2(0,self.m_colorResId,self.m_colorArr);
	end
 	self.m_imageResId = res_alloc_id();
	if type(file)=="table" then
		if moredata.maxIndex then
			self.m_texType = 3;
			res_create_image(0,self.m_imageResId,file["1.png"].file,0,1);
			self.m_mainTexW = res_get_image_width(self.m_imageResId);
			self.m_mainTexH = res_get_image_height(self.m_imageResId);
			self.m_subTexW = file["1.png"].width;
			self.m_subTexH = file["1.png"].height;
			self.m_texCoordArr = {};
			local f;
			for i = 1, moredata.maxIndex do
				f = file[i .. ".png"];
				self.m_texCoordArr[i] = {f.x/self.m_mainTexW,(f.y+f.height)/self.m_mainTexH,(f.x+f.width)/self.m_mainTexW,(f.y+f.height)/self.m_mainTexH,(f.x+f.width)/self.m_mainTexW,f.y/self.m_mainTexH,f.x/self.m_mainTexW,f.y/self.m_mainTexH};
			end
		else
			self.m_texType = 2;
			res_create_image(0,self.m_imageResId,file.file,0,1);
			self.m_mainTexW = res_get_image_width(self.m_imageResId);
			self.m_mainTexH = res_get_image_height(self.m_imageResId);
			self.m_subTexW = file.width;
			self.m_subTexH = file.height;
			
			self.m_texCoordArr = {file.x/self.m_mainTexW,(file.y+file.height)/self.m_mainTexH,(file.x+file.width)/self.m_mainTexW,(file.y+file.height)/self.m_mainTexH,(file.x+file.width)/self.m_mainTexW,file.y/self.m_mainTexH,file.x/self.m_mainTexW,file.y/self.m_mainTexH};
		end
	else
		self.m_texType = 1;
	 	res_create_image(0,self.m_imageResId,file,0,1);
	 	self.m_texCoordArr = ParticleNode.defaultCoord;
	end
	self.m_texW = self.m_subTexW or res_get_image_width(self.m_imageResId); 
	self.m_texH = self.m_subTexH or res_get_image_height(self.m_imageResId);
	self.m_drawingId = drawing_alloc_id();
	drawing_create_node(0, self.m_drawingId, 0);

	drawing_set_parent(self.m_drawingId, self.m_drawingID);

	if color then 
		drawing_set_node_renderable(self.m_drawingId, kRenderTriangles, kRenderDataAll);
	else 
		drawing_set_node_renderable(self.m_drawingId, kRenderTriangles, kRenderDataTexture);
	end
	drawing_set_node_vertex(self.m_drawingId,self.m_vertexResId,self.m_indexResId);
	drawing_set_node_texture(self.m_drawingId,self.m_imageResId,self.m_coordResId);
	if color then 
		drawing_set_node_colors(self.m_drawingId, self.m_colorResId);
	end
    self.m_isStoped = false;
	if self.m_type == kParticleTypeBlast then 
		--self.m_isStoped = false;
		for i = 1, self.m_maxNum do
	    	self:generate();
		end
		-- self.m_isPaused = true;
	end
end

ParticleNode.dtor = function(self)
	if self.m_vertexResId then
		for k, v in pairs(self.m_particles or {}) do
			delete(v);
		end
		self.m_particles = nil;
		self.m_isStoped = true;
		self.m_isPaused = true;
		res_delete(self.m_vertexResId);
    	res_free_id(self.m_vertexResId);
		self.m_vertexResId = nil;
		self.m_vertexArr = nil;
		res_delete(self.m_indexResId);
    	res_free_id(self.m_indexResId);
		self.m_indexResId = nil;
		self.m_indexArr = nil;
		res_delete(self.m_coordResId);
    	res_free_id(self.m_coordResId);
		self.m_coordResId = nil;
		self.m_coordArr = nil;
		if self.m_color then 
			res_delete(self.m_colorResId);
        	res_free_id(self.m_colorResId);
			self.m_colorResId = nil;
			self.m_colorArr = nil;
		end
		res_delete(self.m_imageResId);
    	res_free_id(self.m_imageResId);
		self.m_imageResId = nil;
		drawing_delete(self.m_drawingId);
    	drawing_free_id(self.m_drawingId);
		self.m_drawingId = nil;
		ParticleSystem.getInstance():remove(self.m_index);
	end
end

ParticleNode.generate = function(self, step)
	if self.m_isStoped then 
		return;
	end
    local par, len, particles;
    particles = self.m_particles;
   	for loop = 1, #particles do 
		 if not particles[loop].m_active then 
		 	par = particles[loop];
		 	len = loop - 1;
		 	break;
		 end
	end
	if par == nil then 
	    len = #particles;
	    if self.m_moredata.maxIndex then
	    		self.m_texType = 3;
	    		par = new(self.m_particle, self.m_fileName["1.png"]);

	    	else
	    		self.m_texType = 2;
	    		par = new(self.m_particle, self.m_fileName);
	    	end
		-- par = new(self.m_particle, self.m_fileName);
		particles[len+1] = par;
		if self.m_texType~=3 then
			for i = 1, 8 do
				self.m_coordArr[len*8+i] = self.m_texCoordArr[i]; 
			end
		else 
			for i = 1, 8 do
				self.m_coordArr[len*8+i] = self.m_texCoordArr[1][i]; 
			end
		end
		local t_idx = self.m_indexArr;
		t_idx[len*6+1],t_idx[len*6+2],t_idx[len*6+3],t_idx[len*6+4],t_idx[len*6+5],t_idx[len*6+6] = 4*len+0,4*len+1,4*len+2,4*len+0,4*len+2,4*len+3;
		--透明度
		if self.m_color then
			for i = 1, 16 do
				self.m_colorArr[len*16 + i] = 1;
			end
			res_set_double_array2(self.m_colorResId, self.m_colorArr)
		end
        for i = 1, 8 do
            self.m_vertexArr[len*8 + i] = 0;
        end
		res_set_double_array2(self.m_coordResId, self.m_coordArr);
		res_set_ushort_array2(self.m_indexResId, t_idx);
        res_set_double_array2(self.m_vertexResId, self.m_vertexArr);
	end
	par:init(len, index, self, step);
end

--停止喷射粒子
ParticleNode.stop = function(self)
	self.m_isStoped = true;
end

--开始喷射粒子
ParticleNode.start = function(self)
	self.m_isStoped = false;
end

--暂停刷新粒子
ParticleNode.pause = function(self)
	-- self.m_isPaused = true;
	self._handle.pause = true
end

--恢复刷新粒子
ParticleNode.resume = function(self)
	-- self.m_isPaused = false;
	if not self._handle then
		local count = 0
		self._handle = Clock.instance():schedule(function (  )
			count = count + 1 
			self:update(count)
		end)
	end
end

ParticleNode.setParPos = function(self, x, y, scale, len)
	local t_vtx = self.m_vertexArr;
	local imgW = self.m_texW;
	local imgH = self.m_texH;
	t_vtx[len*8+1],t_vtx[len*8+3],t_vtx[len*8+5],t_vtx[len*8+7] = x, x+scale*imgW, x+scale*imgW, x;
	t_vtx[len*8+2],t_vtx[len*8+4],t_vtx[len*8+6],t_vtx[len*8+8] = y, y, y+scale*imgH, y+scale*imgH;
end

ParticleNode.setParColor = function(self, colortable, alpha, len)
    local t_clr = self.m_colorArr;
    local color = colortable[math.random(#colortable)];
    if color and t_clr then
        for i = 1, 4 do 
            t_clr[len*16 + i*4 - 3] = color[1];
            t_clr[len*16 + i*4 - 2] = color[2];
            t_clr[len*16 + i*4 - 1] = color[3];
            t_clr[len*16 + i*4 - 0] = alpha;
        end
    end
end

ParticleNode.getMoreData = function(self)
	return self.m_moredata;
end

ParticleNode.getOrgPos = function(self)
	return self.m_x0, self.m_y0;
end

ParticleNode.getMaxNum = function(self)
	return self.m_maxNum;
end

ParticleNode.getFileName = function(self)
	return self.m_fileName;
end
local rad = math.rad
local cos = math.cos
local sin = math.sin
local res_set_double_array2 = res_set_double_array2
ParticleNode.update = function ( self,count )
	-- DebugLog("update: ")
	local t = Clock.now()
	local activeNum = 0
	local pos ,t_vtx,particles,imgW,imgH,num;
	for loop,par in ipairs(self.m_particles) do
		if par.m_active then
			activeNum = activeNum+1
			par:update()

			pos = loop - 1
			t_vtx = self.m_vertexArr
			imgW = self.m_texW
			imgH = self.m_texH
			local parPos = pos*8;

			if par.m_rotation then
				imgW = imgW/2;
				imgH = imgH/2;
				local rad = rad(par.m_rotation);
				local cosA = cos(rad);
				local sinA = sin(rad);
				local cs_w = cosA*( imgW);
				local sn_h = sinA*( imgH);
				local sn_w = sinA*( imgW);
				local cs_h = cosA*( imgH);
				t_vtx[parPos+1] = par.m_scale*(-cs_w+sn_h)+par.m_x + imgW;-- needs offset
				t_vtx[parPos+2] = par.m_scale*(-sn_w-cs_h)+par.m_y + imgH;
				t_vtx[parPos+3] = par.m_scale*(cs_w+sn_h) +par.m_x + imgW;
				t_vtx[parPos+4] = par.m_scale*(sn_w-cs_h) +par.m_y + imgH;
				t_vtx[parPos+5] = par.m_scale*(cs_w-sn_h) +par.m_x + imgW;
				t_vtx[parPos+6] = par.m_scale*(sn_w+cs_h) +par.m_y + imgH;
				t_vtx[parPos+7] = par.m_scale*(-cs_w-sn_h)+par.m_x + imgW;
				t_vtx[parPos+8] = par.m_scale*(-sn_w+cs_h)+par.m_y + imgH;
			else
				local offsetX = par.m_scale*imgW/2;
				local offsetY = par.m_scale*imgH/2;
				t_vtx[parPos+1],t_vtx[parPos+3],t_vtx[parPos+5],t_vtx[parPos+7] = par.m_x-offsetX,par.m_x+offsetX,par.m_x+offsetX,par.m_x-offsetX;
				t_vtx[parPos+2],t_vtx[parPos+4],t_vtx[parPos+6],t_vtx[parPos+8] = par.m_y-offsetY,par.m_y-offsetY,par.m_y+offsetY,par.m_y+offsetY;
			end

			if self.m_texType==3 and par.m_index then
				for i = 1, 8 do
					self.m_coordArr[parPos+i] = self.m_texCoordArr[par.m_index][i];
				end
			end

			if self.m_color and par.m_alpha and par.m_colorChanged then
				parPos = parPos*2;
				local arr = self.m_colorArr;
				local ac = 1;
				for i = 0, 3 do
					arr[parPos+i*4+1],arr[parPos+i*4+2],arr[parPos+i*4+3],arr[parPos+i*4+4] = par.m_r*ac,par.m_g*ac,par.m_b*ac,par.m_alpha;
				end
				par.m_colorChanged = false;
			end

		end
	end

    --print(inspect(v.m_vertexArr))
	res_set_double_array2(self.m_vertexResId, self.m_vertexArr);
	if self.m_texType==3 then 
		res_set_double_array2(self.m_coordResId, self.m_coordArr);
	end
	if self.m_color then 
		res_set_double_array2(self.m_colorResId, self.m_colorArr);
	end
	if not self.m_isStoped  then
		-- if activeNum < self.m_maxNum then 
		-- 	num, self.m_newNum = math.modf(self.m_newNum+self.m_stepNum);
		-- 	for i = 1, num do
		-- 		self:generate(count);
		-- 	end
		-- end
	end
	if activeNum <= 0 and self.m_type == kParticleTypeBlast then
		self._handle:cancel()--  = true
		delete(self)
	end
	DebugLog("update: "..tostring(Clock.now() - t))
end
