--[[
    Parse inline - leverage the debug library to allow users to render
    components in pure-lua environments
]]

local LuaXParser = require("src.util.parser.LuaXParser")
local traceback = require("src.util.debug.traceback")
local get_locals = require("src.util.debug.get_locals")
local get_function_location = require("src.util.debug.get_function_location")
local get_global_components = require("src.util.parser.transpile.get_global_components")

local get_component_name = require("src.util.debug.get_component_name")

local Fragment = require("src.components.Fragment")
local create_element = require("src.create_element")

local debug = debug or {}
local debug_getinfo = debug.getinfo
local debug_gethook = debug.gethook
local debug_sethook = debug.sethook
local debug_getlocal = debug.getlocal

---@class LuaX.Parser.Inline
local Inline = {
    debuginfo = {},
    transpile_cache = {},
    assertions = {},
    assert = {},

    original_chunks = setmetatable({}, { __mode = "kv" })
}

function Inline.assert.can_use_decorator()
    assert(debug_getinfo, "Cannot use inline parser decorator: debug.getinfo does not exist")

    local function test_function()
        -- assigning then returning allows this assertion to pass under LuaJIT,
        -- otherwise it would JIT optimize the tail call.
        local info = debug_getinfo(1, "f")

        return info
    end

    local info = test_function()

    assert(info.func == test_function,
        "Cannot use inline parser decorator: debug.getinfo API changed")

    assert(debug_sethook, "Cannot use inline parser decorator: debug.sethook does not exist")
    assert(debug_gethook, "Cannot use inline parser decorator: debug.gethook does not exist")
end

function Inline.assert.can_get_local()
    assert(debug, "Cannot use inline parser: debug global does not exist")

    assert(debug_getlocal, "Cannot use inline parser: debug.getlocal does not exist")

    assert(type(debug_getlocal) == "function", "Cannot use inline parser: debug.getlocal is not a function")

    local im_a_local = "Hello World!"

    local name, value = debug_getlocal(1, 1)

    -- we can't make assertions as to the name of this variable (formerly
    -- im_a_local) because it could have been renamed in a minification step
    assert(type(name) == "string" and value == "Hello World!",
        "Cannot use inline parser: debug.getlocal API changed")
end

---@param chunk string
---@param env table
---@param src string?
function Inline.easy_load(chunk, env, src)
    local chunkname = "inline LuaX"

    local get_output, err = load(chunk, chunkname, nil, env)

    if not get_output then
        err = tostring(err)
        if src then
            err = err:gsub("%[string \"inline LuaX\"%]:1", src)
        end

        error(string.format("Error loading transpiled LuaX.\ntranspilation:\n%s\n\n%s", chunk, err))
    end

    local ok, ret = xpcall(get_output, traceback)

    if ok then
        return ret
    else
        -- TODO try much harder to get current actual line number

        local file, err = ret:match("%[string \"inline LuaX\"%]:1:%s*(.*)$")

        local new_err = string.format("error in inline LuaX in %s: %s", file, tostring(err))

        error(new_err)
    end
end

---@param fn function
function Inline:cached_assert(fn)
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
---@param src string?
function Inline:cache_get(tag, locals, src)
    if not tag then
        return "return nil"
    end

    local cached = self:cache_find(tag)
    if cached then
        return cached
    end

    local parser = LuaXParser.from_inline_string("return " .. tag, src)

    -- mute on_set_variable warnings
    parser:set_handle_variables(function() end)

    local globals = get_global_components()
    if globals then
        parser:set_components(globals, "global")
    else
        parser:set_components(locals, "local")
    end

    local transpiled = parser:transpile()

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

---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
function Inline:transpile_decorator(chunk, stackoffset)
    self:cached_assert(Inline.assert.can_use_decorator)
    self:cached_assert(Inline.assert.can_get_local)

    local stackoffset = stackoffset or 0

    local chunk_locals, chunk_names = get_locals(3 + stackoffset)

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
    setmetatable(chunk_names, { __index = _G })

    local inline_luax = function(...)
        -- get hook & mask on debug ( if any ) to re-insert
        local prev_hook, prev_mask = debug_gethook()

        local inner_locals, inner_names

        -- get locals as they come
        debug_sethook(function()
            -- I don't even need name here! yippee!!
            local info = debug_getinfo(2, "f")

            if info.func == chunk then
                inner_locals, inner_names = get_locals(3)
            end
        end, "r")

        local tag = chunk(...)

        debug_sethook(prev_hook, prev_mask)

        local t = type(tag)

        if t == "table" or t == "nil" then
            return tag
        end

        setmetatable(inner_locals, { __index = chunk_locals })
        setmetatable(inner_names, { __index = chunk_names })

        local element_str = self:cache_get(tag, inner_names)

        local chunk_src = get_function_location(chunk)

        local node = self.easy_load(element_str, inner_locals, chunk_src)

        return node
    end

    self.original_chunks[inline_luax] = chunk

    return inline_luax
end

--- Get the original chunk from a function component that has been inline transpiled
---@param fn function
function Inline:get_original_chunk(fn)
    return self.original_chunks[fn]
end

---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
function Inline:transpile_string(tag, stackoffset)
    self:cached_assert(self.assert.can_get_local)

    local stackoffset = stackoffset or 0

    -- 3 is a value from trial and error
    local locals, names = get_locals(3 + stackoffset)

    ---@diagnostic disable-next-line:invisible
    local vars = LuaXParser.vars

    locals[vars.CREATE_ELEMENT.name] = create_element
    names[vars.CREATE_ELEMENT.name] = true

    locals[vars.FRAGMENT.name] = Fragment
    names[vars.FRAGMENT.name] = true

    locals[vars.IS_COMPILED.name] = true
    names[vars.IS_COMPILED.name] = true

    -- Get debug info, finding the first non-C caller. This is for cases wrapped
    -- in pcall. 1 is the Inline parser itself, so 2 is the first possible real
    -- caller.
    local stack_height = 2 
    local src
    repeat 
        local info = debug_getinfo(stack_height + stackoffset, "lS")

        if info.source ~= "=[C]" then
            src = info.source:sub(2) .. ":" .. info.currentline
        end

        stack_height = stack_height + 1
    until src
    
    local element_str = self:cache_get(tag, names, src)

    local env = setmetatable(locals, {
        __index = _G
    })

    return self.easy_load(element_str, env, src)
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
do
    ---@type { set_Inline: fun(Inline: LuaX.Parser.Inline)}
    local get_component_name = get_component_name --[[ @as any ]]
    get_component_name.set_Inline(Inline)
end

return Inline
