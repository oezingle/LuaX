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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.debug.")
require(library_root .. "_shim") end
local get_function_name=require"lib_LuaX.util.debug.get_function_name"
local function get_nth_caller(n) local info=debug.getinfo(2 + n,"Sl")
if info.source == "[C]" then return "[C]" end
local src=info.source:sub(2) .. ":" .. tostring(info.linedefined)
local name=get_function_name(src)
return (name or src) .. " (line " .. tostring(info.currentline) .. ")" end
return get_nth_caller