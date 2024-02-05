
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

-- TODO might not need effect - might even require not effect. Just nice for unmount.
function Context:GenericProvider (props)        
    use_effect(function ()
        -- uses self here as the unique table address.
        _G.LuaX._hookstate:provide_context(self, props.value or self.default)

        return function ()
            _G.LuaX._hookstate:provide_context(self, nil)            
        end
    end, { props.value })

    return props.children
end

return Context