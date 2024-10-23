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
local class=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b._dep.lib.30log"
local LinkedList=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.LinkedList"
local WorkLoop=class"WorkLoop"
function WorkLoop:init() self.list=LinkedList() end
function WorkLoop:list_dequue() return self.list:dequeue() end
function WorkLoop:list_enqueue(cb) self.list:enqueue(cb) end
function WorkLoop:list_is_empty() return self.list:is_empty() end
function WorkLoop:add(cb) self:list_enqueue(cb) end
return WorkLoop