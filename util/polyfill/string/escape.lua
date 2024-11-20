
---@param text string
local function escape_pattern(text) return text:gsub("([^%w])","%%%1") end
return escape_pattern