
require("Utils")
local this = {obj=nil}
local gameObject
local transform

local username;
local password;
local toggle;

function this.onAwake(obj)
  this.obj=obj
  gameObject=obj.gameObject;
  transform=obj.transform;
  print("onAwake(MainUI)",obj);
end


local function onClick(param)
  this.obj:Destroy();
  GameUI.ShowWindow("ui/Hall");
end

function this.onStart(param)
  Utils.AddClickListener(gameObject, "Button", onClick,param);
end

return this;
