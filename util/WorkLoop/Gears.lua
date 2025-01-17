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
local WorkLoop=require"lib_LuaX.util.WorkLoop"
---@class LuaX.WorkLoop.Gears : LuaX.WorkLoop
local gears=require"gears"
local GearsWorkLoop=WorkLoop:extend"GearsWorkLoop"
function GearsWorkLoop:init() ---@diagnostic disable-next-line:undefined-field
self.super:init()
self.timer=gears.timer{["timeout"] = 0.01,["single_shot"] = false,["callback"] = function () self:run_once() end} end
function GearsWorkLoop:run_once() if self:list_is_empty() then self.is_running=false
self.timer:stop()
return  end
local cb=self:list_dequue()
cb() end
function GearsWorkLoop:start() if self.is_running then return  end
self.is_running=true
self.timer:start() end
return GearsWorkLoop