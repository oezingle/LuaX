local Inline     = require("src.util.parser.Inline")
local LuaXParser = require("src.util.parser.LuaXParser")

local runtime    = require("src.entry.runtime")

local _VERSION   = "0.5.0-dev"

---@class LuaX : LuaX.Runtime
--- Parsing
---@field register fun() Register the LuaX loader
---@field Parser LuaX.Parser.V3
---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string), inline: (fun(tag: string): string)|(fun(fn: function): function) }
---
---@field NativeElement LuaX.NativeElement
---@field NativeTextElement LuaX.NativeTextElement
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

local element_implementations = {}

-- Load any enabled targets
-- TODO this code is AWFUL. Find a fix compatible with the web bundler.
do
    if not SKIP_TARGET_WiboxElement then
        local ok, err = pcall(function()
            element_implementations.WiboxElement = require("src.util.NativeElement.WiboxElement")
        end)
        if not ok then
            element_implementations.WiboxElement = err
        end
    end
    if not SKIP_TARGET_GtkElement then
        local ok, err = pcall(function()
            element_implementations.GtkElement = require("src.util.NativeElement.GtkElement")
        end)
        if not ok then
            element_implementations.GtkElement = err
        end
    end
    if not SKIP_TARGET_WebElement then
        local ok, err = pcall(function()
            element_implementations.WebElement = require("src.util.NativeElement.WebElement")
        end)
        if not ok then
            element_implementations.WebElement = err
        end
    end
end


setmetatable(export, {
    __call = function(t, tag)
        return t.transpile.inline(tag)
    end,
    __index = function(_, k)
        local implementation = element_implementations[k]
        if type(implementation) == "string" then
            error(implementation)
        else
            return implementation
        end
    end
})

local ensure_warn = require("src.util.ensure_warn")
ensure_warn()

return export
