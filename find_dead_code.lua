
local lfs = require("lfs")
local join= require("src.util.polyfill.path.join")

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

---@param path string
---@return string
local function luaify_path (path) 
    local path = path:gsub("%.lua$", ""):gsub("[/\\]", '.')

    return path
end

---@param dir string
---@param files string[]
local function find_files_recurse(dir, files)
    for filename in lfs.dir(dir) do
        if filename ~= "." and filename ~= ".." then
            local path = join(dir, filename)

            if is_dir(path) then
                find_files_recurse(path, files)
            else
                table.insert(files, path)
            end
        end
    end
end

local root_dir = "src"

local function main ()
    ---@type string[]
    local files = {}

    find_files_recurse(root_dir, files)

    local lua_paths = {}
    for _, file in pairs(files) do
        lua_paths[luaify_path(file)] = file
    end

    for _, real_path in pairs(files) do
        local f = io.open(real_path, "r")
        
        if not f then
            print("UNABLE TO OPEN", real_path)
            
            goto continue
        end

        for line in f:lines("l") do
            -- local required_path = line:match("require%(%s*[\"']([^\"'])[\"']%s*%)")
            local required_path = line:match("require%s*%(%s*[\"']([^\"']+)")

            if required_path then
                lua_paths[required_path] = nil
            end
        end

        ::continue::
    end

    print("Dead files:")
    for k, v in pairs(lua_paths) do
        print("", v)
    end
end

main ()