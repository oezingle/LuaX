--- TODO move elements back, unless they have an extra whitespace compared to parent
---@param xml string
---@return string
local function xml_clean_input(xml)
    -- add newline to make sure indentation pattern matches beginning
    local subbed = "\n" .. (xml
        -- replace any newlines at the beginning of the block
        :gsub("^\n+", "")
        -- replace any newlines at the end of the block
        :gsub("\n+%s*$", ""))

    --[[
    local matches = {}
    local match_index = 1
    for space in subbed:gmatch("\n(%s*)") do
        io.stdout:write("|", space, "|", "\n")

        matches[match_index] =

        match_index = match_index + 1
    end
    ]]

    --[[
    local matches = {}
    local last_match = nil
    while true do
        local start_index = subbed:find("\n(%s*)", last_match)

        if not start_index then break end



        last_match = start_index + 1
    end
    ]]

    return subbed:sub(2)
end

return xml_clean_input
