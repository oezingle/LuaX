
--- Check if the character at pos of text is cancelled
---@param text string
---@param pos integer
---@return boolean
local function is_cancelled(text, pos)
    local pos = pos - 1

    local char = text:sub(pos, pos)

    local cancelled = false

    while char == "\\" do
        cancelled = not cancelled       
        
        pos = pos - 1

        char = text:sub(pos, pos)
    end

    return cancelled
end

return is_cancelled