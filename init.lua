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
local Inline=require"lib_LuaX.util.parser.Inline"
local LuaXParser=require"lib_LuaX.util.parser.LuaXParser"
local ensure_warn=require"lib_LuaX.util.ensure_warn"
local _VERSION="0.4.0"

ensure_warn()
if table.pack(...)[1] ~= (arg or {})[1] then 
---@class LuaX.Exported

---@field Renderer LuaX.Renderer
---@field Children LuaX.Children
---@field NativeElement LuaX.NativeElement
---@field create_element fun(type: LuaX.Component, props: LuaX.Props): LuaX.ElementNode
---@field clone_element (fun(element: LuaX.ElementNode, props: LuaX.Props): LuaX.ElementNode) | (fun(element: LuaX.ElementNode[], props: LuaX.Props): LuaX.ElementNode[])

---@field Fragment LuaX.Component
---@field Portal LuaX.Portal


---@field use_context LuaX.Hooks.UseContext
---@field use_effect LuaX.Hooks.UseEffect
---@field use_memo LuaX.Hooks.UseMemo
---@field use_portal LuaX.Hooks.UsePortal
---@field use_ref LuaX.Hooks.UseRef
---@field use_state LuaX.Hooks.UseState

---@field register fun() Register the LuaX loader
---@field Parser LuaX.Parser.V3
---@field transpile { from_path: (fun(path: string): string), from_string: (fun(content: string, source?: string): string)}

---@operator call:function 
---@param path string
---@param content string
---@param source string?
local export={["Renderer"] = require"lib_LuaX.util.Renderer",["NativeElement"] = require"lib_LuaX.util.NativeElement",["Children"] = require"lib_LuaX.Children",["Context"] = require"lib_LuaX.Context",["Portal"] = require"lib_LuaX.Portal",["create_element"] = require"lib_LuaX.create_element",["clone_element"] = require"lib_LuaX.clone_element",["Fragment"] = require"lib_LuaX.components.Fragment",["use_context"] = require"lib_LuaX.hooks.use_context",["use_effect"] = require"lib_LuaX.hooks.use_effect",["use_memo"] = require"lib_LuaX.hooks.use_memo",["use_portal"] = require"lib_LuaX.hooks.use_portal",["use_ref"] = require"lib_LuaX.hooks.use_ref",["use_state"] = require"lib_LuaX.hooks.use_state",["register"] = require"lib_LuaX.util.parser.loader.register",["Parser"] = LuaXParser,["transpile"] = {["from_path"] = function (path) return LuaXParser.from_file_path(path):transpile() end,["from_string"] = function (content,source) return LuaXParser.from_file_content(content,source):transpile() end,["inline"] = function (tag) return Inline:transpile(tag) end},["__from_cli"] = require"lib_LuaX.cmd.cmd",["_VERSION"] = _VERSION}
export.create_context=export.Context.create
export.create_portal=export.Portal.create
setmetatable(export,{["__call"] = function (table,tag) return table.transpile.inline(tag) end})
if  not LuaX or  not next(LuaX) then ---@class LuaX : LuaX.Exported
---@field _hookstate LuaX.HookState

LuaX=export end
return export else local cmd=require"lib_LuaX.cmd.cmd"
cmd() end