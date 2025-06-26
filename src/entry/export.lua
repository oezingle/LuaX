local Inline     = require("src.util.parser.Inline")
local LuaXParser = require("src.util.parser.LuaXParser")

local runtime    = require("src.entry.runtime")

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
}

-- copy fields directly
for k, v in pairs(runtime) do
    export[k] = v
end

-- Generally NativeElement implementations are not simultaneously loadable.
-- To get around this, we load them lazily in export's metatable's __index
local possibly_unstable_exports = {
    WiboxElement = function ()
        return require("src.util.NativeElement.WiboxElement")
    end,
    GtkElement = function ()
        return require("src.util.NativeElement.GtkElement")
    end,
    WebElement = function ()
        return require("src.util.NativeElement.WebElement")
    end,

    GLibIdleWorkloop = function ()
        return require("src.util.WorkLoop.GLibIdle")
    end,
    WebWorkLoop = function ()
        return require("src.util.WorkLoop.Web")
    end,
}

setmetatable(export, {
    __call = function(t, tag)
        return t.transpile.inline(tag)
    end,
    __index = function(t, k)
        local implementation = possibly_unstable_exports[k]
        if implementation then
            t[k] = implementation
            
            return implementation()
        end
    end
})

return export
