#!/usr/bin/lua

-- local use_state      = require("src.hooks.use_state")
-- local use_effect     = require("src.hooks.use_effect")
-- local use_memo       = require("src.hooks.use_memo")

-- check if ... (provided by import) matches arg (provided by lua command line)
if table.pack(...)[1] ~= (arg or {})[1] then
    -- this file has been imported

    -- TODO no way in hell this optimization gets bundled right
    local imports = {
        Renderer = "src.util.Renderer",
        Fragment = "src.components.Fragment",
        create_element = "src.create_element",
        clone_element = "src.clone_element",
        use_state = "src.hooks.use_state",
        use_effect = "src.hooks.use_effect",
        use_memo = "src.hooks.use_memo",
        use_ref = "src.hooks.use_ref",
        register = "src.util.parser.loader.register"
    }

    ---@class LuaX.Import
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
    local export = {}

    setmetatable(export, {
        __index = function(_, key)
            local src = imports[key]

            local mod = require(src)

            return mod
        end,
        __call = function(_, tag)
            return require("src.util.parser.inline")(tag)
        end,
        __pairs = function(_)
            -- TODO FIXME pairs -> k, package.loaded[k]
            local iter = pairs(imports)

            local newiter = function(table, index)
                local k, path = iter(table, index)

                return k, package.loaded[path]
            end

            --- LuaLS is wrong here
            ---@diagnostic disable-next-line:redundant-return-value
            return newiter, imports, nil
        end
    })

    if not LuaX then
        ---@class LuaX : LuaX.Import
        ---@field _hookstate LuaX.HookState
        LuaX = export
    end

    return export
else
    local cmd = require("src.cmd.cmd")

    cmd()
end
