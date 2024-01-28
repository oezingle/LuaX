
---@param text string
---@param indent string
---@param depth integer
---@return string
local function clean_text(text, indent, depth)
    text = "\n" .. text

    -- remove indentations up to depth
    local indent_pattern = "\n" .. string.rep(indent, depth)

    text = text
        :gsub(indent_pattern, "\n")
        -- remove newline(s) before content (one or two)
        :gsub("^\n", "")
        --:gsub("^\n", "")
        -- remove newline after content (just one) and unrelated whitespace
        :gsub("\n%s-$", "")

    return text
end

return clean_text