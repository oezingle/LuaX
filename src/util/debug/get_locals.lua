
---@param stack integer|function
---@return table<string, any> locals, table<string, any> names
local function get_locals(stack)
    local locals = {}
    local names = {}

    local index = 1

    while true do
        local var_name, var_value = debug.getlocal(stack, index)

        if not var_name then
            break
        end

        locals[var_name] = var_value
        names[var_name] = true

        index = index + 1
    end

    return locals, names
end

return get_locals
