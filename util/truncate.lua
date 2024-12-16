---@param str string
---@param length integer?
---@return string
local function truncate(str,length) local length=length or 50
if str:match"\n" or  # str >= length then local up_to_line=str:match"^(.-)\n" or str
up_to_line=up_to_line:sub(1,length - 3)
return up_to_line .. "..." else 
return str end end
return truncate