local escape = require("src.util.polyfill.string.escape")

local function is_lua_file(path)
    local extensions = {
        ".lua",
        ".luax"
    }

    for _, extension in ipairs(extensions) do
        if path:match(escape(extension) .. "$") then
            return true
        end
    end

    local file = io.open(path)

    if not file then
        error(string.format("Unable to open %q", path))
    end

    local top = file:read("l")
    if top and top:match("^#!/usr/bin/lua") then
        return true
    end

    return false
end

return is_lua_file
