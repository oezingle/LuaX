local TokenStack = require("src.util.parser.TokenStack")

---@param slice string
local function remove_quotes(slice)
    local subbed = slice
        :gsub("[\"']$", "")
        :gsub("^[\"']", "")
        :gsub("^%[%[", "")
        :gsub("%]%]$", "")

    return subbed
end

---@param strings string[]
---@param slice string
---@param is_literal boolean
local function handle_slice(strings, slice, is_literal)
    if is_literal then
        slice = string.format("tostring(%s)", slice)
    else
        slice = string.format("%q", remove_quotes(slice))
    end

    table.insert(strings, slice)
end

---@param text string
---@return string
local function split_literals(text)
    local tokenstack = TokenStack(text)
    tokenstack.requires_literal = true

    local strings = {}

    local last_is_literal = false
    local last_start = 1

    while tokenstack.pos <= #text + 1 do
        tokenstack:run_once()

        local is_literal = not tokenstack:is_empty()

        if is_literal ~= last_is_literal then
            local slice = text:sub(last_start, tokenstack.pos - 2)

            handle_slice(strings, slice, not is_literal)

            last_start = tokenstack.pos

            last_is_literal = is_literal
        end
    end

    -- TODO can i assume this isn't a literal? seems like it!
    local slice = text:sub(last_start, tokenstack.pos - 2)
    handle_slice(strings, slice, false)

    return table.concat(strings, "..")
end

return split_literals
