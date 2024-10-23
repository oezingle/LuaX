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
local NativeElement=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.NativeElement"
local NativeTextElement=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.NativeElement.NativeTextElement"
local string_split=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.polyfill.string.split"
local list_reduce=require"7b791f5a-9ab9-4f26-8ff8-7af2bb1b7b9b.util.polyfill.list.reduce"
local wibox=require"wibox"
local WiboxElement=NativeElement:extend"WiboxElement"
function WiboxElement:init(native,type) self.wibox=native
self.texts={}
self.signal_handlers={}
self.type=type end
function WiboxElement:set_prop(prop,value) local wibox=self.wibox
if prop:match"^LuaX::" then local prop_name=prop:sub(7)
if prop_name == "onload" then value(self,wibox) end elseif prop:match"^signal::" then local signal_name=prop:sub(9)
if value then wibox:weak_connect_signal(signal_name,value) end
self.signal_handlers[prop]=value else wibox[prop]=value end end
function WiboxElement:get_prop(prop) if self.signal_handlers[prop] then return self.signal_handlers[prop] end
return self.wibox[prop] end
function WiboxElement:insert_child(index,element,is_text) if is_text then table.insert(self.texts,index,element)
self:_reload_text() else if self.wibox.insert then self.wibox:insert(index,element.wibox) elseif self.wibox.get_children and self.wibox.set_children then local children=self.wibox:get_children()
table.insert(children,element.wibox)
self.wibox:set_children(children) else error(string.format("Unable to insert child with wibox %s",self.wibox)) end end end
function WiboxElement:delete_child(index,is_text) if is_text then table.remove(self.texts,index) else if self.wibox.remove then self.wibox:remove(index) elseif self.wibox.get_children and self.wibox.set_children then local children=self.wibox:get_children()
table.remove(children,index)
self.wibox:set_children(children) else error(string.format("Unable to insert child with wibox %s",self.wibox)) end end end
function WiboxElement:get_type() return self.type end
function WiboxElement.create_element(component) local wibox_name=string.sub(component,7)
local fields=string_split(wibox_name,"%.")
local widget_type=list_reduce(fields,function (object,key) return object[key] end,wibox)
local widget=wibox.widget{["widget"] = widget_type}
return WiboxElement(widget,component) end
function WiboxElement.get_root(native) return WiboxElement(native,"UNKNOWN (root element)") end
function WiboxElement:_reload_text() local texts={}
for _,text_element in ipairs(self.texts) do table.insert(texts,text_element.value) end
local text=table.concat(texts,"")
self:set_prop("text",text) end
local WiboxText=NativeTextElement:extend"WiboxText"
function WiboxText:set_value(value) self.value=value
self.parent:_reload_text() end
function WiboxText:get_prop(prop) if prop ~= "value" then return nil end
return self.value end
function WiboxElement.create_literal(value,parent) return WiboxText(value,parent) end
return WiboxElement