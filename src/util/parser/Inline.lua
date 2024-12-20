--[[
    Parse inline - leverage the debug library to allow users to render
    components in pure-lua environments 
]]

local LuaXParser = require("src.util.parser.LuaXParser")
local traceback = require("src.util.debug.traceback")
local get_locals = require("src.util.debug.get_locals")

local Fragment = require("src.components.Fragment")
local create_element = require("src.create_element")

---@class LuaX.Parser.Inline
local Inline = {
    debuginfo = {},
    transpile_cache = {},
    assertions = {},
    assert = {},
}

function Inline.assert.can_use_decorator()
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

function Inline.assert.can_get_local()
    assert(debug, "Cannot use inline parser: debug global does not exist")

    assert(debug.getlocal, "Cannot use inline parser: debug.getlocal does not exist")

    assert(type(debug.getlocal) == "function", "Cannot use inline parser: debug.getlocal is not a function")

    local im_a_local = "Hello World!"

    local name, value = debug.getlocal(1, 1)

    assert(name == "im_a_local" and value == "Hello World!",
        "Cannot use inline parser: debug.getlocal API changed")
end



---@param chunk string
---@param env table
---@param src string?
function Inline.easy_load(chunk, env, src)
    local chunkname = "inline LuaX"
    if src then
        chunkname = chunkname .. " " .. src
    end

    local get_output, err = load(chunk, chunkname, nil, env)

    if not get_output then
        warn("Transpiled code run:")
        print(chunk)

        error(err)
    end

    return get_output()
end

---@param fn function
function Inline:lazy_assert(fn)
    if type(self.assertions[fn]) == "string" then
        error(self.assertions[fn])
    end

    local ok, err = xpcall(fn, traceback)

    if ok then
        self.assertions[fn] = false
    else
        self.assertions[fn] = err
        
        error(err)
    end
end

--#region transpilation

---@param tag string?
---@param locals table
function Inline:cache_get(tag, locals)
    if not tag then
        return "return nil"
    end

    local cached = self:cache_find(tag)
    if cached then
        return cached
    end

    local transpiled = LuaXParser.from_inline_string("return " .. tag)
        :handle_variables_as_table(locals)
        :set_components(locals, "local")
        :transpile()

    self:cache_set(tag, transpiled)

    return transpiled
end

---@param tag string
---@param transpiled string
function Inline:cache_set(tag, transpiled)
    self.transpile_cache[tag] = transpiled
end

function Inline:cache_find(tag)
    return self.transpile_cache[tag]
end

---@param tag string?
function Inline:cache_clear(tag)
    if tag then
        self.transpile_cache[tag] = nil
    else
        self.transpile_cache = {}
    end
end

-- nice debug function that prints locals
function Inline.print_locals(locals)
    for k, v in pairs(locals) do
        print(k, v)
    end
end

-- TODO maybe load() can set custom debug info? in which case, we can create
-- decorator callback, dump it as a template, and then smash in binary-dumped transpile results.
---@protected
local REQUEST_ORIGINAL_CHUNK = {}

---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
function Inline:transpile_decorator(chunk, stackoffset)
    self:lazy_assert(Inline.assert.can_use_decorator)
    self:lazy_assert(Inline.assert.can_get_local)

    local stackoffset = stackoffset or 0

    local chunk_locals = get_locals(3 + stackoffset)

    -- This is compiled, ignore usage of decorator
    ---@diagnostic disable-next-line:invisible
    if chunk_locals[LuaXParser.vars.IS_COMPILED.name] then
        return chunk
    end

    ---@diagnostic disable-next-line:invisible
    chunk_locals[LuaXParser.vars.CREATE_ELEMENT.name] = create_element
    ---@diagnostic disable-next-line:invisible
    chunk_locals[LuaXParser.vars.FRAGMENT.name] = Fragment

    setmetatable(chunk_locals, { __index = _G })

    local inline_luax = function (...)
        -- TODO honestly this feels like an evil hack. in practice it's okay, but jeez.
        if ({...})[1] == REQUEST_ORIGINAL_CHUNK then
            return chunk
        end

        -- get hook & mask on debug ( if any ) to re-insert
        local prev_hook, prev_mask = debug.gethook()

        local inner_locals

        -- get locals as they come
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

        local element_str = self:cache_get(tag, inner_locals)

        local chunk_src = debug.getinfo(chunk, "S").short_src

        local node = self.easy_load(element_str, inner_locals, chunk_src)

        return node
    end

    return inline_luax
end

--- Get the original chunk from a function component that has been inline transpiled
---@param fn function
function Inline:get_original_chunk (fn)
    return fn(REQUEST_ORIGINAL_CHUNK)
end

---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
function Inline:transpile_string(tag, stackoffset)
    self:lazy_assert(self.assert.can_get_local)

    local stackoffset = stackoffset or 0

    -- 3 is a value from trial and error
    local locals = get_locals(3 + stackoffset)
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.CREATE_ELEMENT.name] = create_element
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.FRAGMENT.name] = Fragment
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.IS_COMPILED.name] = true

    local element_str = self:cache_get(tag, locals)

    local env = setmetatable(locals, {
        __index = _G
    })

    return self.easy_load(element_str, env)
end

--- Inline transpiler, taking either a LuaX string or a Component.
--- Components preferred as locals can be looked up better.
---
---@overload fun (self: self, input: function): LuaX.Component
---@param input string
---@param stackoffset integer?
---@return LuaX.ElementNode
function Inline:transpile(input, stackoffset)
    local t = type(input)

    if t == "function" then
        return self:transpile_decorator(input, stackoffset)
    else
        return self:transpile_string(input, stackoffset)
    end
end

--#endregion

--- Crazy (bad) diamond dependency fix.
---@type { set_Inline: fun(Inline: LuaX.Parser.Inline)}
local get_component_name = require("src.util.Renderer.helper.get_component_name") --[[ @as any ]]
get_component_name.set_Inline(Inline)

return Inline