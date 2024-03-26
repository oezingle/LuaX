
--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param text string
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

return escape_pattern