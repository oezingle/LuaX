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
local table_equals=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.table_equals"
local function use_state(default) local hookstate=LuaX._hookstate
local index=hookstate:get_index()
local value=hookstate:get_value(index)
if value == nil then value=default
hookstate:set_value_silent(index,value) end
local setter=function (cb_or_new_value) local new_value=nil
if type(cb_or_new_value) == "function" then new_value=cb_or_new_value(value) else new_value=cb_or_new_value end
if  not table_equals(value,new_value) then hookstate:set_value(index,new_value) end end
hookstate:set_index(index + 1)
return value,setter end
return use_state