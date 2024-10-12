local Parser = require("lib.lua-parser")
local find_ending_tag = require("src.util.parser.find_ending_tag")
local keywords = require("src.util.parser.keywords")

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
---@param node Lua-Parser.Exprs
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
            table.insert(vars, expression.name)
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
local collect_locals = function(text)
    -- TODO this is a sorry excuse for parsing functionality
    --[[
    text = text
        :gsub("%(%s*<.-</.->%s*%)", "nil")
        :gsub("=%s*<.-</.->", "= nil")
        :gsub("return%s*<.-</.->", "return nil")
    ]]

    repeat
        local multiline_start, multiline_end = text:find("%(%s*<")

        local _, assign_tag_start = text:find("=%s*<")

        local _, keyword_tag_start = nil, nil
        for _, keyword in ipairs(keywords) do
            _, keyword_tag_start = text:find(keyword .. "%s+<")

            if keyword_tag_start then break end
        end
        
        local pos = multiline_end or assign_tag_start or keyword_tag_start

        if not pos then
            break
        end

        local sub = text:sub(pos + 1)

        local length = find_ending_tag(sub)

        local end_tag_etc = text:sub(pos + 1 + length)

        local _, tag_end = end_tag_etc:find("^</.->")

        local tag_content = text:sub(pos, pos + length + tag_end)

        if multiline_start then
            tag_content = "(" .. tag_content .. ")"
        end

        text = text:gsub(tag_content, "nil")
    until false

    local node = Parser.parse(text)

    ---@type string[]
    local vars = {}

    collect_vars(vars, node)

    return list_to_map(vars)
end

return collect_locals
