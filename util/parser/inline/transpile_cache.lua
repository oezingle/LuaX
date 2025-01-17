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

local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local transpile_cache={}
---@param tag string
local cache={}
function cache.find(tag) return transpile_cache[tag] end
---@param tag string
---@param output string
function cache.set(tag,output) transpile_cache[tag]=output end





---@param tag string
---@param locals table<string, any>
---@return string
function cache.get(tag,locals) local cached=cache.find(tag)
if cached then return cached end
local transpiled=LuaXParser.from_inline_string("return " .. tag):handle_variables_as_table(locals):set_components(locals,"local"):transpile()
cache.set(tag,transpiled)
return transpiled end
---@param tag string?
function cache.clear(tag) if tag then transpile_cache[tag]=nil else transpile_cache={} end end
return cache