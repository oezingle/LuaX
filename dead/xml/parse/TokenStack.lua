-- where were you when BracketBuffer died?

-- TODO this class is useless because of backslashes

local class = require("lib.30log")

---@class LuaX.TokenStack : Log.BaseFunctions
---@operator call:LuaX.TokenStack
local TokenStack = class("TokenStack")

-- TODO is [[ ]] covered?

local token_list = { "<", ">", "{", "}", "[", "]", "(", ")", "\"", "'" }

function TokenStack:init()
    self.list = ""

    self.tokens = {}
    for _, token in ipairs(token_list) do
        self.tokens[token] = true
    end
end

function TokenStack:is_empty()

end

---@param char "<" | ">" | "{" | "}" | "[" | "]" | "(" | ")" | "\"" | "'"
function TokenStack.get_opposite(char)
    return ({
        -- ["<"] = ">",
        [">"] = "<",

        ["{"] = "}",
        ["}"] = "{",

        ["["] = "]",
        ["]"] = "[",

        ["("] = ")",
        [")"] = "(",

        ["\""] = "\"",
        ["'"] = "'",
    })[char]
end

---@param char string
function TokenStack:add(char)
    if self:is_token(char) then
        local last_token = self.list:sub(-1)

        if self.get_opposite(char) == last_token then
            self.list = self.list:sub(1, -2)
        else
            self.list = self.list .. char
        end
    end
end

---@return string
function TokenStack:get()
    return self.list
end

---@param char string
function TokenStack:is_token(char)
    return self.tokens[char] or false
end

return TokenStack
