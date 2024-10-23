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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.polyfill.path.")
require(library_root .. "_shim") end
local sep=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.polyfill.path.sep"
local function join(...) local elements=table.pack(...)
local ret={}
for i,item in ipairs(elements) do local is_first=i == 1
if item:sub(1,1) == sep and  not is_first then item=item:sub(2) end
if item:sub( - 1) == sep then item=item:sub(1, - 2) end
table.insert(ret,item) end
return table.concat(ret,sep) end
return join