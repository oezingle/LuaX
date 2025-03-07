---@class LuaX.Runtime
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
---@field ErrorBoundary LuaX.Component.ErrorBoundary
---@field Portal LuaX.Portal
---@field Context LuaX.Context
--- Hooks
---@field use_context LuaX.Hooks.UseContext
---@field use_effect LuaX.Hooks.UseEffect
---@field use_memo LuaX.Hooks.UseMemo
---@field use_portal LuaX.Hooks.UsePortal
---@field use_ref LuaX.Hooks.UseRef
---@field use_state LuaX.Hooks.UseState
---@field use_suspense LuaX.Hooks.UseSuspense
local runtime = {
    Renderer          = require("src.util.Renderer"),
    Children          = require("src.Children"),

    NativeElement     = require("src.util.NativeElement"),
    NativeTextElement = require("src.util.NativeElement.NativeTextElement"),
    -- TODO find a nice way to have these load, even though they throw errors
    -- TODO treeshake these based on target?
    -- WiboxElement   = require("src.util.NativeElement.WiboxElement"),
    -- GtkElement     = require("src.util.NativeElement.GtkElement"),

    create_element    = require("src.create_element"),
    clone_element     = require("src.clone_element"),

    Fragment          = require("src.components.Fragment"),
    Suspense          = require("src.components.Suspense"),
    ErrorBoundary     = require("src.components.ErrorBoundary"),
    Context           = require("src.Context"),
    Portal            = require("src.Portal"),

    use_context       = require("src.hooks.use_context"),
    use_effect        = require("src.hooks.use_effect"),
    use_memo          = require("src.hooks.use_memo"),
    use_portal        = require("src.hooks.use_portal"),
    use_ref           = require("src.hooks.use_ref"),
    use_state         = require("src.hooks.use_state"),
    use_suspense      = require("src.hooks.use_suspense"),
}

return runtime
