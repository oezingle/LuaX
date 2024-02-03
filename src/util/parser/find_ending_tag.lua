
local is_cancelled = require("src.util.parser.parse.is_cancelled")
local TokenStack = require("src.util.parser.TokenStack")

--- Find the number of chars from the start of children to the end of children
---@param text string
---@return integer
local function find_ending_tag(text)
    local depth = 1

    local tokenstack = TokenStack(text)
    tokenstack.requires_literal = true

    while depth >= 1 do
        local pos = tokenstack.pos

        if pos > #text then
            error("HTML end tag not found")
        end

        if tokenstack:is_empty() and not is_cancelled(text, pos) then
            local current = text:sub(pos, pos)

            -- io.stdout:write(current)

            if current == "<" then
                local next = text:sub(pos + 1, pos + 1)

                if next == "/" then
                    depth = depth - 1
                else
                    depth = depth + 1
                end
            end
        end

        tokenstack:run_once()
    end

    local pos = tokenstack.pos - 2

    return pos
end

return find_ending_tag