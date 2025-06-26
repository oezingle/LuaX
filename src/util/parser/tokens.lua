---@nospec too simple to need a test. just a list

local keywords = require("src.util.parser.keywords")
local escape   = require("src.util.polyfill.string.escape")

---@class LuaX.Parser.V2.Token
---@field pattern string
---@field replacer string
---@field end_pattern string
---@field end_replacer string

---@param token any
---@return LuaX.Parser.V2.Token
local function ensure_token(token)
    token.replacer = token.replacer or ""
    token.end_pattern = token.end_pattern or ""
    token.end_replacer = token.end_replacer or ""

    return token
end

-- Generate a list of valid tokens that precede LuaX tags
local function bake_tokens()
    ---@type any[]
    local tokens = {
        {
            -- Capture here to keep whitespace & allow indent features to work nicely.
            pattern = "return%s*%[(=*)%[(%s*)<",
            replacer = "return%2",
            end_pattern = "%s*%]%1%]",
            end_replacer = ""
        },
        {
            pattern = "LuaX%s*%(%[(=*)%[(%s*)<",
            replacer = "%2",
            end_pattern = "%s*%]%1%]%s*%)",
            end_replacer = ""
        }
    }

    for _, keyword in ipairs(keywords) do
        table.insert(tokens, {
            pattern = "([%s%(%)%[%]])" .. keyword .. "(%s*)<",
            replacer = "%1" .. keyword .. "%2"
        })
        
        table.insert(tokens, {
            pattern = "^" .. keyword .. "(%s*)<",
            replacer = keyword .. "%1"
        })
    end

    -- https://hackage.haskell.org/package/language-lua-0.11.0.1/docs/Language-Lua-Token.html
    for token, match in pairs({
        ["{"] = "}",
        ["["] = "]",
        ["("] = ")",
        [","] = "",
        ["="] = "",
    }) do
        table.insert(tokens, {
            pattern = escape(token) .. "%s*<",
            replacer = token,
            -- Add end_pattern match for matching ending brackets
            end_pattern = match and ("%s*" .. escape(match)),
            end_replacer = match
        })
    end

    ---@type LuaX.Parser.V2.Token[]
    local ret = {}

    for _, token in ipairs(tokens) do
        table.insert(ret, ensure_token(token))
    end

    return ret
end

return bake_tokens()
