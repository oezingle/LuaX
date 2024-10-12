#!/usr/bin/lua

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

        __from_cli = require("src.cmd.cmd")
    }

    setmetatable(export, {
        __call = function(_, tag)
            return require("src.util.parser.inline")(tag)
        end
    })

    if not LuaX then
        ---@class LuaX : LuaX.Exported
        ---@field _hookstate LuaX.HookState
        LuaX = export
    end

    return export
else
    local cmd = require("src.cmd.cmd")

    cmd()
end
