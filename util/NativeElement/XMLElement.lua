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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.NativeElement.")
require(library_root .. "_shim") end
local NativeElement=require"lib_LuaX.util.NativeElement.NativeElement"
local split=require"lib_LuaX.util.polyfill.string.split"
local ElementNode=require"lib_LuaX.util.ElementNode"
local XMLElement=NativeElement:extend"XMLElement"
function XMLElement:init(native) self.type=native.type
self.props=native.props
self.children=native.children end
function XMLElement.create_element(element_type) return XMLElement{["type"] = element_type,["props"] = {},["children"] = {}} end
function XMLElement:set_prop(prop,value) self.props[prop]=value end
function XMLElement:insert_child(index,element) table.insert(self.children,index,element) end
function XMLElement:delete_child(index) table.remove(self.children,index) end
function XMLElement.get_root(xml) return XMLElement(xml or {["type"] = "ROOT",["props"] = {},["children"] = {}}) end
function XMLElement:get_type() return self.type end
function XMLElement:__tostring() if ElementNode.is_literal(self.type) then return tostring(self.props.value) end
local type=self.type
local props={}
for prop,value in pairs(self.props or {}) do local prop_str=string.format("%s=\"%s\"",prop,tostring(value))
table.insert(props,prop_str) end
local props_str=table.concat(props," ")
if  # self.children == 0 then return string.format("<%s %s/>",type,props_str) end
local children={}
for _,child in ipairs(self.children) do local child_strings=split(tostring(child),"\n")
for _,child_string in ipairs(child_strings) do table.insert(children,"\9" .. child_string) end end
return string.format("<%s %s>\n%s\n</%s>",type,props_str,table.concat(children,"\n"),type) end
return XMLElement