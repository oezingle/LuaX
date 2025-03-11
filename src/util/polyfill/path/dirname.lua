

---@param path string
---@return string
local function path_dirname(path)
    -- Path with no slashes, ie just a file
    if not path:match("[/\\]") and path:match("%.") then
        return ""
    end
 
    path = path:gsub("[/\\][^/\\]+%.%S+$", "")

    return path
end

return path_dirname