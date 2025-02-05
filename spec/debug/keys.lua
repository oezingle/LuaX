local function keys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return table.concat(keys, ", ")
end

return keys
