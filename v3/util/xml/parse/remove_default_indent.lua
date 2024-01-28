
---@param doc string
---@return string
local function remove_default_indent (doc)
    local starts_with_newline = "^\n"
    
    while doc:match(starts_with_newline) do
        doc = doc:gsub(starts_with_newline, "")
    end

    -- match start of string, whitespace, and then XML < tag
    local default_indent = doc:match("^(%s*)%S")

    local sub = doc:gsub(default_indent, "")

    return sub
end

return remove_default_indent