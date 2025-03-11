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
local NativeElement=require"lib_LuaX.util.NativeElement"
local NativeTextElement=require"lib_LuaX.util.NativeElement.NativeTextElement"
local js=require"js"
local document=js.global.document
local null=js.null
local WebElement=NativeElement:extend"WebElement (fengari)"
function WebElement:init(node) self.node=node
self.events_registered={}
self.event_listeners={} end
function WebElement:get_trailing_children(index) local children=self.node.childNodes
local after={}
for i = index, # children do local child=children[i]
table.insert(after,child)
child:remove() end
return after end
function WebElement:reinsert_trailing_children(list) for _,child in ipairs(list) do self.node:append(child) end end
function WebElement:insert_child(index,element) local trailing=self:get_trailing_children(index)
self.node:append(element.node)
self:reinsert_trailing_children(trailing) end
function WebElement:delete_child(index) local child=self.node.childNodes[index]
child:remove() end
function WebElement:set_prop(prop,value) if prop:sub(1,2) == "on" and type(value) == "function" then local event=prop:sub(3)
if  not self.events_registered[event] then local listeners=self.event_listeners
self.node:addEventListener(event,function (e) local listener=listeners[event]
if listener then listener(e) end end)
self.events_registered[event]=true end
self.event_listeners[event]=value else self.node:setAttribute(prop,value) end end
function WebElement:get_prop(prop) return self.node.attributes[prop] end
function WebElement.get_root(native) assert(native ~= null,"WebElement root may not be null")
return WebElement(native) end
function WebElement:get_native() return self.node end
function WebElement.create_element(name) local node=document:createElement(name)
return WebElement(node) end
local WebText=NativeTextElement:extend"WebText"
function WebText:init(node) self.node=node end
function WebText:set_value(value) self.node.data=value end
function WebText:get_value() return self.node.data end
function WebElement.create_literal(value) local node=document:createTextNode(value)
return WebText(node) end
return WebElement