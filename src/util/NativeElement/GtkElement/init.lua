---@class LuaX.GtkElement : LuaX.NativeElement
---@field set_lowercase fun(lowercase: boolean)

local vanilla_require = require
local require = function(path)
    local ok, ret = pcall(vanilla_require, path)

    if ok then
        return ret
    else
        warn(ret)
    end
end

return
    require("src.util.NativeElement.GtkElement.lgi.Gtk3Element") or
    error("No GtkElement implementation loaded successfully. To see the errors created by these implementations, use warn(\"@on\") before loading this file.")