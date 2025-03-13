local _VERSION   = "0.5.2"

---@class LuaX.Runtime
--- APIs
---@field Renderer LuaX.Renderer
---@field Children LuaX.Children
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
---@field use_callback LuaX.Hooks.UseCallback
---@field use_context LuaX.Hooks.UseContext
---@field use_effect LuaX.Hooks.UseEffect
---@field use_memo LuaX.Hooks.UseMemo
---@field use_portal LuaX.Hooks.UsePortal
---@field use_ref LuaX.Hooks.UseRef
---@field use_state LuaX.Hooks.UseState
---@field use_suspense LuaX.Hooks.UseSuspense
---
---@field _VERSION string
local runtime = {
    Renderer       = require("src.util.Renderer"),
    Children       = require("src.Children"),

    create_element = require("src.create_element"),
    clone_element  = require("src.clone_element"),

    Fragment       = require("src.components.Fragment"),
    Suspense       = require("src.components.Suspense"),
    ErrorBoundary  = require("src.components.ErrorBoundary"),
    Context        = require("src.Context"),
    Portal         = require("src.Portal"),

    use_callback   = require("src.hooks.use_callback"),
    use_context    = require("src.hooks.use_context"),
    use_effect     = require("src.hooks.use_effect"),
    use_memo       = require("src.hooks.use_memo"),
    use_portal     = require("src.hooks.use_portal"),
    use_ref        = require("src.hooks.use_ref"),
    use_state      = require("src.hooks.use_state"),
    use_suspense   = require("src.hooks.use_suspense"),

    _VERSION          = _VERSION
}

-- Set up a passthrough so transpiled inline LuaX works nicely.
setmetatable(runtime, { __call = function (_, ...) 
    return ...
end })

runtime.create_context = runtime.Context.create
runtime.create_portal  = runtime.Portal.create

return runtime
