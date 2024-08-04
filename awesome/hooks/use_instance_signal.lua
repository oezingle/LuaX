local use_state = require("src.hooks.use_state")
local use_effect = require("src.hooks.use_effect")

---@generic O : Awesome.InstanceSignalable<string>, R
---@param object O
---@param signal string
---@param transformer fun(object: O): R
---@return R
local function use_instance_signal(object, signal, transformer)
    local value, set_value = use_state(transformer(object))
    use_effect(function()
        local cb = function(object)
            set_value(transformer(object))
        end

        --- Signalable doesn't wanna work here
        ---@diagnostic disable-next-line:undefined-field
        object:connect_signal(signal, cb)

        return function()
            ---@diagnostic disable-next-line:undefined-field
            object:disconnect_signal(signal, cb)
        end
    end, { object })

    return value
end

return use_instance_signal
