#!/usr/bin/env lua

local Inline      = require("src.util.parser.Inline")
local LuaXParser  = require("src.util.parser.LuaXParser")
local ensure_warn = require("src.util.ensure_warn")
local table_pack  = require("src.util.polyfill.table.pack")

local _VERSION    = "0.5.0-dev"

ensure_warn()

-- check if ... (provided by import) matches arg (provided by lua command line)
if table_pack(...)[1] ~= (arg or {})[1] then
    -- this file has been imported

    ---@class LuaX.Exported
    --- APIs
    ---@field Renderer LuaX.Renderer
    ---@field Children LuaX.Children
    ---
    ---@field NativeElement LuaX.NativeElement
    ---
    ---@field create_element fun(type: LuaX.Component, props: LuaX.Props): LuaX.ElementNode
    ---@field clone_element (fun(element: LuaX.ElementNode, props: LuaX.Props): LuaX.ElementNode) | (fun(element: LuaX.ElementNode[], props: LuaX.Props): LuaX.ElementNode[])
    --- Components
    ---@field Fragment LuaX.Component.Fragment
    ---@field Suspense LuaX.Component.Suspense
    ---@field Portal LuaX.Portal
    ---@field Context LuaX.Context
    --- Hooks
    ---@field use_context LuaX.Hooks.UseContext
    ---@field use_effect LuaX.Hooks.UseEffect
    ---@field use_memo LuaX.Hooks.UseMemo
    ---@field use_portal LuaX.Hooks.UsePortal
    ---@field use_ref LuaX.Hooks.UseRef
    ---@field use_state LuaX.Hooks.UseState
    ---@field use_supsense LuaX.Hooks.UseSuspense
    --- Parsing
    ---@field register fun() Register the LuaX loader
    ---@field Parser LuaX.Parser.V3
    ---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string), inline: (fun(tag: string): string)|(fun(fn: function): function) }
    ---
    ---@operator call:function

    local export = {
        Renderer       = require("src.util.Renderer"),
        Children       = require("src.Children"),

        NativeElement  = require("src.util.NativeElement"),
        -- TODO find a nice way to have these load, even though they throw errors
        -- TODO treeshake these based on target?
        -- WiboxElement   = require("src.util.NativeElement.WiboxElement"),
        -- GtkElement     = require("src.util.NativeElement.GtkElement"),

        create_element = require("src.create_element"),
        clone_element  = require("src.clone_element"),

        Fragment       = require("src.components.Fragment"),
        Suspense       = require("src.components.Suspense"),
        Context        = require("src.Context"),
        Portal         = require("src.Portal"),

        use_context    = require("src.hooks.use_context"),
        use_effect     = require("src.hooks.use_effect"),
        use_memo       = require("src.hooks.use_memo"),
        use_portal     = require("src.hooks.use_portal"),
        use_ref        = require("src.hooks.use_ref"),
        use_state      = require("src.hooks.use_state"),
        use_suspense   = require("src.hooks.use_suspense"),

        register       = require("src.util.parser.loader.register"),
        Parser         = LuaXParser,
        transpile      = {
            ---@param path string
            from_path = function(path)
                return LuaXParser.from_file_path(path):transpile()
            end,
            ---@param content string
            ---@param source string?
            from_string = function(content, source)
                return LuaXParser.from_file_content(content, source):transpile()
            end,
            inline = function(tag)
                return Inline:transpile(tag)
            end
        },

        __from_cli     = require("src.cmd.cmd"),

        _VERSION       = _VERSION
    }

    export.create_context = export.Context.create
    export.create_portal = export.Portal.create

    setmetatable(export, {
        __call = function(table, tag)
            return table.transpile.inline(tag)
        end
    })

    -- Check if LuaX global doesn't exist or LuaX global is an empty table.
    if not _G.LuaX or not next(_G.LuaX) then
        ---@class LuaX : LuaX.Exported
        ---@field _hookstate LuaX.HookState
        -- field _render_info LuaX.RenderInfo
        _G.LuaX = export
    end

    return export
else
    local cmd = require("src.cmd.cmd")

    cmd()
end
