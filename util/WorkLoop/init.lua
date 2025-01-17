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
---@nospec
local class=require"lib_LuaX._dep.lib.30log"
---@class LuaX.WorkLoop : Log.BaseFunctions
---@field protected list_dequue fun(self: self): function
---@field protected list LinkedList<function>
---@field protected list_enqueue fun(self: self, cb: function)
---@field protected list_is_empty fun(self: self): boolean


---@field is_running boolean
---@field start fun(self: self) Must not crash if double-started. write yourself a guard.


---@field add fun(self: self, cb: function)
local LinkedList=require"lib_LuaX.util.LinkedList"
local WorkLoop=class"WorkLoop"
function WorkLoop:init() self.list=LinkedList() end
function WorkLoop:list_dequue() return self.list:dequeue() end
function WorkLoop:list_enqueue(cb) self.list:enqueue(cb) end
function WorkLoop:list_is_empty() return self.list:is_empty() end
function WorkLoop:add(cb) self:list_enqueue(cb) end
return WorkLoop