require("Utils")
local this = {obj=nil}
local gameObject
local transform
local image;
local vector=Vector3.New(0, 0, -30);

function this.onAwake(obj)
  this.obj=obj
  gameObject=obj.gameObject;
  transform=obj.transform;
end

local i=0;
function this.onUpdate()
  i=i+1;
  if i==3 then
    i=0;
    image.transform:Rotate(vector)
  end
end

function this.onStart(param)
  image=Utils.GetImage(gameObject,"Image")
end

return this;
