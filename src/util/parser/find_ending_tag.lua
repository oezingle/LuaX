
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
            -- TODO FIXME change this error so hard
            error("LuaX Transpiler: Cannot find ending tag")
        end

        -- TODO TokenStack needs to silently account for tags - they cancel literals.
        -- TODO this means that most of my parser is broken. Big broken.
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