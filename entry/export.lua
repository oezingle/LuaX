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
local library_root=folder_of_this_file:sub(1, - 1 -  # "entry.")
require(library_root .. "_shim") end
local Inline=require"lib_LuaX.util.parser.Inline"
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local runtime=require"lib_LuaX.entry.runtime"
local _VERSION="0.5.0"
local export={["NativeElement"] = require"lib_LuaX.util.NativeElement",["NativeTextElement"] = require"lib_LuaX.util.NativeElement.NativeTextElement",["register"] = require"lib_LuaX.util.parser.loader.register",["Parser"] = LuaXParser,["transpile"] = {["from_path"] = function (path) return LuaXParser.from_file_path(path):transpile() end,["from_string"] = function (content,source) return LuaXParser.from_file_content(content,source):transpile() end,["inline"] = function (tag) return Inline:transpile(tag) end},["_VERSION"] = _VERSION}
for k,v in pairs(runtime) do export[k]=v end
local element_implementations={["WiboxElement"] = function () return require"lib_LuaX.util.NativeElement.WiboxElement" end,["GtkElement"] = function () return require"lib_LuaX.util.NativeElement.GtkElement" end,["WebElement"] = function () return require"lib_LuaX.util.NativeElement.WebElement" end}
setmetatable(export,{["__call"] = function (t,tag) return t.transpile.inline(tag) end,["__index"] = function (_,k) local implementation=element_implementations[k]
if implementation then return implementation() end end})
local ensure_warn=require"lib_LuaX.util.ensure_warn"
ensure_warn()
return export