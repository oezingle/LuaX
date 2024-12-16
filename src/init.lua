#!/usr/bin/lua

local LuaXParser = require("src.util.parser.LuaXParser")

local _VERSION = "0.3.6-dev"

-- check if ... (provided by import) matches arg (provided by lua command line)
if table.pack(...)[1] ~= (arg or {})[1] then
    -- this file has been imported

    ---@class LuaX.Exported
    ---@field Renderer LuaX.Renderer
    ---@field Fragment LuaX.Component
    ---@field create_element fun(type: LuaX.Component, props: LuaX.Props): LuaX.ElementNode
    ---@field clone_element (fun(element: LuaX.ElementNode, props: LuaX.Props): LuaX.ElementNode) | (fun(element: LuaX.ElementNode[], props: LuaX.Props): LuaX.ElementNode[])
    -- TODO FIXME types for hooks here.
    ---@field use_state any
    ---@field use_effect any
    ---@field use_memo any
    ---@field use_ref any
    ---@field register fun() Register the LuaX loader

    local export = {
        Renderer       = require("src.util.Renderer"),
        Fragment       = require("src.components.Fragment"),
        create_element = require("src.create_element"),
        clone_element  = require("src.clone_element"),
        use_state      = require("src.hooks.use_state"),
        use_effect     = require("src.hooks.use_effect"),
        use_memo       = require("src.hooks.use_memo"),
        use_ref        = require("src.hooks.use_ref"),
        register       = require("src.util.parser.loader.register"),

        Parser = LuaXParser,
        transpile      = {
            ---@param path string
            from_path = function (path)
                return LuaXParser.from_file_path(path):transpile()
            end,
            ---@param content string
            ---@param source string?
            from_string = function (content, source)
                -- TODO FIXME does NOT work on inline LuaX
                return LuaXParser.from_file_content(content, source):transpile()
            end,
            inline = require("src.util.parser.inline")
        },

        __from_cli     = require("src.cmd.cmd"),
        
        _VERSION = _VERSION
    }

    setmetatable(export, {
        __call = function(table, tag)
            return table.transpile.inline(tag)
        end
    })

    if not LuaX or not next(LuaX) then
        ---@class LuaX : LuaX.Exported
        ---@field _hookstate LuaX.HookState
        LuaX = export
    end

    return export
else
    local cmd = require("src.cmd.cmd")

    cmd()
end
