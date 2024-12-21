local Parser = require("lib.lua-parser")

---@type LuaX.Parser.V3
local LuaXParser

---@generic T
---@param list T[]
---@return table<T, true>
local function list_to_map(list)
    local map = {}

    for _, item in pairs(list) do
        map[tostring(item)] = true
    end

    return map
end

--- TODO could do a much better job - get current scope by position, then find parent expressions to ignore variables outside scope
--- Recursively collect locals given a lua-parser tree
---@param vars string[]
---@param node Lua-Parser.Node
local function collect_vars(vars, node)
    for _, expression in ipairs(node) do
        --[[
        print(expression)
        for k, v in pairs(expression) do
            if k ~= "parent" then
                print("", k, v)
            end
        end
        ]]

        if expression.name then
            -- lua-parser now seems to nest expression names??
            table.insert(vars, expression.name.name)
        end

        if expression.vars then
            for _, var in ipairs(expression.vars) do
                table.insert(vars, var.name)
            end
        end

        if expression.exprs then
            collect_vars(vars, expression.exprs)
        end
    end
end

---@param text string
---@return table<string, true>
local function collect_locals (text)
    -- this is the most resource intensive way to do this, BUT
    -- 1. users get a warning when auto_set_components can't resolve globals
    -- 2. cpus are free these days. completeness trumps efficiency in this case
    local text = LuaXParser()
        :set_text(text)
        :set_sourceinfo("collect_locals internal parser")
        :set_components({}, "local")
        :transpile()

    local node, err = Parser.parse(text)

    if not node then
        error("Unable to collect locals - are you sure your code is syntactically correct?\n" .. err)
    end

    ---@type string[]
    local vars = {}

    collect_vars(vars, node)

    return list_to_map(vars)
end

return function (parser)
    LuaXParser = parser

    return collect_locals
end