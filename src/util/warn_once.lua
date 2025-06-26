--- Can't be tested because of warn() usage
---@nospec

local warn = require("src.util.polyfill.warn")

local table_pack = require("src.util.polyfill.table.pack")

local warn_history = {}

--- Like warn(), but will cache previous warnings.
---@param ... any
local function warn_once (...)
    local strs = {}
    for i, sub in ipairs(table_pack(...)) do
        strs[i] = tostring(sub)
    end
    
    local hash = table.concat(strs)

    if not warn_history[hash] then
        warn(...)

        warn_history[hash] = true
    end
end

return warn_once