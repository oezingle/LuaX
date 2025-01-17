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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.WorkLoop.")
require(library_root .. "_shim") end
---@class LuaX.DefaultWorkLoop : LuaX.WorkLoop
local WorkLoop=require"lib_LuaX.util.WorkLoop"
---@param opts { supress_warning?: boolean }
local DefaultWorkLoop=WorkLoop:extend"DefaultWorkLoop"
function DefaultWorkLoop:init(opts) opts=opts or {}
if  not opts.supress_warning then warn("LuaX Renderer is using a default (synchronous) work loop! " .. "This is not recommended as it will freeze " .. "the main thread until rendering is done.") end
---@diagnostic disable-next-line:undefined-field
self.super:init() end
function DefaultWorkLoop:add(cb) self:list_enqueue(cb) end
function DefaultWorkLoop:start() 
if self.is_running then return  end
self.is_running=true
while self.is_running do self:run_once() end end
function DefaultWorkLoop:run_once() if self:list_is_empty() then self.is_running=false
return  end
local cb=self:list_dequue()
cb() end
return DefaultWorkLoop