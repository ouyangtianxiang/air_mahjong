

BaseAnim = {};

-- #param
-- control  :  控件
-- callback :  回调
function BaseAnim.moveTo( control , param , callback)
	param.time = param.time or 0;  -- 时间
	param.dist_x = param.dist_x or 0;  -- x的位移
	param.dist_y = param.dist_y or 0;  -- y的位移
	param.type = param.type or kAnimNormal;  -- 类型
	param.delay = param.delay or 0;   -- 动画延时
end

-- #param
-- control  :  控件
-- scale_w  :  宽的拉伸比例
-- scale_h  :  高的拉伸比例
-- callback :  回调
function BaseAnim.scaleTo( control , param , callback)
	
end

-- #param
-- control  :  控件
-- dist_x   :  x的位移
-- dist_y   :  y的位移
-- callback :  回调
function BaseAnim.rotateTo( control , dist_x , dist_y , callback)
	
end

