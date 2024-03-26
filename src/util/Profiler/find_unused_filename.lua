
local LOOP_PANIC_MAX = 1024

--- If filename exists, convert the string to filename-1, filename-2, ...
---@param path string
---@return string path
local function find_unused_filename(path)
    local i = 0

    while io.open(path, "r") do
        path = path:gsub("%-(%d+)$", function(index_str)
            local index = tonumber(index_str)

            return "-" .. tostring(index + 1)
        end)

        -- see if the file has been suffixed with -(number)
        if not path:match("%-(%d+)$") then
            path = path .. "-1"
        end

        if i >= LOOP_PANIC_MAX then
            error(string.format("Unable to find unused filename after %d iterations. Please rename callgrind files", LOOP_PANIC_MAX))
        end

        i = i + 1
    end

    return path
end

return find_unused_filename
