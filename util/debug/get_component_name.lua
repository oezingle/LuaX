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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.debug.")
require(library_root .. "_shim") end
local get_function_location=require"lib_LuaX.util.debug.get_function_location"
local get_function_name=require"lib_LuaX.util.debug.get_function_name"
local ElementNode=require"lib_LuaX.util.ElementNode"
local Inline
local inline_transpiled_location={}
local function actually_get_component_name(component) local t=type(component)
if t == "function" then local location=get_function_location(component)
local name=get_function_name(location)
if location == inline_transpiled_location then local chunk=Inline:get_original_chunk(component)
if chunk then return actually_get_component_name(chunk) else return "Inline LuaX" end elseif name ~= location then return string.format("%s (%s)",name,location) end
return "Function defined at " .. location elseif ElementNode.is_literal(component) then return "Literal" elseif t == "string" then return component else return string.format("UNKNOWN (%s %s)",t,tostring(component)) end end
local function set_Inline(value) Inline=value
inline_transpiled_location=get_function_location(Inline:transpile_decorator(function (props)  end)) end
local get_component_name=setmetatable({["set_Inline"] = set_Inline},{["__call"] = function (_,...) return actually_get_component_name(...) end})
return get_component_name