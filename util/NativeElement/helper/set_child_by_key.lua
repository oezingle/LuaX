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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.NativeElement.helper.")
require(library_root .. "_shim") end
local key_first=require"lib_LuaX.util.key.key_first"
local function set_child_by_key(children_by_key,key,child) local first,restkey=key_first(key)
if children_by_key.class then error"set_child_by_key found a NativeElement when it expected an array!" end
if  # restkey == 0 then children_by_key[first]=child else if  not children_by_key[first] then children_by_key[first]={} end
set_child_by_key(children_by_key[first],restkey,child) end end
return set_child_by_key