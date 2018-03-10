Data={game=nil,login=nil,area=nil,power=nil,item=nil,powers=nil,level=nil,config=nil};
local function encodeURI(s)
  s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
  return string.gsub(s, " ", "+")
end

local function HCKey(url,param)
  local str=""
  if param then
    for key, var in pairs(param) do
      str=str..key..'='..var..',';
    end
  end
  return Game.Utils.it:MD5(url..str);
end

local function Encode(www,gbk)
  if gbk then
    return Game.Utils.it:GBK(www.bytes);
  else
    return www.text;
  end
end

function Http(url,onHttp,param,gbk,hc)
  print(url);
  local wait=GameUI.ShowWindow("ui/Wait");
  Game.Loader.it:WWWLoad(url,function(www)
    wait:Destroy();
    local text=Encode(www,gbk);
    if hc then
      local key=HCKey(url,param);
      if www.error == nil then
        Game.Utils.it:SaveFile(key,text);
      else
        text=Game.Utils.it:ReadFile(key);
      end
    end
    onHttp(text);
  end,param);
end
