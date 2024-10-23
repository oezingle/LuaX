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
local LuaXParser=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.parser.LuaXParser"
local transpile_cache={}
local cache={}
function cache.find(tag) return transpile_cache[tag] end
function cache.set(tag,output) transpile_cache[tag]=output end
function cache.get(tag,locals) local cached=cache.find(tag)
if cached then return cached end
local parser=LuaXParser.from_inline_string("return " .. tag):set_components(locals,"local")
local transpiled=parser:transpile()
cache.set(tag,transpiled)
return transpiled end
function cache.clear(tag) if tag then transpile_cache[tag]=nil else transpile_cache={} end end
return cache