local class        = require("lib.30log")
local is_cancelled = require("src.util.parser.is_cancelled")
local TokenStack   = require("src.util.parser.TokenStack")

---@class LuaX.Language.Base_Node
---@field props table<string, string>
---@field type string

---@class LuaX.Language.Literal : LuaX.Language.Base_Node
---@field type "literal"
---@field value string

---@class LuaX.Language.Comment : LuaX.Language.Base_Node
---@field type "comment"
---@field value string

---@class LuaX.Language.Element : LuaX.Language.Base_Node
---@field type "element"
---@field name string
---@field children LuaX.Language.Node[]

---@alias LuaX.Language.Node LuaX.Language.Literal | LuaX.Language.Comment | LuaX.Language.Element


-- TODO FIXME skip_whitespace should be a helper function like is_cancelled
-- TODO break locals out into function files

---@class LuaX.Parser : Log.BaseFunctions
-- ---@field pos integer
---@field text string
---@field indent string
---@operator call:LuaX.Parser
local LuaXParser = class("LuaXParser")

function LuaXParser:init(text)
    -- self.pos = 1

    self.text = text
end

--[[
function LuaXParser:get_pos()
    return self.pos
end

---@param pos integer
function LuaXParser:set_pos(pos)
    self.pos = pos
end

---@param pos integer
function LuaXParser:change_pos(pos)
    self.pos = self.pos + pos
end
]]

--- Check if the char under the cursor is cancelled
--[[
function LuaXParser:is_cancelled()
    return is_cancelled(self.text, self.pos)
end
]]

---@param pos integer?
function LuaXParser:skip_whitespace(pos)
    local pos = pos or 1

    -- TODO for some reason i gotta use this while loop instead of using the length of a match of %s
    while self.text:sub(pos, pos):match("%s") do
        pos = pos + 1
    end

    return pos
end

local PROP_PARSE_MAX = 1000

---@param text string
---@param pos integer
---@return table<string, string> props, integer pos, boolean has_children
local function get_props(text, pos)
    -- fetch props
    local has_children = true

    local props = {}
    local loop_panic = 0
    while true do
        local props_and_more = text:sub(pos)

        local whitespaces = 1

        while props_and_more:sub(whitespaces, whitespaces):match("%s") do
            whitespaces = whitespaces + 1
        end
        pos = pos + whitespaces - 1

        props_and_more = props_and_more:sub(whitespaces)

        if props_and_more:match("^/>") then
            pos = pos + 2
            has_children = false

            break
        end

        if props_and_more:match("^>") then
            pos = pos + 1

            break
        end

        -- TODO FIXME doesn't match implicit props
        local prop_name = props_and_more:match("^(%S+)=")
        pos = pos + #prop_name + 1

        local tokenstack = TokenStack(text:sub(pos))

        tokenstack:run_once()
        tokenstack:run_until_empty()

        local prop_value = text:sub(pos, pos + tokenstack.pos - 2)

        pos = pos + tokenstack.pos - 1

        -- remove quotes
        if prop_value:match("^\".*\"$") then
            prop_value = prop_value:sub(2, -2)
        end

        props[prop_name] = prop_value

        if loop_panic >= PROP_PARSE_MAX then
            error("LOOP PANIC: loop got stuck while collecting props")
        end
        loop_panic = loop_panic + 1
    end

    return props, pos, has_children
end

--- Find the number of chars from the start of children to the end of children
---@param text string
---@return integer
local function find_ending_tag(text)
    local depth = 1

    local tokenstack = TokenStack(text)

    while depth >= 1 do
        local pos = tokenstack.pos

        if pos > #text then
            error("HTML end tag not found")
        end

        if tokenstack:is_empty() and not is_cancelled(text, pos) then
            local current = text:sub(pos, pos)

            --io.stdout:write(current)

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

--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param text string
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

--- Parse a tag
---@param pos integer
---@return LuaX.Language.Element element, integer pos
function LuaXParser:parse_tag(pos)
    local tag_and_more = self.text:sub(pos)

    ---@type string
    local tag_name
    if tag_and_more:match("^<>") then
        tag_name = "Fragment"

        pos = pos + 1
    else
        local tag_start, tag_end = tag_and_more:find("^<([^%s>]+)")
        if not tag_start or not tag_end then
            error("No LuaX tag found")
        end
        pos = pos + tag_end

        tag_name = tag_and_more:sub(tag_start + 1, tag_end)
    end

    local props, pos, has_children = get_props(self.text, pos)

    local children = {}

    if has_children then
        -- TODO this causes this function's performance to be O(2n) instead of O(n)
        local children_text_len = find_ending_tag(self.text:sub(pos))

        children = self:parse_string(pos, children_text_len)

        pos = pos + children_text_len

        -- Move cursor past end tag
        do
            pos = self:skip_whitespace(pos)

            local end_tag = self.text:sub(pos):match("^</%s*" .. escape_pattern(tag_name) .. "%s*>") or
                -- match fragment ends </>
                tag_name == "Fragment" and self.text:sub(pos):match("^</%s*>")

            if not end_tag then
                error("No end tag found")
            end

            pos = pos + #end_tag
        end
    end

    return {
        type = "element",
        name = tag_name,
        props = props,
        children = children,
    }, pos
end

---@param nodes LuaX.Language.Node[]
---@param value string
local function add_literal(nodes, value)
    if value:match("^%s*$") then
        return
    end

    ---@type LuaX.Language.Literal
    local node = {
        type = "literal",
        value = value
    }

    table.insert(nodes, node)
end

-- TODO FIXME re-add old indent features.

---@param start integer
---@param length integer
---@return LuaX.Language.Node[]
function LuaXParser:parse_string(start, length)
    local text = self.text:sub(start, start + length - 1)

    local nodes = {}

    local tokenstack = TokenStack(text)

    local pos = tokenstack.pos

    local last_literal_start = pos

    while pos <= #text do
        pos = tokenstack.pos

        if tokenstack:is_empty() and not is_cancelled(text, pos) then
            local current = text:sub(pos, pos)

            if current == "<" then
                -- move current text into a literal
                add_literal(nodes, text:sub(last_literal_start, pos - 1))

                local element, new_pos = self:parse_tag(start + pos - 1)

                table.insert(nodes, element)

                tokenstack.pos = new_pos

                last_literal_start = new_pos
            end
        end

        tokenstack:run_once()
    end

    add_literal(nodes, text:sub(last_literal_start, pos - 1))

    return nodes
end

return LuaXParser
