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
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local get_locals=require"lib_LuaX.util.parser.inline.get_locals"
local transpile_cache=require"lib_LuaX.util.parser.inline.transpile_cache"
local load_cache=require"lib_LuaX.util.parser.inline.load_cache"
local Fragment=require"lib_LuaX.components.Fragment"


---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
local create_element=require"lib_LuaX.create_element"
local function inline_transpile_string(tag,stackoffset) 
local stackoffset=stackoffset or 0
---@diagnostic disable-next-line:invisible
local locals=get_locals(3 + stackoffset)
---@diagnostic disable-next-line:invisible
locals[LuaXParser.vars.CREATE_ELEMENT.name]=create_element
---@diagnostic disable-next-line:invisible
locals[LuaXParser.vars.FRAGMENT.name]=Fragment
locals[LuaXParser.vars.IS_COMPILED.name]=true
local element_str=transpile_cache.get(tag,locals)
local env=setmetatable(locals,{["__index"] = _G})
local node=load_cache.get(element_str,env)
return node end
return inline_transpile_string