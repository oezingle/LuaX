local class = require("lib.30log")
local is_cancelled = require("src.util.parser.parse.is_cancelled")

---@return table<string, true>
local function get_tokens()
    local tokens = {
        "{",
        "}",
        "[",
        "]",
        "(",
        ")",
        "'",
        "\"",
    }

    local out = {}
    for _, token in ipairs(tokens) do
        out[token] = true
    end

    return out
end

---@class LuaX.TokenStack : Log.BaseFunctions
---@field pos integer
---@field text string
---@field tokens table<string, true>
---@field requires_literal boolean
---@operator call:LuaX.TokenStack
local TokenStack = class("TokenStack")

---@param text string
function TokenStack:init(text)
    self:set_pos(1)

    self.stack = ""

    self.text = text

    self.tokens = get_tokens()

    self:set_requires_literal(false)
end

---@param requires_literal boolean
---@return self
function TokenStack:set_requires_literal(requires_literal)
    self.requires_literal = requires_literal

    return self
end

---@param pos integer
---@return self
function TokenStack:set_pos(pos)
    self.pos = pos

    return self
end

function TokenStack:get_pos()
    return self.pos
end

---- Check if the current character is cancelled by backslashes
function TokenStack:is_cancelled()
    return is_cancelled(self.text, self.pos)
end

--- Check if the current character is a token
---@return boolean
function TokenStack:is_token()
    if self:is_cancelled() then
        return false
    end

    local char = self.text:sub(self.pos, self.pos)

    return self.tokens[char] or false
end

---@param char "<" | ">" | "{" | "}" | "[" | "]" | "(" | ")" | "\"" | "'"
function TokenStack.get_opposite(char)
    return ({
        ["<"] = ">",
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

function TokenStack:is_empty()
    return #self.stack == 0
end

--[[
function TokenStack:is_in_literal()
    return self.text:match("{")
end

function TokenStack:is_in_string()
    return self.text:match("['\"]") or self.text:match("%[%[")
end
]]

-- collect char if:
--      first char(s) is string (LuaXParser props collection)
--      first char(s) is literal (LuaXParser props collection / literal parsing)

--- Advance one character
---@return self
function TokenStack:run_once()
    local char = self.text:sub(self.pos, self.pos)

    if self:is_token() then
        local last_token = self.stack:sub(-1)

        if self.get_opposite(char) == last_token then
            self.stack = self.stack:sub(1, -2)
        else
            if not self.stack:match("[\"']$") and not self.stack:match("%[%[$") then
                if not self.requires_literal or self.stack:match("^{") or char == "{" then
                    self.stack = self.stack .. char
                end
            end
        end
    end

    self:safety_check()

    self.pos = self.pos + 1

    return self
end

function TokenStack:get_current()
    return self.text:sub(self.pos, self.pos)
end

function TokenStack:safety_check()
    if self.pos > #self.text + 1 then
        error("TokenStack out of text bounds")
    end
end

---@return self
function TokenStack:run_until_empty()
    while not self:is_empty() do
        self:run_once()

        self:safety_check()
    end

    return self
end

return TokenStack
