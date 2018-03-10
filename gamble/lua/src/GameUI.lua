GameUI = { }
local this = GameUI
local gameObject
local transform

function this.onAwake(obj)
  gameObject=obj.gameObject;
  transform=obj.transform;
end

local function onEscape()
  if transform.childCount>1 then
    local child=transform:GetChild(transform.childCount-1);
    UnityEngine.GameObject.Destroy(child.gameObject)
  else
    UnityEngine.Application.Quit();
  end
end

function this.onStart(param)
  Game.LuaGame.it:AddKeyListener("escape",onEscape,0);
end

function this.ShowWindow(name,param)
  local gameObject = Game.Loader.it:CreateGameObject(transform, name);
  Game.LuaGame.it:Mount(gameObject,name,param)
  return gameObject;
end

return this;
