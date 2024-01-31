local clean_text = require "src.util.xml.parse.clean_text"
local remove_comments = require "src.util.xml.parse.remove_comments"
local TokenStack      = require "src.util.xml.parse.TokenStack"

---@param value string
---@return LuaX.Language.Literal
local function create_literal (value)
    return {
        type = "literal",
        value = value
    }
end

--[[
    for every char
        if child of tag
            if not str:sub(1):match("^</")
            
            no-op

        if char is a <
            match %S+ (tag name)

            until >
                match props
            
                
            if last char is /
                no children
        else
            this is a literal
]]

---@param str string
-- ---@param indent string
-- ---@param depth integer?
---@return LuaX.Language.Node[]
local function parse_luax (str)
    local _, first_char = str:find("^%s*%S")

    if not first_char then
        return {}
    end

    local nodes = {}

    for i = first_char, #str do
        local c = str:sub(i,i)
    end

    return nodes
end

return parse_luax