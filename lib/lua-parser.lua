
local function parser_shim()
    package.loaded["ext.op"]                 = require("lib.lua-ext.op")
    package.loaded["ext.table"]              = require("lib.lua-ext.table")
    package.loaded["ext.class"]              = require("lib.lua-ext.class")
    package.loaded["ext.string"]             = require("lib.lua-ext.string")
    package.loaded["ext.tolua"]              = require("lib.lua-ext.tolua")
    package.loaded["ext.assert"]             = require("lib.lua-ext.assert")

    package.loaded["parser.base.ast"]        = require("lib.lua-parser.base.ast")
    package.loaded["parser.lua.ast"]         = require("lib.lua-parser.lua.ast")

    package.loaded["parser.base.datareader"] = require("lib.lua-parser.base.datareader")

    package.loaded["parser.base.tokenizer"]  = require("lib.lua-parser.base.tokenizer")
    package.loaded["parser.lua.tokenizer"]   = require("lib.lua-parser.lua.tokenizer")

    package.loaded["parser.base.parser"]     = require("lib.lua-parser.base.parser")
    package.loaded["parser.lua.parser"]      = require("lib.lua-parser.lua.parser")

    ---@alias Lua-Parser.Location { col: integer, line: integer }
    ---@alias Lua-Parser.Span { from: Lua-Parser.Location, to: Lua-Parser.Location }


    ---@class Lua-Parser.CNode
    ---@field span Lua-Parser.Span
    ---@field copy fun(self: self): self
    ---@field flatten fun(self:self, func: function, varmap: any) TODO Not sure how this works whatsoever
    ---@field toLua fun(self: self): string
    ---@field serialize fun(self: self, apply: function) TODO not sure how this works

    ---@class Lua-Parser.Node.Function : Lua-Parser.CNode
    ---@field type "function"
    ---@field func Lua-Parser.Node
    ---@field args Lua-Parser.Node[]

    ---@class Lua-Parser.Node.String
    ---@field type "string"
    ---@field value string

    ---@class Lua-Parser.Node.If
    ---@field type "if"
    ---@field cond Lua-Parser.Node
    ---@field elseifs Lua-Parser.Node[]
    ---@field elsestmt Lua-Parser.Node

    ---@alias Lua-Parser.Node Lua-Parser.CNode | Lua-Parser.Node.Function | Lua-Parser.Node.String | Lua-Parser.Node.If

    ---@type { parse: fun(lua: string): Lua-Parser.Node }
    return require("lib.lua-parser.parser")
end

return parser_shim()
