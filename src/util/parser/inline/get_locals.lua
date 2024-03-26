local function assert_can_get_local()
    assert(debug, "Cannot use inline parser: debug global does not exist")

    assert(debug.getlocal, "Cannot use inline parser: debug.getlocal does not exist")

    assert(type(debug.getlocal) == "function", "Cannot use inline parser: debug.getlocal is not a function")

    local im_a_local = "Hello World!"

    local name, value = debug.getlocal(1, 1)

    assert(name == "im_a_local" and value == "Hello World!",
        "Cannot use inline parser: debug.getlocal API changed")
end

assert_can_get_local()

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
