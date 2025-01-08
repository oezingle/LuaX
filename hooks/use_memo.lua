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
local HookState=require"lib_LuaX.util.HookState"
---@alias LuaX.Hooks.UseMemo.State { deps: any[], cached: any }
---@generic T
---@alias LuaX.Hooks.UseMemo fun (callback: (fun(): T), deps: any[]): T
---@generic T
---@param callback fun(): T
---@param deps any[]
---@return T
local table_equals=require"lib_LuaX.util.table_equals"
local function use_memo(callback,deps) local hookstate=HookState.global.get(true)
local index=hookstate:get_index()

local last_value=hookstate:get_value(index) or {}
local last_deps=last_value.deps
local memo_value=last_value.cached
if  not table_equals(deps,last_deps,2) then 

local new_value={["deps"] = deps}
hookstate:set_value_silent(index,new_value)
memo_value=callback()
new_value.cached=memo_value
hookstate:set_value(index,new_value) end
hookstate:increment()
return memo_value end
return use_memo