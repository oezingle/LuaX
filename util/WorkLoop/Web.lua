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
local WorkLoop=require"lib_LuaX.util.WorkLoop.WorkLoop"
local js=require"js"
local setInterval=js.global.setInterval
local clearInterval=js.global.clearInterval
local WebWorkLoop=WorkLoop:extend"WebWorkLoop"
function WebWorkLoop:start() self.interval=setInterval(function () self:run_once() end, - 1) end
function WebWorkLoop:stop() clearInterval(self.interval)
self.interval=nil
self.is_running=false end
return WebWorkLoop