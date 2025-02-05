-- Lua 5.1/LuaJIT provide getfenv & setfenv instead of _ENV, so we can just simulate _ENV
local _ENV = _ENV or _G

local searchpath = package.searchpath
local vanilla_require = require
--- env_aware_require acts the same as require(), except it reads/writes
--- _ENV.package.loaded instead of _G.package.loaded, and loads modules with
--- _ENV instead of _G (where _G is the original globals table, which Lua's
--- standard library uses instead of _ENV)
---@param modpath string
---@return any, string?
local function env_aware_require(modpath)
    local loaded = _ENV.package.loaded[modpath]
    if loaded then
        return loaded
    end

    local c_path = searchpath(modpath, package.cpath)
    -- for C modules, just allow vanilla require behaviour
    if c_path then
        return vanilla_require(modpath)
    end

    local path, err = searchpath(modpath, package.path)

    if not path then
        error(err)
    end

    local chunk, err = loadfile(path, nil, _ENV)
    if not chunk then
        error(err)
    end

    if _VERSION:match("%d.%d") == "5.1" then
        ---@diagnostic disable-next-line:deprecated
        setfenv(chunk, _ENV)
    end

    local mod = chunk(modpath, path)

    package.loaded[modpath] = mod

    return mod, path
end

local function parser_shim()
    local package, require = package, require

    if not _IS_BUNDLED then
        -- push new env so the real package.loaded isn't polluted.
        _ENV          = setmetatable({
            package = setmetatable({
                loaded = {
                    -- This list is minimal for my use case.
                    table = table,
                    string = string
                }
            }, { __index = package }),
            require = env_aware_require
        }, { __index = _G })

        package = _ENV.package
        require = _ENV.require
    end


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
