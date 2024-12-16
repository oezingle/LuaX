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
---@alias LuaX.UseEffectState { deps: any[]?, on_remove: function? }
---@param callback fun(): function?
---@param deps any[]?
local table_equals=require"lib_LuaX.util.table_equals"
local function use_effect(callback,deps) local hookstate=LuaX._hookstate
local index=hookstate:get_index()

local old_value=hookstate:get_value(index) or {}
local old_deps=old_value.deps
local on_remove=old_value.on_remove
if  not deps or  not table_equals(deps,old_deps,false) then 
hookstate:set_value_silent(index,{["deps"] = deps})
if on_remove then on_remove() end

local callback_result=callback()
hookstate:get_value(index).on_remove=callback_result end
hookstate:set_index(index + 1) end
return use_effect