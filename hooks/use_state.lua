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
local HookState=require"lib_LuaX.util.HookState"
local function use_state(default) local hookstate=HookState.global.get(true)
local index=hookstate:get_index()
local state=hookstate:get_value(index)
hookstate:increment()
if state == nil then if type(default) == "function" then default=default() end
local setter=function (new_value) local state=hookstate:get_value(index)
if type(new_value) == "function" then new_value=new_value(state[1]) end
if  not deep_equals(state[1],new_value,2) then state[1]=new_value
hookstate:modified(index,state) end end
state={default,setter}
hookstate:set_value_silent(index,state) end
return state[1],state[2] end
return use_state