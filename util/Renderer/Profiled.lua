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

---@nospec
local Renderer=require"lib_LuaX.util.Renderer"
---@class LuaX.ProfiledRenderer : LuaX.Renderer
---@field profiler LuaX.Profiler
---@operator call:LuaX.ProfiledRenderer
local Profiler=require"lib_LuaX.util.Profiler"
local ProfiledRenderer=Renderer:extend"ProfiledRenderer"
function ProfiledRenderer:init(workloop) ---@diagnostic disable-next-line:assign-type-mismatch
self:set_workloop(workloop)
self.profiler=Profiler()
self.profiler:start() end
function ProfiledRenderer:render_keyed_child(element,container,key,caller) 
---@diagnostic disable-next-line:undefined-field
return self.super.render_keyed_child(self,element,container,key,caller) end
---@param filename string?
function ProfiledRenderer:dump(filename) self.profiler:stop()
self.profiler:dump(filename or "callgrind.out.luax","KCacheGrind") end
return ProfiledRenderer