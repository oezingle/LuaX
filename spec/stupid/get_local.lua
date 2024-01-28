
---@param stack integer|function
---@param name string
local function get_local_named (stack, name)
    local index = 1

    while true do
        local var_name, var_value = debug.getlocal(stack + 1, index)

        if not var_name then 
            break
        end

        if var_name == name then
            return var_value
        end

        index = index + 1
    end
end

local function fake_create_element(element)
    -- local this = "fake_create_element"

    local var = get_local_named(2, element)

    local component = var or element

    print(component)
end

local function chunk ()
    -- local this = "chunk"

    local Fragment = require("src.components.Fragment")

    fake_create_element("Fragment")
end

chunk()