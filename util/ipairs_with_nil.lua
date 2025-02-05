local function ipairs_with_nil(list,length) local max=length or  # list
local index=0
return function () if index == max then return nil end
index=index + 1
local item=list[index]
return index,item end end
return ipairs_with_nil