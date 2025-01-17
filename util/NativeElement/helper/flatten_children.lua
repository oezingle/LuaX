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
local key_add=require"lib_LuaX.util.key.key_add"
---@param children_by_key LuaX.NativeElement.ChildrenByKey
---@param key LuaX.Key
---@param elements { element: LuaX.NativeElement, key: LuaX.Key }[]?
local ipairs_with_nil=require"lib_LuaX.util.ipairs_with_nil"
local function flatten_children(children_by_key,key,elements) elements=elements or {}
if  not children_by_key then  elseif children_by_key.class then 
table.insert(elements,{["key"] = key,["element"] = children_by_key}) else for i,entry in ipairs_with_nil(children_by_key) do local new_key=key_add(key,i)
flatten_children(entry,new_key,elements) end end
return elements end
return flatten_children