local Inline     = require("src.util.parser.Inline")
local LuaXParser = require("src.util.parser.LuaXParser")

local runtime    = require("src.entry.runtime")

local _VERSION   = "0.5.1"

---@class LuaX : LuaX.Runtime
--- Parsing
---@field register fun() Register the LuaX loader
---@field Parser LuaX.Parser.V3
---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string), inline: (fun(tag: string): string)|(fun(fn: function): function) }
---
---@field NativeElement LuaX.NativeElement
---@field NativeTextElement LuaX.NativeTextElement
---
---@field GtkElement LuaX.GtkElement
---@field WiboxElement LuaX.WiboxElement
---@field WebElement LuaX.WebElement
---
---@operator call:function

local export     = {
    NativeElement     = require("src.util.NativeElement"),
    NativeTextElement = require("src.util.NativeElement.NativeTextElement"),

    register          = require("src.util.parser.loader.register"),
    Parser            = LuaXParser,
    transpile         = {
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

    _VERSION          = _VERSION
}

-- copy fields directly
for k, v in pairs(runtime) do
    export[k] = v
end

local element_implementations = {
    WiboxElement = function ()
        return require("src.util.NativeElement.WiboxElement")
    end,
    GtkElement = function ()
        return require("src.util.NativeElement.GtkElement")
    end,
    WebElement = function ()
        return require("src.util.NativeElement.WebElement")
    end,
}

setmetatable(export, {
    __call = function(t, tag)
        return t.transpile.inline(tag)
    end,
    __index = function(_, k)
        local implementation = element_implementations[k]
        if implementation then
            return implementation()
        end
    end
})

local ensure_warn = require("src.util.ensure_warn")
ensure_warn()

return export
