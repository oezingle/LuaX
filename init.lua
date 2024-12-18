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
local library_root=folder_of_this_file:sub(1, - 1 -  # "")
require(library_root .. "_shim") end
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"

local _VERSION="0.3.6-dev"
if table.pack(...)[1] ~= (arg or {})[1] then 
---@class LuaX.Exported
---@field Renderer LuaX.Renderer
---@field Fragment LuaX.Component
---@field create_element fun(type: LuaX.Component, props: LuaX.Props): LuaX.ElementNode
---@field clone_element (fun(element: LuaX.ElementNode, props: LuaX.Props): LuaX.ElementNode) | (fun(element: LuaX.ElementNode[], props: LuaX.Props): LuaX.ElementNode[])

---@field use_state any
---@field use_effect any
---@field use_memo any
---@field use_ref any
---@field register fun() Register the LuaX loader
---@param path string
---@param content string
---@param source string?
local export={["Renderer"] = require"lib_LuaX.util.Renderer",["Fragment"] = require"lib_LuaX.components.Fragment",["create_element"] = require"lib_LuaX.create_element",["clone_element"] = require"lib_LuaX.clone_element",["use_state"] = require"lib_LuaX.hooks.use_state",["use_effect"] = require"lib_LuaX.hooks.use_effect",["use_memo"] = require"lib_LuaX.hooks.use_memo",["use_ref"] = require"lib_LuaX.hooks.use_ref",["register"] = require"lib_LuaX.util.parser.loader.register",["Parser"] = LuaXParser,["transpile"] = {["from_path"] = function (path) return LuaXParser.from_file_path(path):transpile() end,["from_string"] = function (content,source) return LuaXParser.from_file_content(content,source):transpile() end,["inline"] = require"lib_LuaX.util.parser.inline"},["__from_cli"] = require"lib_LuaX.cmd.cmd",["_VERSION"] = _VERSION}
setmetatable(export,{["__call"] = function (table,tag) return table.transpile.inline(tag) end})
if  not LuaX or  not next(LuaX) then ---@class LuaX : LuaX.Exported
---@field _hookstate LuaX.HookState
LuaX=export end
return export else local cmd=require"lib_LuaX.cmd.cmd"
cmd() end