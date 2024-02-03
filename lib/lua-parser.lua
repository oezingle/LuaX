local function parser_shim()
    -- package.loaded["slaxml"] = require("lib.slaxml.slaxml")

    local shims = {
        { "ext.op",     "lib.lua-ext.op" },
        { "ext.table",  "lib.lua-ext.table" },

        { "ext.class",  "lib.lua-ext.class" },

        { "ext.string", "lib.lua-ext.string" },

        { "ext.tolua",  "lib.lua-ext.tolua" },
        { "parser.ast", "lib.lua-parser.ast" },
    }

    for _, shim in pairs(shims) do
        local dest, src = table.unpack(shim)

        package.loaded[dest] = require(src)
    end

    ---@alias Lua-Parser.Location { col: integer, line: integer }

    ---@alias Lua-Parser.Span { from: Lua-Parser.Location, to: Lua-Parser.Location }

    ---@alias Lua-Parser.Exprs { [number]: Lua-Parser.Node, span: Lua-Parser.Span }

    ---@alias Lua-Parser.Variable { span: Lua-Parser.Span, name: string, parent: Lua-Parser.Node }

    ---@alias Lua-Parser.Node { exprs: Lua-Parser.Exprs, parent: Lua-Parser.Node, span: Lua-Parser.Span, vars?: Lua-Parser.Variable[], name?: string }

    ---@type { parse: fun(lua: string): Lua-Parser.Exprs }
    return require("lib.lua-parser.parser")
end

return parser_shim()
