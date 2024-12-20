do local folder_of_this_file
local module_arg={...}
if module_arg[1] ~= (arg or {})[1] then folder_of_this_file=module_arg[1] .. "."
local is_implicit_init=module_arg[2]:match(module_arg[1] .. "[/\\]init%.lua")
if  not is_implicit_init then folder_of_this_file=folder_of_this_file:match"(.+%.)[^.]+" or "" end else folder_of_this_file=arg[0]:gsub("[^%./\\]+%..+$","")
do local sep=package.path:sub(1,1)
local pwd=sep == "/" and os.getenv"PWD" or io.popen("cd","r"):read"a"
for _ in folder_of_this_file:gmatch"%.%." do pwd=pwd:gsub("[/\\][^/\\]+[/\\]?$","") end
pwd=pwd .. sep
package.path=package.path .. string.format(";%s?.lua;%s?%sinit.lua",pwd,pwd,sep) end
folder_of_this_file=folder_of_this_file:gsub("[/\\]","."):gsub("^%.+","") end
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.")
require(library_root .. "_shim") end

local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local traceback=require"lib_LuaX.util.debug.traceback"
local get_locals=require"lib_LuaX.util.debug.get_locals"
local get_function_location=require"lib_LuaX.util.Renderer.helper.get_function_location"
local get_component_name=require"lib_LuaX.util.Renderer.helper.get_component_name"
local Fragment=require"lib_LuaX.components.Fragment"
---@class LuaX.Parser.Inline
local create_element=require"lib_LuaX.create_element"
local Inline={["debuginfo"] = {},["transpile_cache"] = {},["assertions"] = {},["assert"] = {}}
function Inline.assert.can_use_decorator() assert(debug.getinfo,"Cannot use inline parser decorator: debug.getinfo does not exist")
local function test_function() return debug.getinfo(1,"f") end
local info=test_function()
assert(info.func == test_function,"Cannot use inline parser decorator: debug.getinfo API changed")
assert(debug.sethook,"Cannot use inline parser decorator: debug.sethook does not exist")
assert(debug.gethook,"Cannot use inline parser decorator: debug.gethook does not exist") end
function Inline.assert.can_get_local() assert(debug,"Cannot use inline parser: debug global does not exist")
assert(debug.getlocal,"Cannot use inline parser: debug.getlocal does not exist")
assert(type(debug.getlocal) == "function","Cannot use inline parser: debug.getlocal is not a function")
local im_a_local="Hello World!"
local name,value=debug.getlocal(1,1)
assert(name == "im_a_local" and value == "Hello World!","Cannot use inline parser: debug.getlocal API changed") end
---@param chunk string
---@param env table
---@param src string?
function Inline.easy_load(chunk,env,src) local chunkname="inline LuaX"
if src then chunkname=chunkname .. " " .. src end
local get_output,err=load(chunk,chunkname,nil,env)
if  not get_output then warn"Transpiled code run:"
print(chunk)
error(err) end
local ok,ret=pcall(get_output)
if ok then return ret else local file,err=ret:match"%[string \"inline LuaX%s*([^\"]*)\"%]:1:%s*(.*)$"
local new_err=string.format("LuaX: %s: %s",file,err)
error(new_err) end end
---@param fn function
function Inline:lazy_assert(fn) if type(self.assertions[fn]) == "string" then error(self.assertions[fn]) end
local ok,err=xpcall(fn,traceback)
if ok then self.assertions[fn]=false else self.assertions[fn]=err
error(err) end end

---@param tag string?
---@param locals table
function Inline:cache_get(tag,locals) if  not tag then return "return nil" end
local cached=self:cache_find(tag)
if cached then return cached end
local transpiled=LuaXParser.from_inline_string("return " .. tag):handle_variables_as_table(locals):set_components(locals,"local"):transpile()
self:cache_set(tag,transpiled)
return transpiled end
---@param tag string
---@param transpiled string
function Inline:cache_set(tag,transpiled) self.transpile_cache[tag]=transpiled end
function Inline:cache_find(tag) return self.transpile_cache[tag] end
---@param tag string?
function Inline:cache_clear(tag) if tag then self.transpile_cache[tag]=nil else self.transpile_cache={} end end

function Inline.print_locals(locals) for k,v in pairs(locals) do print(k,v) end end


---@protected
---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
local REQUEST_ORIGINAL_CHUNK={}
function Inline:transpile_decorator(chunk,stackoffset) self:lazy_assert(Inline.assert.can_use_decorator)
self:lazy_assert(Inline.assert.can_get_local)
local stackoffset=stackoffset or 0

---@diagnostic disable-next-line:invisible
local chunk_locals,chunk_names=get_locals(3 + stackoffset)
if chunk_locals[LuaXParser.vars.IS_COMPILED.name] then return chunk end
---@diagnostic disable-next-line:invisible
---@diagnostic disable-next-line:invisible
chunk_locals[LuaXParser.vars.CREATE_ELEMENT.name]=create_element
chunk_locals[LuaXParser.vars.FRAGMENT.name]=Fragment
setmetatable(chunk_locals,{["__index"] = _G})
setmetatable(chunk_names,{["__index"] = _G})
local inline_luax=function (...) 
if ({...})[1] == REQUEST_ORIGINAL_CHUNK then return chunk end

local prev_hook,prev_mask=debug.gethook()

local inner_locals,inner_names
debug.sethook(function () 
local info=debug.getinfo(2,"f")
if info.func == chunk then inner_locals,inner_names=get_locals(3) end end,"r")
local tag=chunk(...)
debug.sethook(prev_hook,prev_mask)
setmetatable(inner_locals,{["__index"] = chunk_locals})
setmetatable(inner_names,{["__index"] = chunk_names})
local element_str=self:cache_get(tag,inner_names)
local chunk_src=get_function_location(chunk)
local node=self.easy_load(element_str,inner_locals,chunk_src)
return node end
return inline_luax end

---@param fn function
function Inline:get_original_chunk(fn) return fn(REQUEST_ORIGINAL_CHUNK) end
---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
function Inline:transpile_string(tag,stackoffset) self:lazy_assert(self.assert.can_get_local)

local stackoffset=stackoffset or 0
---@diagnostic disable-next-line:invisible
local locals,names=get_locals(3 + stackoffset)
local vars=LuaXParser.vars
locals[vars.CREATE_ELEMENT.name]=create_element
names[vars.CREATE_ELEMENT.name]=true
locals[vars.FRAGMENT.name]=Fragment
names[vars.FRAGMENT.name]=true
locals[vars.IS_COMPILED.name]=true
names[vars.IS_COMPILED.name]=true
local element_str=self:cache_get(tag,names)
local env=setmetatable(locals,{["__index"] = _G})
return self.easy_load(element_str,env) end



---@overload fun (self: self, input: function): LuaX.Component
---@param input string
---@param stackoffset integer?
---@return LuaX.ElementNode
function Inline:transpile(input,stackoffset) local t=type(input)
if t == "function" then return self:transpile_decorator(input,stackoffset) else return self:transpile_string(input,stackoffset) end end


do ---@type { set_Inline: fun(Inline: LuaX.Parser.Inline)}

local get_component_name=get_component_name
get_component_name.set_Inline(Inline) end
return Inline