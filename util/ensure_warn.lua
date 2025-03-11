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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.")
require(library_root .. "_shim") end
local table_pack=require"lib_LuaX.util.polyfill.table.pack"
local warn_enabled=false
local function test_control_flag(...) local arg1=({...})[1]
if arg1 == "@on" then warn_enabled=true
return false elseif arg1 == "@off" then warn_enabled=false end
return warn_enabled end
local function nocolor_warn(...) if test_control_flag(...) then print("Lua warning:",...) end end
local colors={["YELLOW"] = "\27[33m",["RESET"] = "\27[0m"}
local function color_warn(...) if test_control_flag(...) then io.stdout:write(colors.YELLOW)
io.stdout:write(table.concat(table_pack(...),"\9"))
io.stdout:write(colors.RESET,"\n") end end
local os_getenv=(os or {}).getenv
local function ensure_warn() if warn then return  end
local term=os_getenv and os_getenv"TERM" or ""
if term:match"xterm" then warn=color_warn else warn=nocolor_warn end end
return ensure_warn