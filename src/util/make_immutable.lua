
--!currently unused!

-- saves minimal memory to move this master table out of the metatable init
local master_table = {}

---@generic T
---@param table T
---@return T
local function make_immutable (table)
    return setmetatable(master_table, {
        __index = table,
        __newindex = function ()
            error("this table is immutable")
        end
    })
end

return make_immutable
