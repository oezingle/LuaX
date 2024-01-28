

-- Get the indent of some given XML, assuming it is correctly formatted
local function get_indent (doc)
    local indent = doc:match("%S\n(%s*)%S")

    return indent or ""
end

return get_indent