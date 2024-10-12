
--- Return true if a path exists and is a directory, false otherwise
---@param path string
---@return boolean
local function is_dir(path)
    local file = io.open(path, "r")

    if not file then
        return false
    end

    local _, _, code = file:read()

    if code == 21 then
        return true
    end

    return false
end

return is_dir