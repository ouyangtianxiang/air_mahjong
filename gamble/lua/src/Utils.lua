
Utils = {}
function trace(obj)
  local str="{"
  for key, var in pairs(obj) do
    str=str..key..'='..var..',';
  end
  str=str..'}';
  print(str);
end

local this = Utils

function trim (s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function Split(str, separator)
  local begin = 1;
  local index = 1;
  local array = { };
  while true do
    local i = string.find(str, separator, begin);
    if not i then
      array[index] = string.sub(str, begin, string.len(str));
      break;
    end
    array[index] = string.sub(str, begin, i - 1);
    begin = i + string.len(separator);
    index = index + 1;
  end
  return array;
end

function RGB(color)
  local str=string.format("%X", color)
  str=string.rep("0",6-#str)..str;
  local r=("0x"..string.sub(str,1,2))/255;
  local g=("0x"..string.sub(str,3,4))/255;
  local b=("0x"..string.sub(str,5,6))/255;
  return Color.New(r,g,b,1);
end

function this.setActive(transform, isShow)
  if transform ~= nil then
    if transform.gameObject.activeSelf ~= isShow then
      transform.gameObject:SetActive(isShow)
    end
  end
end

function this.split(szFullString, szSeparator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = { }
  while true do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
    if not nFindLastIndex then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(szSeparator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
end

function this.DOAnchorPos(transform, startX, startY, endX, endY, duration, startTime, func)
  transform.anchoredPosition = Vector2.New(startX, startY);
  local tweener = transform.DOAnchorPos(transform, Vector2.New(endX, endY), duration, true);
  tweener:SetUpdate(true);
  if startTime ~= nil then
    tweener:SetDelay(startTime);
  end

  if func ~= nil then
    tweener:OnComplete(func)
  end
end

function this.GetDropdown(go, name,label,onSelect)
  local button=go.transform:Find(name)
  local text=this.GetText(button,"Text");
  local obj={text=text,onSelect=onSelect};
  function obj.init(data,key,def)
    obj.data=data;
    obj.key=key;
    obj.label=label;
    this.AddClickListener(button,nil,function()
      GameUI.ShowWindow("ui/Dropdown",obj);
    end);
    for key, var in pairs(data) do
      for k, v in pairs(def) do
        if var[k]==v then
          obj.text.text=var[obj.key];
          obj.value=var;
          return;
        end
      end
    end
  end
  return obj
end

function this.GetInputField(go, name)
  local inputField = this.GetComponent(typeof(UnityEngine.UI.InputField), go, name)
  return inputField;
end

function this.GetText(go, name)
  local text = this.GetComponent(typeof(UnityEngine.UI.Text), go, name)
  return text
end
function this.GetImage(go, name)
  local image = this.GetComponent(typeof(UnityEngine.UI.Image), go, name)
  return image
end

function this.GetButton(go, name)
  local button = this.GetComponent(typeof(UnityEngine.UI.Button), go, name)
  return button
end

function this.GetToggle(go, name)
  local toggle = this.GetComponent(typeof(UnityEngine.UI.Toggle), go, name)
  return toggle
end

function this.GetToggleGroup(go, name)
  local tg = this.GetComponent(typeof(UnityEngine.UI.ToggleGroup), go, name)
  return tg
end

function this.GetComponent(componentType, go, name)
  local component = nil
  if name == nil or #tostring(name) == 0 then
    component = go.transform:GetComponent(componentType)
    if tolua.isnull(component) then
      print(go.name,go.transform);
      component = go.gameObject:AddComponent(componentType)
    end
  else
    component = go.transform:Find(name):GetComponent(componentType)
    if tolua.isnull(component) then
      component = go.transform:Find(name).gameObject:AddComponent(componentType)

    end
  end

  return component
end

function this.ClearAllChild(transform)
  while transform.childCount > 0 do
    UnityEngine.GameObject.DestroyImmediate(transform:GetChild(0).gameObject);
  end
  transform:DetachChildren();

end

function this.FormGameObject(parent, path, count)
  local table = { }
  for i = 0, count - 1 do
    table[i] = Game.Loader.Instance:CreateGameObject(parent.transform, path);
  end
  return table;
end


function this.AddClickListener(go, name, func, param1, param2, param3, param4)
  local button = this.GetButton(go, name)
  button.onClick:RemoveAllListeners();
  button.onClick:AddListener( function()
    func(param1, param2, param3, param4)
  end )
end
