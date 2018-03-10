-- 道具类

Prop = class();


Prop.ctor = function ( self )
	-- body
end

Prop.parseData = function ( self, data )
	self.name = data.name;           --商品名称
    self.image = data.image;         --图片路径
    self.goodsdes = data.goodsdes;   --描述
    self.num = data.num;             --剩余数量
    self.cid = data.cid;             --卡片编号
    self.endtime = data.endtime;     --到期时间
    self.type = data.type;
end

Prop.dtor = function ( self )
	-- body
end


