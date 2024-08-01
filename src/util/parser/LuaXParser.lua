local class           = require("lib.30log")
local escape          = require("src.util.polyfill.string.escape")
local TokenStack      = require("src.util.parser.TokenStack")
local node_to_element = require("src.util.parser.transpile.node_to_element")
local NativeElement   = require("src.util.NativeElement")
local warn_once       = require("src.util.warn_once")
local get_indent      = require("src.util.parser.parse.get_indent")
local tokens          = require("src.util.parser.tokens")
local collect_locals  = require("src.util.parser.transpile.collect_locals")

local require_path

do
    if table.pack(...)[1] == (arg or {})[1] then
        error("LuaXParser must be imported")
    end

    require_path = (...)
end

---@class LuaX.Language.Node.Literal
---@field type "literal"
---@field value string

---@class LuaX.Language.Node.Element
---@field type "element"
---@field name string
---@field props LuaX.Props
---@field children LuaX.Language.Node[]

---@alias LuaX.Language.Node LuaX.Language.Node.Literal | LuaX.Language.Node.Element

---@alias LuaX.Parser.V2.Import { name: string, export: string }

---@class LuaX.Parser.V2 : Log.BaseFunctions
---@field imported { ["Fragment"]: boolean }
---@field indent string
---@field default_indent string
---@field verbose boolean?
-- ---@field imports table<"auto"|"required", table<string, LuaXParser.V2.Import>>
---@operator call: LuaX.Parser.V2
local LuaXParser = class("LuaXParser (V2)")

function LuaXParser:init()
    self.imported = {
        ["Fragment"] = false,
    }

    self.indent = ""

    self.default_indent = ""
end

LuaXParser.imports = {
    auto = {
        FRAGMENT = {
            name = "_LuaX_Fragment",
            export = "Fragment",
        },
        IS_COMPILED = {
            name = "_LuaX_is_compiled",
        }
    },
    required = {
        CREATE_ELEMENT = {
            name = "_LuaX_create_element",
            export = "create_element"
        }
    }
}

---@param text string
---@return table<string, string>, integer
function LuaXParser:parse_props(text)
    if self.verbose then
        print("parse_props", text)
    end

    local pos = 1

    local props = {}

    while not text:match("^%s*>", pos) and not text:match("^%s*/%s*>", pos) do
        -- remove whitespace
        pos = pos + #(text:match("^%s*", pos) or "")

        local prop = text:match("^[^>%s]+", pos)

        if prop:match("^.-=") then
            -- explicit prop
            local prop_name = prop:match("^(.-)=")

            local prop_value_start = pos + #prop_name + 1

            local tokenstack = TokenStack(text)

            tokenstack:set_pos(prop_value_start)

            tokenstack:run_once()

            tokenstack:run_until_empty()

            -- TODO skip whitespace for value
            local prop_value = text:sub(prop_value_start, tokenstack:get_pos() - 1)

            local prop_value_clean = prop_value
                :gsub("^[\"'](.*)[\"']$", "%1") -- remove block quotes
            --:gsub("^[\"'](%{.*%})[\"']$", "%1") -- remove quotes around {} blocks, keeping {}

            -- print(prop_value)

            -- clean up whitespace around
            local prop_name_clean = prop_name:gsub("^%s*(.-)%s*$", "%1")

            props[prop_name_clean] = prop_value_clean

            pos = prop_value_start + #prop_value
        else
            -- implicit prop
            props[prop] = true

            pos = pos + #prop
        end
    end

    return props, pos
end

--- Grandmothered in from old Parser
---@param nodes LuaX.Language.Node[]
---@param slice string
---@param is_luablock boolean
function LuaXParser:handle_literal_slice(nodes, slice, is_luablock)
    if self.verbose then
        print("handle_literal_slice", slice)
    end

    if #slice == 0 then
        return
    end

    -- io.stdout:write("inserting literal |", slice, "|\n")

    if is_luablock then
        table.insert(nodes, slice)
    else
        table.insert(nodes, {
            type = "literal",
            value = slice
        })
    end
end

--- Handle literal values, splitting into blocks of lua if necessary.
---@param nodes LuaX.Language.Node[]
---@param text string
---@param depth integer
---@return integer
function LuaXParser:parse_literal(nodes, text, depth)
    if self.verbose then
        print("parse_literal", text)
    end

    local tokenstack = TokenStack(text)
    tokenstack.requires_literal = true

    local last_was_luablock = false

    -- TODO if tokenstack's first run_once() results in a literal, then last_start needs to be += 1
    local last_start = tokenstack:get_pos()

    -- TODO FIXME this is a terrible way to fix this edge case. see above
    if text:sub(1, 1) == "{" then
        last_start = last_start + 1
    end

    ---@type { value: string, is_luablock: boolean }[]
    local slices = {}

    -- TODO is_cancelled here would be nice.
    -- todo this loop is a little bit shakey but it seems to get the job done.
    -- TODO rewrite - last_start issue.
    while not (tokenstack:get_current() == "<" and tokenstack:is_empty()) do
        tokenstack:run_once()

        local was_luablock = tokenstack:is_empty()

        if was_luablock ~= last_was_luablock then
            local slice = text:sub(last_start, tokenstack:get_pos() - 2)

            table.insert(slices, {
                value = slice,
                is_luablock = was_luablock
            })

            if self.verbose then
                print("insert slice", slice, was_luablock)
            end

            last_start = tokenstack:get_pos()

            last_was_luablock = was_luablock
        end
    end

    -- TODO can i assume this isn't a literal? seems like it!
    local slice = text:sub(last_start, tokenstack:get_pos() - 2)
    table.insert(slices, {
        value = slice,
        is_luablock = false
    })

    -- clean text
    local indent_pattern = self.default_indent .. string.rep(self.indent, depth)

    for _, slice in ipairs(slices) do
        -- TODO FIXME clean comments here.

        slice.value = slice.value
            :gsub("\n" .. indent_pattern, "\n")
            :gsub("^" .. indent_pattern, "")
    end

    -- clean up empty slices
    for index = #slices, 1, -1 do
        local slice = slices[index]

        if #slice.value == 0 then
            table.remove(slices, index)
        end
    end

    slices[1].value = slices[1].value:gsub("^\n", "")
    slices[#slices].value = slices[#slices].value
        :gsub("\n%s-$", "")

    -- print("\nslices")
    -- for _, slice in ipairs(slices) do
    --     print(slice.value:gsub("\n", "n"))
    -- end

    -- create nodes
    for _, slice in ipairs(slices) do
        self:handle_literal_slice(nodes, slice.value, slice.is_luablock)
    end

    return tokenstack:get_pos()
end

--[[
    parse_text -> parse multiple elements and/or literals
]]
-- TODO match { ...props} ?
---@param text string
---@param depth integer
---@return LuaX.Language.Node[], integer
function LuaXParser:parse_text(text, depth)
    if self.verbose then
        print("parse_text", text)
    end

    local pos = 1

    local nodes = {}

    while not text:match("^%s*</", pos) do
        local _, tag_start = text:find("^%s*<", pos)

        if tag_start then
            local subtext = text:sub(tag_start)

            local node, node_end = self:parse_tag(subtext, depth)

            table.insert(nodes, node)

            pos = tag_start + node_end
        else
            local subtext = text:sub(pos)

            local literal_pos = self:parse_literal(nodes, subtext, depth)

            pos = pos + literal_pos - 1
        end
    end

    pos = pos + #text:match("^%s*", pos)

    return nodes, pos
end

---@param message string
---@param tag_name string
---@param depth number
local function tag_error(message, tag_name, depth)
    local str = string.format("LuaXParser - Tag '%s' at depth %d: %s", tag_name, depth, message)

    return str
end

---@param text string
---@param props_end integer
---@param tag_name string
---@param depth integer
function LuaXParser:parse_children(text, props_end, tag_name, depth)
    if self.verbose then
        print("parse_children", text:sub(props_end))
    end

    local _, nochild = text:find("^%s*/%s*>", props_end)

    if nochild ~= nil then
        return {}, nochild
    end

    -- TODO need to account for this. somehow
    local _, children_start = text:find("^%s*>", props_end)

    if not children_start then
        error(tag_error("props appear to not end", tag_name, depth))
    end

    local childrentext = text:sub(children_start + 1)

    local children, children_end = self:parse_text(childrentext, depth + 1)

    local _, tag_end = childrentext:find("^<%s*/%s*" .. escape(tag_name) .. "%s*>", children_end)

    if not tag_end then
        error(tag_error("cannot find element end", tag_name, depth))
    end

    -- TODO appears this math can be wrong sometimes.
    return children, children_start + tag_end
end

--- Parse a Node from given text, returning the length of that node's text.
---@param text string
---@param depth integer
---@return LuaX.Language.Node, integer
function LuaXParser:parse_tag(text, depth)
    if self.verbose then
        print("parse_tag", text)
    end

    local fragment_match = text:match("^<%s*>")

    if fragment_match then
        self.imported.Fragment = true

        local subtext = text:sub(1 + #fragment_match)

        local children, children_end = self:parse_text(subtext, depth + 1)

        ---@type LuaX.Language.Node
        local node = {
            type = "element",
            name = self.imports.auto.FRAGMENT.name,
            props = {},
            children = children,
        }

        local _, tag_end = subtext:find("^<%s*/%s*>", children_end)

        if not tag_end then
            error(tag_error("cannot find end", "Fragment", depth))
        end

        return node, #fragment_match + tag_end
    end

    local _, tag_name_start = text:find("^<%s*")

    local tag_name = text:match("([^%s/>]+)", tag_name_start + 1)

    if not tag_name then
        error(tag_error("Cannot find tag name", "(unknown)", depth))
    end

    local tag_name_length = tag_name_start + #tag_name + 1

    local proptext = text:sub(tag_name_length)

    local props, props_end = self:parse_props(proptext)

    local children, tag_end = self:parse_children(proptext, props_end, tag_name, depth)

    ---@type LuaX.Language.Node
    local node = {
        type = "element",
        name = tag_name,
        props = props,
        children = children
    }

    return node, tag_name_length + tag_end - 1
end

---@param text string
---@param pos integer
function LuaXParser:set_default_indent(text, pos)
    local subtext = text:sub(1, pos)

    local default_indent = subtext:match("^(%s*)<$") or subtext:match("\n(%s*)<$")

    self.default_indent = default_indent or ""
end

---@param text string
---@param init integer?
---@param components table<string, true>
---@param components_mode "global" | "local"
function LuaXParser:transpile_tag(text, init, components, components_mode)
    if self.verbose then
        print("transpile_tag", text)
    end

    init = init or 1

    self:set_default_indent(text, init)

    local subtext = text:sub(init)

    -- Get the indent of the tag, then remove the default indent.
    self.indent = get_indent(subtext)
        :gsub("^" .. self.default_indent, "")

    local node, end_pos = self:parse_tag(subtext, 0)

    local transpiled = node_to_element(node, components, components_mode, self.imports.required.CREATE_ELEMENT.name)

    local text_transpiled = text:sub(1, init - 1) .. transpiled .. text:sub(init + end_pos)

    return text_transpiled, #transpiled
end

-- TODO cache this work. duh!
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

---@param text string
---@param import LuaX.Parser.V2.Import
---@return string
function LuaXParser:add_import(text, import)
    local luax_root = require_path
        -- TODO FIXME this code is location dependent
        :gsub("%.util%.parser%.LuaXParser$", "")

    local fmt = "local %s = require(%q)[%q]"

    local require_string = string.format(fmt, import.name, luax_root, import.export)

    return require_string .. "\n" .. text
end

---@param text any
---@param components any
---@param components_mode any
---@return boolean continue, string text
function LuaXParser:replace_once(text, components, components_mode)
    for _, info in ipairs(tokens) do
        local pattern = info.pattern

        -- Find from back to front
        local block_start = text:find(pattern .. ".-")

        local _, luax_start = text:find(pattern, block_start)

        if luax_start then
            -- remove call to LuaX
            local text = text:sub(1, block_start - 1) .. info.replacer .. text:sub(luax_start)

            local new_luax_start = block_start + #info.replacer
            local text, transpiled_length = self:transpile_tag(text, new_luax_start, components, components_mode)

            local luax_end = new_luax_start + transpiled_length

            local _, call_end = text:find(info.end_pattern, luax_end)
            if not call_end then
                error("LuaX Parser: Unable to locate end of block")
            end
            text = text:sub(1, luax_end) .. info.end_replacer .. text:sub(call_end + 1)

            return true, text
        end
    end

    return false, text
end

--- transpile some arbitrary text
---@param text string
---@param components table<string, true>
---@param components_mode "global" | "local"
function LuaXParser:transpile_text(text, components, components_mode)
    repeat
        local continue

        continue, text = self:replace_once(text, components, components_mode)
    until not continue

    return text
end

---@param text string
function LuaXParser:transpile_file(text)
    if self.verbose then
        print("transpile_file", text)
    end

    local globals = self.collect_global_components()

    local locals = collect_locals(text)
    locals[self.imports.auto.FRAGMENT.name] = true

    text = globals and
        self:transpile_text(text, globals, "global") or
        self:transpile_text(text, locals, "local")

    text = self:add_import(text, self.imports.required.CREATE_ELEMENT)

    -- See src/util/parser/inline/decorator.lua:40
    local compilation_string = string.format("local %s = true", self.imports.auto.IS_COMPILED.name)
    text = compilation_string .. "\n" .. text

    if self.imported.Fragment then
        text = self:add_import(text, self.imports.auto.FRAGMENT)
    end

    return text
end

return LuaXParser
