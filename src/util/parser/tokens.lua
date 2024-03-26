
---@nospec too simple to need a test. just a list

local keywords = require("src.util.parser.keywords")

-- valid tokens that precede LuaX tags
local tokens = {
    -- https://hackage.haskell.org/package/language-lua-0.11.0.1/docs/Language-Lua-Token.html
    "{",
    "[",
    "(",
    ",",
    "=",
}

for _, keyword in ipairs(keywords) do
    table.insert(tokens, keyword)
end

return tokens