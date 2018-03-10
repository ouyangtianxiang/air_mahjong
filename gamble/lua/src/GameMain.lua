GameMain = { }
local this = GameMain
local obj
local gameObject
local transform

function this.onAwake(_obj)
  obj=_obj;
  gameObject=obj.gameObject;
  transform=obj.transform;
end

local function onPreload()
end

local function onRes()
  GameUI.ShowWindow("ui/Login");
end

function this.onStart(param)
  local ui=obj.transform:Find("GameUI");
  Game.LuaGame.it:Mount(ui.gameObject,"GameUI",nil);

  Game.Loader.it:Preload("res", onRes, onPreload);
end


return this;
