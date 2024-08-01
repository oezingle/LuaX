local get_locals      = require("src.util.parser.inline.get_locals")
local transpile_cache = require("src.util.parser.inline.transpile_cache")
local load_cache      = require("src.util.parser.inline.load_cache")

local LuaXParser      = require("src.util.parser.LuaXParser")
local Fragment        = require("src.components.Fragment")
local create_element  = require("src.create_element")


local debug = debug

local function assert_can_use_decorator()
    assert(debug.getinfo, "Cannot use inline parser decorator: debug.getinfo does not exist")

    local function test_function()
        return debug.getinfo(1, "f")
    end

    local info = test_function()

    assert(info.func == test_function,
        "Cannot use inline parser decorator: debug.getinfo API changed")

    assert(debug.sethook, "Cannot use inline parser decorator: debug.sethook does not exist")
    assert(debug.gethook, "Cannot use inline parser decorator: debug.gethook does not exist")
end

assert_can_use_decorator()

---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
local function inline_transpile_decorator(chunk, stackoffset)
    local stackoffset = stackoffset or 0

    local chunk_src = debug.getinfo(chunk, "S").short_src

    local chunk_locals = get_locals(3 + stackoffset)

    -- This is compiled, ignore usage of decorator
    if chunk_locals[LuaXParser.imports.auto.IS_COMPILED.name] then
        return chunk
    end

    chunk_locals[LuaXParser.imports.required.CREATE_ELEMENT.name] = create_element
    chunk_locals[LuaXParser.imports.auto.FRAGMENT.name] = Fragment

    setmetatable(chunk_locals, { __index = _G })

    local inline_luax = function (...)
        -- get hook & mask on debug ( if any ) to re-insert
        local prev_hook, prev_mask = debug.gethook()

        local inner_locals

        debug.sethook(function()
            -- I don't even need name here! yippee!!
            local info = debug.getinfo(2, "f")

            if info.func == chunk then
                inner_locals = get_locals(3)
            end
        end, "r")

        local tag = chunk(...)

        debug.sethook(prev_hook, prev_mask)

        setmetatable(inner_locals, {
            __index = chunk_locals
        })

        local element_str = transpile_cache.get(tag, inner_locals)

        local node = load_cache.get(element_str, inner_locals, chunk_src)

        return node
    end

    return inline_luax
end

return inline_transpile_decorator
