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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.parser.loader.")
require(library_root .. "_shim") end
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local sep=require"lib_LuaX.util.polyfill.path.sep"
local function luax_loader(modulename) local modulepath=string.gsub(modulename,"%.",sep)
local match_module_files="." .. sep .. "?.luax;." .. sep .. "?" .. sep .. "init.luax"
for path in string.gmatch(match_module_files,"([^;]+)") do local filename=string.gsub(path,"%?",modulepath)
local file=io.open(filename,"r")
if file then local content=file:read"a"
local parser=LuaXParser.from_file_content(content,filename)
local transpiled=parser:transpile()
local get_module,err=load(transpiled,filename)
if  not get_module then error(err) end
return get_module end end
return string.format("No LuaX module found for %s",modulename) end
return luax_loader