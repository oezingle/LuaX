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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.Renderer.")
require(library_root .. "_shim") end
local RenderInfo=require"lib_LuaX.util.Renderer.RenderInfo"
local DrawGroup={}
function DrawGroup.create(on_error,on_complete,on_restart) return {["refs"] = 0,["on_error"] = on_error,["on_complete"] = on_complete,["on_restart"] = on_restart} end
function DrawGroup.ref(group) group.refs=group.refs + 1
if group.refs <= 1 then group.on_restart() end end
function DrawGroup.unref(group) group.refs=group.refs - 1
if group.refs <= 0 then group.on_complete() end end
function DrawGroup.current() local info=RenderInfo.get()
if  not info then return nil end
return info.draw_group end
function DrawGroup.error(group,...) group=group or DrawGroup.current()
if group then group.on_error(...) else error(...) end end
return DrawGroup