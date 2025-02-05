local sep        = require("src.util.polyfill.path.sep")
local table_pack = require("src.util.polyfill.table.pack")

---@param ... string
local function join(...)
    local elements = table_pack(...)

    local ret = {}

    for i, item in ipairs(elements) do
        local is_first = i == 1
        -- local is_last  = i == #elements

        -- Remove starts with slash
        if item:sub(1, 1) == sep and not is_first then
            item = item:sub(2)
        end

        if item:sub(-1) == sep then
            item = item:sub(1, -2)
        end

        table.insert(ret, item)
    end

    return table.concat(ret, sep)
end

return join
