require("Utils")
local this = {obj=nil}
local gameObject
local transform
local scrollView;

function this.onAwake(obj)
  this.obj=obj
  gameObject=obj.gameObject;
  transform=obj.transform;
  print("onAwake(MainUI)",obj);
end

local function onClick1(param)
  GameUI.ShowWindow("ui/IntoRoom",param);
end
local function onClick2(param)
  GameUI.ShowWindow("ui/CreateRoom",param);
end
local function onClick3(param)
  GameUI.ShowWindow("ui/NanchangMahjong",param);
end


function this.onStart(param)

  Utils.AddClickListener(gameObject,"ScrollView/Content/Button1",onClick1);
  Utils.AddClickListener(gameObject,"ScrollView/Content/Button2",onClick2);
  Utils.AddClickListener(gameObject,"ScrollView/Content/Button3",onClick3);

end

return this;
