---@generic T
---@param list T[]
---@param fn fun(item: T): any
---@return T[]
local function list_filter(list,fn) local ret={}
for _,item in ipairs(list) do local filter_passed=fn(item)
if filter_passed then table.insert(ret,item) end end
return ret end
return list_filter