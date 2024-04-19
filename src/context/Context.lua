
local class = require("lib.30log")
local use_effect = require("src.hooks.use_effect")

---@class LuaX.Context<T> : Log.BaseFunctions, { default: T, Provider: LuaX.Component }
---@field protected default table
---@field Provider LuaX.Component
---@operator call:LuaX.Context
local Context = class("Context")

---@param default table
function Context:init(default)
    self.default = default or {}

    -- create_element doesn't know what self is.
    self.Provider = function (props)
        return self.GenericProvider(self, props)
    end
end

function Context:GenericProvider (props)
    props.__luax_internal.context[self] = props.value or self.default

    return props.children
end

return Context