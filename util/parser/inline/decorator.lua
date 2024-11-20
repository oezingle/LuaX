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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.inline.")
require(library_root .. "_shim") end
local get_locals=require"lib_LuaX.util.parser.inline.get_locals"
local transpile_cache=require"lib_LuaX.util.parser.inline.transpile_cache"
local load_cache=require"lib_LuaX.util.parser.inline.load_cache"
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local Fragment=require"lib_LuaX.components.Fragment"
local create_element=require"lib_LuaX.create_element"
local debug=debug
local function assert_can_use_decorator() assert(debug.getinfo,"Cannot use inline parser decorator: debug.getinfo does not exist")
local function test_function() return debug.getinfo(1,"f") end
local info=test_function()
assert(info.func == test_function,"Cannot use inline parser decorator: debug.getinfo API changed")
assert(debug.sethook,"Cannot use inline parser decorator: debug.sethook does not exist")
assert(debug.gethook,"Cannot use inline parser decorator: debug.gethook does not exist") end
---@param chunk function
---@param stackoffset number?
---@return LuaX.FunctionComponent
assert_can_use_decorator()
local function inline_transpile_decorator(chunk,stackoffset) local stackoffset=stackoffset or 0
local chunk_src=debug.getinfo(chunk,"S").short_src

---@diagnostic disable-next-line:invisible
local chunk_locals=get_locals(3 + stackoffset)
if chunk_locals[LuaXParser.vars.IS_COMPILED.name] then return chunk end
---@diagnostic disable-next-line:invisible
---@diagnostic disable-next-line:invisible
chunk_locals[LuaXParser.vars.CREATE_ELEMENT.name]=create_element
chunk_locals[LuaXParser.vars.FRAGMENT.name]=Fragment
setmetatable(chunk_locals,{["__index"] = _G})
local inline_luax=function (...) 
local prev_hook,prev_mask=debug.gethook()
local inner_locals
debug.sethook(function () 
local info=debug.getinfo(2,"f")
if info.func == chunk then inner_locals=get_locals(3) end end,"r")
local tag=chunk(...)
debug.sethook(prev_hook,prev_mask)
setmetatable(inner_locals,{["__index"] = chunk_locals})
local element_str=transpile_cache.get(tag,inner_locals)
local node=load_cache.get(element_str,inner_locals,chunk_src)
return node end
return inline_luax end
return inline_transpile_decorator