-- https://github.com/luarocks/luarocks/blob/master/src/luarocks/loader.lua

local LuaXParser = require("src.util.parser.LuaXParser")

local sep = require("src.util.polyfill.path.sep")

---@param modulename string
local function luax_loader(modulename)
    local modulepath = string.gsub(modulename, "%.", sep)

    local match_module_files = "." .. sep .. "?.luax;." .. sep .. "?" .. sep .. "init.luax"

    for path in string.gmatch(match_module_files, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)

        local file = io.open(filename, "r")

        if file then
            local content = file:read("a")

            local parser = LuaXParser.from_file_content(content, filename)

            local transpiled = parser:transpile()

            local get_module, err = load(transpiled, filename)

            if not get_module then
                error(err)
            end

            return get_module
        end
    end

    return string.format("No LuaX module found for %s", modulename)
end

return luax_loader
