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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.Renderer.helper.")
require(library_root .. "_shim") end



---@param child LuaX.ElementNode | nil
---@param container LuaX.NativeElement
---@param key LuaX.Key
local NativeElement=require"lib_LuaX.util.NativeElement.NativeElement"
local function can_modify_child(child,container,key) 
local existing_children=container:get_children_by_key(key)
if  not existing_children then return false,existing_children end

if  not existing_children.class then return false,existing_children end
---@type LuaX.NativeElement

local existing_child=existing_children
if  not child then return false,existing_children end

if  not existing_child.get_type then return false,existing_children end
if existing_child:get_type() ~= child.type then return false,existing_children end
return true,existing_child end
return can_modify_child