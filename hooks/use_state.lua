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
local library_root=folder_of_this_file:sub(1, - 1 -  # "hooks.")
require(library_root .. "_shim") end
local deep_equals=require"lib_LuaX.util.deep_equals"
---@alias LuaX.Hooks.UseState.Dispatch<R> fun(new_value: R | (fun(old: R): R))
---@generic T
---@alias LuaX.Hooks.UseState fun(default?: T): T, LuaX.Hooks.UseState.Dispatch<T>
---@generic T
---@param default T?
---@return T, LuaX.Hooks.UseState.Dispatch<T>
local HookState=require"lib_LuaX.util.HookState"
local function use_state(default) local hookstate=HookState.global.get(true)
local index=hookstate:get_index()
local value=hookstate:get_value(index)
if value == nil then if type(default) == "function" then default=default() end
value=default
hookstate:set_value_silent(index,value) end

local setter=function (cb_or_new_value) local new_value=nil
if type(cb_or_new_value) == "function" then new_value=cb_or_new_value(value) else new_value=cb_or_new_value end


if type(new_value) == "function" or  not deep_equals(value,new_value,2) then 
value=new_value
hookstate:set_value(index,new_value) end end
hookstate:increment()
return value,setter end
return use_state