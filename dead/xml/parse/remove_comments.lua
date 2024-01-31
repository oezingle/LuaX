---@param str string
---@return string
local function remove_comments(str)
    str = ("\n" .. str .. "\n")
        -- remove (newline) comment (newline), replacing with just newline
        :gsub("\n%s*%-%-.-\n", "\n")
        -- remove comment at end of line
        :gsub("%s*%-%-.-\n", "\n")
        -- remove comment at end of string
        :gsub("%-%-%[%[.-%]%]", "")
        -- remove whitespace at front of code
        :gsub("^%s*", "")
        -- remove whitespace at end of code
        :gsub("%s*$", "")

    return str
end

return remove_comments
