local function htmlparser_shiv()
    package.loaded["htmlparser.ElementNode"] = require("lib.htmlparser.src.htmlparser.ElementNode")
    package.loaded["htmlparser.voidelements"] = require("lib.htmlparser.src.htmlparser.voidelements")


    ---@type { parse: fun(html: string): HTMLParser.Node }
    return require("lib.htmlparser.src.htmlparser")
end

---@class HTMLParser.Node
---@field select fun(self: self, selectorstring: string): HTMLParser.Node[]
---
---@field name string
---@field attributes table<string, string>
---@field id string?
---@field classes string[]
---@field getcontent fun(self: self): string text content
---@field nodes HTMLParser.Node[]
---@field parent HTMLParser.Node
---
---@field index integer
---@field gettext fun(self: self): string html content
---@field level integer
---@field root HTMLParser.Node
---@field deepernodes HTMLParser.Node[]
---@field deeperelements table<string, HTMLParser.Node[]>
---@field deeperattributes table<string, HTMLParser.Node[]>
---@field deeperids table<string, HTMLParser.Node[]>
---@field deeperclasses table<string, HTMLParser.Node[]>

return htmlparser_shiv()
