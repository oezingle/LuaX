local class                 = require("lib.30log")
local is_cancelled          = require("src.util.parser.parse.is_cancelled")
local TokenStack            = require("src.util.parser.TokenStack")
local remove_default_indent = require("src.util.parser.parse.remove_default_indent")
local get_indent            = require("src.util.parser.parse.get_indent")
local clean_text            = require("src.util.parser.parse.clean_text")
local find_ending_tag       = require("src.util.parser.find_ending_tag")
local collect_locals        = require("src.util.parser.transpile.collect_locals")
local node_to_element       = require("src.util.parser.transpile.node_to_element")
local NativeElement         = require("src.util.NativeElement")
local warn_once             = require("src.util.warn_once")

local require_path          = (...)

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
---@field imports table<"fragment" | "luablock", boolean>
---@operator call:LuaX.Parser
local LuaXParser = class("LuaXParser")

LuaXParser.FRAGMENT_AUTO_IMPORT_NAME = "_LuaX_Fragment"
LuaXParser.LUA_BLOCK_AUTO_IMPORT_NAME = "_LuaX_Lua_Block"
LuaXParser.CREATE_ELEMENT_IMPORT_NAME = "_LuaX_create_element"


function LuaXParser:init(text)
    -- self.pos = 1

    -- TODO this here has issues!
    local unindented = remove_default_indent(text)

    self.indent = get_indent(unindented)

    self.imports = {}

    self.text = unindented
end

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

-- this implementation is kinda grimey.
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

        -- skip whitespaces
        local whitespaces = 1
        while props_and_more:sub(whitespaces, whitespaces):match("%s") do
            whitespaces = whitespaces + 1
        end
        pos = pos + whitespaces - 1

        props_and_more = props_and_more:sub(whitespaces)

        -- check for early return
        if props_and_more:match("^/>") then
            pos = pos + 2
            has_children = false

            break
        end
        if props_and_more:match("^>") then
            pos = pos + 1

            break
        end

        local implicit_prop = props_and_more:match("^([^%s=]+)%s")

        if implicit_prop then
            -- move forward the length of that prop
            pos = pos + #implicit_prop

            props[implicit_prop] = "{true}"
        else
            local prop_name = props_and_more:match("^(%S+)=")
            -- move forward the length of that prop and "="
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
        end

        if loop_panic >= PROP_PARSE_MAX then
            error("LOOP PANIC: loop got stuck while collecting props")
        end
        loop_panic = loop_panic + 1
    end

    return props, pos, has_children
end

--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param text string
local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

--- Parse a tag
---@param pos integer
---@param depth integer?
---@return LuaX.Language.Element element, integer pos
function LuaXParser:parse_tag(pos, depth)
    depth = depth or 0

    local tag_and_more = self.text:sub(pos)

    ---@type string
    local tag_name
    if tag_and_more:match("^<>") then
        -- TODO FIXME Fragment here should be _LuaX_Fragment or something
        tag_name = self.FRAGMENT_AUTO_IMPORT_NAME

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

        children = self:parse_string(pos, children_text_len, depth + 1)

        pos = pos + children_text_len

        -- Move cursor past end tag
        do
            pos = self:skip_whitespace(pos)

            local tag_is_auto_fragment = tag_name == self.FRAGMENT_AUTO_IMPORT_NAME

            self.imports.fragment = tag_is_auto_fragment or self.imports.fragment

            local end_tag = self.text:sub(pos):match("^</%s*" .. escape_pattern(tag_name) .. "%s*>") or
                -- match fragment ends </>
                tag_name == self.FRAGMENT_AUTO_IMPORT_NAME and self.text:sub(pos):match("^</%s*>")

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
---@param slice string
---@param is_luablock boolean
function LuaXParser:luablock_handle_slice(nodes, slice, is_luablock)
    if is_luablock then
        self.imports.luablock = true

        ---@type LuaX.Language.Element
        local element = {
            type = "element",
            name = LuaXParser.LUA_BLOCK_AUTO_IMPORT_NAME,
            children = {},
            props = { value = "{" .. slice .. "}" }
        }

        table.insert(nodes, element)
    else
        if #slice == 0 then
            return
        end

        table.insert(nodes, {
            type = "literal",
            value = slice
        })
    end
end

--- Handle literal values, splitting into LuaBlocks if necessary.
---@param nodes LuaX.Language.Node[]
---@param text string
function LuaXParser:split_luablocks(nodes, text)
    local tokenstack = TokenStack(text)
    tokenstack.requires_literal = true

    local last_is_literal = false
    local last_start = 1

    while tokenstack.pos <= #text + 1 do
        tokenstack:run_once()

        local is_literal = not tokenstack:is_empty()

        if is_literal ~= last_is_literal then
            local slice = text:sub(last_start, tokenstack.pos - 2)

            self:luablock_handle_slice(nodes, slice, not is_literal)

            last_start = tokenstack.pos

            last_is_literal = is_literal
        end
    end

    -- TODO can i assume this isn't a literal? seems like it!
    local slice = text:sub(last_start, tokenstack.pos - 2)
    self:luablock_handle_slice(nodes, slice, false)
end

---@param nodes LuaX.Language.Node[]
---@param value string
---@param indent string
---@param depth integer
function LuaXParser:add_literal(nodes, value, indent, depth)
    if value:match("^%s*$") then
        return
    end

    local cleaned = clean_text(value, indent, depth)

    self:split_luablocks(nodes, cleaned)
end

--- TODO FIXME fails with literal in here.
---@param start integer
---@param length integer
---@param depth integer?
---@return LuaX.Language.Node[] nodes, integer pos
function LuaXParser:parse_string(start, length, depth)
    depth = depth or 0

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
                self:add_literal(nodes, text:sub(last_literal_start, pos - 1), self.indent, depth)

                local element, new_pos = self:parse_tag(start + pos - 1, depth)

                table.insert(nodes, element)

                tokenstack.pos = new_pos

                last_literal_start = new_pos
            end
        end

        tokenstack:run_once()
    end

    self:add_literal(nodes, text:sub(last_literal_start, pos - 1), self.indent, depth)

    -- TODO return pos
    return nodes, pos
end

-- TODO isn't used in parse_file(). more the fault of my shitty parse_file implementation
---@return LuaX.Language.Node
function LuaXParser:parse_all()
    local start = self:skip_whitespace()

    -- TODO does this work properly?
    local nodes = self:parse_string(start, #self.text - start + 1, 0)

    if #nodes > 1 then
        error("LuaX must have one parent element")
    end

    return nodes[1]
end

---@param str string
---@param replacement string
---@param startpos integer
---@param endpos integer
local function insert_at(str, replacement, startpos, endpos)
    return str:sub(1, startpos - 1) .. replacement .. str:sub(endpos)
end

-- TODO don't love this approach but it might be the best we have
local luax_root = require_path:gsub("%.util%.parser%.LuaXParser$", "")

function LuaXParser.collect_global_components()
    -- Check if we can safely use global mode for component names
    local globals = {}

    ---@type LuaX.NativeElement[]
    local subclasses_of_native_element = NativeElement:subclasses()

    if #subclasses_of_native_element > 0 then
        for _, NativeElementImplementation in ipairs(subclasses_of_native_element) do
            -- saves some memory to do this here, as every string from this class in globals will be the same
            local implementation_name = tostring(NativeElementImplementation)

            if not NativeElementImplementation.components then
                warn_once(string.format(
                    "LuaX Parser: NativeElement subclass %s does not have a component registry list - defaulting to local variable lookup",
                    implementation_name
                ))

                return nil
            end

            for _, component_name in ipairs(NativeElementImplementation.components) do
                if globals[component_name] then
                    warn_once(string.format(
                        "LuaX Parser: Multiple NativeElement implementations implement the element '%s'. Ignoring from %s, using existing from %s",
                        component_name, implementation_name, globals[component_name]
                    ))
                end

                -- so that we can look up which implementation uses this
                globals[component_name] = implementation_name
            end
        end
    else
        warn_once(
            "LuaX Parser: NativeElement has not been extended yet - defaulting to local variable lookup" .. '\n' ..
            "to use global mode, import your NativeElement implementation before any LuaX files"
        )

        return nil
    end

    return globals
end

-- TODO match calls to LuaX([[ ...tag... ]])
-- TODO needs to match function call ie render(<aApp />)
-- TODO needs to match no child
-- TODO needs to match array element { <App> }
-- TODO maybe iterate over lua keywords? ie return, break, end, etc etc etc. any other token is a comparison
function LuaXParser:parse_file()
    -- preprocess - look for FRAGMENT_AUTO_IMPORT_NAME, and add it to imports
    -- self.text = "local create_element = require(\"\")" .. "\n" .. "" .. "\n"

    self.text =
        string.format("local %s = require(%q).create_element", self.CREATE_ELEMENT_IMPORT_NAME, luax_root) ..
        "\n" ..
        self.text

    -- Check if we can safely use global mode for component names
    local globals = LuaXParser.collect_global_components()


    local locals = collect_locals(self.text)

    repeat
        local _, multiline_match = self.text:find("%(%s*<")
        local _, assign_match = self.text:find("=%s*<")
        local _, return_match = self.text:find("return%s+<")

        local match = multiline_match or assign_match or return_match

        if match == nil then
            break
        end

        local _, endpos = self:parse_tag(match)

        -- TODO this is super wasteful ( ok for now - wastes time but transpile is ok )
        -- new instance here to fix whitespace issues (this is an awful fix!)
        local parser = LuaXParser(self.text:sub(match, endpos))
        local parsed = parser:parse_tag(1)

        self.imports.fragment = parser.imports.fragment or self.imports.fragment
        self.imports.luablock = parser.imports.luablock or self.imports.luablock

        if self.imports.fragment then
            locals[self.FRAGMENT_AUTO_IMPORT_NAME] = true
        end

        if self.imports.luablock then
            locals[self.LUA_BLOCK_AUTO_IMPORT_NAME] = true
        end

        local transpiled = globals and
            node_to_element(parsed, globals, "global", self.CREATE_ELEMENT_IMPORT_NAME) or
            node_to_element(parsed, locals, "local", self.CREATE_ELEMENT_IMPORT_NAME)

        --print(self.text:sub(1, match - 1) .. self.text:sub(endpos))
        self.text = insert_at(self.text, transpiled, match, endpos)
    until false

    if self.imports.fragment then
        self.text =
            string.format("local %s = require(%q).Fragment", self.FRAGMENT_AUTO_IMPORT_NAME, luax_root) ..
            "\n" ..
            self.text
    end

    if self.imports.luablock then
        self.text =
            string.format("local %s = require(%q).LuaBlock", self.LUA_BLOCK_AUTO_IMPORT_NAME, luax_root) ..
            "\n" ..
            self.text
    end

    return self.text
end

return LuaXParser
