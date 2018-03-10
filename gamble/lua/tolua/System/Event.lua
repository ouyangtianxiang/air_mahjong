local events={};
Event={
  AddEventListener=function(type,func)
    events[type]=func
  end,
  RemoveEventListener=function(type)
    events[type]=nil;
  end,
  DispatchEvent=function(type,...)
    local func=events[type];
    if func~=nil then
      func(...);
    end
  end
}
