
local class = require("lib.30log")
local RenderInfo = require("src.util.Renderer.RenderInfo")

---@class LuaX.Context<T> : Log.BaseFunctions, { default: T, Provider: LuaX.Component }
---@field protected default table
---@field Provider LuaX.Component
---@operator call:LuaX.Context
local Context = class("Context")

---@param default table
function Context:init(default)
    self.default = default

    -- create_element doesn't know what self is.
    self.Provider = function (props)
        return self:GenericProvider(props)
    end
end

function Context:GenericProvider (props)
    RenderInfo.get().context[self] = props.value
    -- props.__luax_internal.context[self] = props.value

    return props.children
end

---@generic T
---@param default T?
---@return LuaX.Context<T>
function Context.create (default)
    return Context(default)
end

return Context