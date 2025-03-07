local Inline      = require("src.util.parser.Inline")
local LuaXParser  = require("src.util.parser.LuaXParser")

local runtime = require("src.entry.runtime")

local _VERSION    = "0.5.0-dev"

---@class LuaX : LuaX.Runtime
--- Parsing
---@field register fun() Register the LuaX loader
---@field Parser LuaX.Parser.V3
---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string), inline: (fun(tag: string): string)|(fun(fn: function): function) }
---
---@operator call:function

local export = {
    register       = require("src.util.parser.loader.register"),
    Parser         = LuaXParser,
    transpile      = {
        ---@param path string
        from_path = function(path)
            return LuaXParser.from_file_path(path):transpile()
        end,
        ---@param content string
        ---@param source string?
        from_string = function(content, source)
            return LuaXParser.from_file_content(content, source):transpile()
        end,
        inline = function(tag)
            return Inline:transpile(tag)
        end
    },

    _VERSION       = _VERSION
}

for k, v in pairs(runtime) do
    export[k] = v
end

export.create_context = export.Context.create
export.create_portal = export.Portal.create

setmetatable(export, {
    __call = function(t, tag)
        return t.transpile.inline(tag)
    end
})

local ensure_warn = require("src.util.ensure_warn")
ensure_warn()

return export
