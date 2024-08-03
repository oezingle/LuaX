
-- TODO given some wise usage of get_indent, maybe this file doesn't need to exist?

---@param text string
---@param pos integer
---@return string
local function get_default_indent(text, pos)
    local subtext = text:sub(1, pos):match("\n([^\n]-)$") or ""

    local default_indent = subtext:match("^%s*")

    return default_indent or ""
end

return get_default_indent