
-- TODO passing functions to components can be made a bit better using fn_equal perhaps?

local create_element = require("v3.create_element")
local get_function_location = require("v3.util.Renderer.helper.get_function_location")

local function_a = function (component, props)
---@diagnostic disable-next-line:undefined-field
if props.children then
    ---@type LuaX.ElementNode | string | (LuaX.ElementNode | string)[] | nil
    ---@diagnostic disable-next-line:undefined-field
    local children = props.children

    -- single child to children
    if type(children) ~= "table" or #children == 0 then
        children = { children }
    end

    for i, child in ipairs(children) do
        if type(child) ~= "table" then
            if type(child) == "function" then
                warn(string.format(
                    "passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",
                    get_function_location(child)
                ))
            end

            child = create_element("LITERAL_NODE", { value = tostring(child) })
        end

        -- TODO NO BAD NO
        -- child.key = i

        children[i] = child
    end

    props.children = children
end

return {
    type = component,
    props = props
}
end

local function_b = function (component, props)
---@diagnostic disable-next-line:undefined-field
if props.children then
    ---@type LuaX.ElementNode | string | (LuaX.ElementNode | string)[] | nil
    ---@diagnostic disable-next-line:undefined-field
    local children = props.children

    -- single child to children
    if type(children) ~= "table" or #children == 0 then
        children = { children }
    end

    for i, child in ipairs(children) do
        if type(child) ~= "table" then
            if type(child) == "function" then
                warn(string.format(
                    "passed a chld function (defined at %s) as a literal. Are you sure you didn't mean to call create_element()?",
                    get_function_location(child)
                ))
            end

            child = create_element("LITERAL_NODE", { value = tostring(child) })
        end

        -- TODO NO BAD NO
        -- child.key = i

        children[i] = child
    end

    props.children = children
end

return {
    type = component,
    props = props
}
end

---@param data string
---@return string[]
local function get_hex(data)
    local hex = {}

    for i = 1, #data do
        local char = string.sub(data, i, i)
        
        table.insert(hex, string.format("%02x", string.byte(char)))
    end

    return hex
end

local function write_hex (string, file)
    local data = table.concat(get_hex(string), "\n")

    local file = io.open(file, "w")

    if not file then
        error("File issue lmao")
    end

    file:write(data)
    file:flush()
    file:close()
end

---@param a function
---@param b function
local function fn_equal (a, b)
    local str_a = string.dump(a, true)
    local cmp_a = str_a:sub(1, 30) .. str_a:sub(40)
    
    local str_b = string.dump(b, true)
    local cmp_b = str_b:sub(1, 30) .. str_b:sub(40)

    return cmp_a == cmp_b
end

describe("function equality using string.dump", function ()
    it("fails same address", function ()
        assert.falsy(function_a == function_b)
    end)

    -- 33 chars same - header type shit
    -- 

    it("passes same content", function ()
        local string_a = string.dump(function_a, true)
        local string_b = string.dump(function_b, true)

        write_hex(string_a, "fn_dump/a.txt")
        write_hex(string_b, "fn_dump/b.txt")
        
        os.execute("code --diff fn_dump/a.txt fn_dump/b.txt")

        -- assert.truthy(string_a == string_b)
    end)
end)