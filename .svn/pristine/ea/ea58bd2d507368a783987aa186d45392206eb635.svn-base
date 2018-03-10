
require("Utils")
local this = {obj=nil}
local gameObject
local transform
local item;
local go;

function this.onAwake(obj)
  this.obj=obj
  gameObject=obj.gameObject;
  transform=obj.transform;
end

local function onClick()
  this.obj:Destroy();
end

function this.onStart(param)
  local text=Utils.GetText(gameObject,"BG/Text")
  text.text=param;

  Utils.AddClickListener(gameObject, "BG/Button",  onClick);
end
return this;
