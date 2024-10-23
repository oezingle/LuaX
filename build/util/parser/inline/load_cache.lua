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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.inline.")
require(library_root .. "_shim") end
local table_equals=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.table_equals"
local LuaXParser=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.LuaXParser"
local load_cache={}
local cache={}
function cache.find(code,env) local cached=load_cache[code]
if  not cached then return nil end
for k,v in pairs(env) do if  not table_equals(v,cached.env[k]) then return nil end end
return cached.old end
function cache.set(code,env,output) load_cache[code]={["env"] = env,["old"] = output} end
function cache.get(code,env,src_name) local cached=cache.find(code,env)
if cached then return cached end
local chunkname="inline LuaX code"
if src_name then chunkname=chunkname .. " " .. src_name end
local get_output,err=load(code,chunkname,nil,env)
if  not get_output then warn"Code passed in:"
print(code)
error(err) end
local output=get_output()
cache.set(code,env,output)
return output end
function cache.clear(code) if code then load_cache[code]=nil else load_cache={} end end
return cache