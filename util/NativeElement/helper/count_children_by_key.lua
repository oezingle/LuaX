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
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
local key_first=require"lib_LuaX.util.key.key_first"


---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
local VirtualElement=require"lib_LuaX.util.NativeElement.VirtualElement"
local function count_children_by_key(children_by_key,key) 
local count=0
local first,restkey=key_first(key)
for index,child in ipairs_with_nil(children_by_key,first) do if child then if child.class then if child.class ~= VirtualElement then count=count + 1 end else 

local pass_key=index == first
local passed_key=pass_key and restkey or {}
count=count + count_children_by_key(child,passed_key) end end end
return count end
return count_children_by_key