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
local class=require"lib_LuaX._dep.lib.30log"
local table_pack=require"lib_LuaX.util.polyfill.table.pack"
local table_unpack=require"lib_LuaX.util.polyfill.table.unpack"
local DrawGroup=require"lib_LuaX.util.Renderer.DrawGroup"
local traceback=require"lib_LuaX.util.debug.traceback"
local WorkLoop=class"WorkLoop"
function WorkLoop:init() self.list={}
self.head=0
self.tail=0 end
function WorkLoop:list_dequue() self.head=self.head + 1
local ret=self.list[self.head]
self.list[self.head]=nil
return ret end
function WorkLoop:list_enqueue(...) local item=table_pack(...)
self.tail=self.tail + 1
self.list[self.tail]=item end
function WorkLoop:list_is_empty() return self.tail - self.head == 0 end
function WorkLoop:add(cb,...) self:list_enqueue(cb,...) end
function WorkLoop:stop() self.is_running=false end
function WorkLoop:run_once() if self:list_is_empty() then self:stop()
return  end
local item=self:list_dequue()
local cb=item[1]
local upper=jit and 10 or nil
local ok,err=xpcall(cb,traceback,table_unpack(item,2,upper))
if  not ok then ok=pcall(DrawGroup.error,nil,err) end
if  not ok then error("DrawGroup error handler failed.\n" .. err) end end
function WorkLoop:safely_start() if self.is_running then return  end
self.is_running=true
self:start() end
return WorkLoop