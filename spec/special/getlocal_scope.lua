

--- Different from src/util/parser/inline/get_locals.lua
---@param stack integer|function
---@return { name: string, value: any }[]
local function get_locals(stack)
    local locals = {}

    local index = 1

    while true do
        local var_name, var_value = debug.getlocal(stack, index)

        if not var_name then
            break
        end

        table.insert(locals, {
            name = var_name,
            value = var_value
        })

        index = index + 1
    end

    return locals
end

---@param inner boolean
local function function_with_inner (inner)
    local a = "Hello world!"

    local b = 0

    local c = false

    if inner then
        local d = 1

        local e = "Goodbye!"
    end

    local f = true

    local locals = get_locals(2)

    return locals
end

describe("getlocal", function ()
    it("has the same count with multiple blocks", function ()
        local locals1 = function_with_inner(false)

        local locals2 = function_with_inner(true)

        assert.equal(#locals1, #locals2)
    end)

    -- TODO more tests
end)