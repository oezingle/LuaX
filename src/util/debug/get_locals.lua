
---@param stack integer|function
---@return table<string, any>
local function get_locals(stack)
    local locals = {}

    local index = 1

    while true do
        local var_name, var_value = debug.getlocal(stack, index)

        if not var_name then
            break
        end

        locals[var_name] = var_value

        index = index + 1
    end

    --[[
    for k, v in pairs(locals) do
        print(k, v)
    end
    ]]

    return locals
end

return get_locals
