---@generic T, Initial
---@param list T[]
---@param cb fun(previous: Initial, current_value: T, current_index: number, list: T[]): Initial | any
---@param initial Initial
local function list_reduce(list,cb,initial) local reduction=initial or list[1]
for i,value in ipairs(list) do reduction=cb(reduction,value,i,list) end
return reduction end
return list_reduce