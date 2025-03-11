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
local library_root=folder_of_this_file:sub(1, - 1 -  # "components.")
require(library_root .. "_shim") end
local use_effect=require"lib_LuaX.hooks.use_effect"
local use_state=require"lib_LuaX.hooks.use_state"
local RenderInfo=require"lib_LuaX.util.Renderer.RenderInfo"
local DrawGroup=require"lib_LuaX.util.Renderer.DrawGroup"
local create_element=require"lib_LuaX.create_element"
local function ErrorBoundary(props) local err,set_err=use_state(nil)
use_effect(function () local info=RenderInfo.get()
local old_group=info.draw_group
DrawGroup.ref(old_group)
local group=DrawGroup.create(function (e) set_err(e) end,function () DrawGroup.unref(old_group) end,function () DrawGroup.ref(old_group) end)
info.draw_group=group end,{})
if err then local fallback=props.fallback
if type(fallback) == "string" or type(fallback) == "function" then return create_element(fallback,{["error"] = err}) else return fallback end else return props.children end end
return ErrorBoundary