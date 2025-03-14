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
local library_root=folder_of_this_file:sub(1, - 1 -  # "entry.")
require(library_root .. "_shim") end
local _VERSION="0.5.2"
local runtime={["Renderer"] = require"lib_LuaX.util.Renderer",["Children"] = require"lib_LuaX.Children",["create_element"] = require"lib_LuaX.create_element",["clone_element"] = require"lib_LuaX.clone_element",["Fragment"] = require"lib_LuaX.components.Fragment",["Suspense"] = require"lib_LuaX.components.Suspense",["ErrorBoundary"] = require"lib_LuaX.components.ErrorBoundary",["Context"] = require"lib_LuaX.Context",["Portal"] = require"lib_LuaX.Portal",["use_callback"] = require"lib_LuaX.hooks.use_callback",["use_context"] = require"lib_LuaX.hooks.use_context",["use_effect"] = require"lib_LuaX.hooks.use_effect",["use_memo"] = require"lib_LuaX.hooks.use_memo",["use_portal"] = require"lib_LuaX.hooks.use_portal",["use_ref"] = require"lib_LuaX.hooks.use_ref",["use_state"] = require"lib_LuaX.hooks.use_state",["use_suspense"] = require"lib_LuaX.hooks.use_suspense",["_VERSION"] = _VERSION}
setmetatable(runtime,{["__call"] = function (_,...) return ... end})
runtime.create_context=runtime.Context.create
runtime.create_portal=runtime.Portal.create
return runtime