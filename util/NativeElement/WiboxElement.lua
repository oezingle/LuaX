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
local string_split=require"lib_LuaX.util.polyfill.string.split"
local list_reduce=require"lib_LuaX.util.polyfill.list.reduce"
local wibox=require"wibox"
local WiboxElement=NativeElement:extend"WiboxElement"
WiboxElement.widgets={["wibox"] = {["container"] = wibox.container,["layout"] = wibox.layout,["widget"] = wibox.widget,["mod"] = {}}}
function WiboxElement:init(native,type) self.widget=native
self.texts={}
self.signal_handlers={}
self.has_had_onload=false
self.type=type end
function WiboxElement:set_prop(prop,value) local widget=self.widget
if prop:match"^LuaX::" then local prop_name=prop:sub(7)
if prop_name == "onload" and  not self.has_had_onload then value(self,widget)
self.has_had_onload=true end elseif prop:match"^signal::" then local signal_name=prop:sub(9)
if value then widget:weak_connect_signal(signal_name,value) end
self.signal_handlers[prop]=value else widget[prop]=value end end
function WiboxElement:get_prop(prop) if self.signal_handlers[prop] then return self.signal_handlers[prop] end
return self.widget[prop] end
function WiboxElement:insert_child(index,element,is_text) if is_text then table.insert(self.texts,index,element)
self:_reload_text() else if self.widget.insert then self.widget:insert(index,element.widget) elseif self.widget.get_children and self.widget.set_children then local children=self.widget:get_children()
table.insert(children,element.widget)
self.widget:set_children(children) else error(string.format("Unable to insert child to wibox %s",self.widget)) end end end
function WiboxElement:delete_child(index,is_text) if is_text then table.remove(self.texts,index) else if self.widget.remove then self.widget:remove(index) elseif self.widget.get_children and self.widget.set_children then local children=self.widget:get_children()
table.remove(children,index)
self.widget:set_children(children) else error(string.format("Unable to insert child with wibox %s",self.widget)) end end end
function WiboxElement:get_type() return self.type end
function WiboxElement.create_element(element_name) local fields=string_split(element_name,"%.")
local widget_type=list_reduce(fields,function (object,key) return object[key] end,WiboxElement.widgets)
assert(widget_type,string.format("No widget known by name %q",element_name))
local widget=wibox.widget{["widget"] = widget_type}
return WiboxElement(widget,element_name) end
function WiboxElement.get_root(native) return WiboxElement(native,"UNKNOWN (root element)") end
function WiboxElement:_reload_text() local texts={}
for _,text_element in ipairs(self.texts) do table.insert(texts,text_element.value) end
local text=table.concat(texts,"")
self:set_prop("text",text) end
local WiboxText=NativeTextElement:extend"WiboxText"
function WiboxText:set_value(value) self.value=value
self.parent:_reload_text() end
function WiboxText:get_value() return self.value end
function WiboxElement.create_literal(value,parent) return WiboxText(value,parent) end
function WiboxElement.rebuild_component_list() local components={}
for provider,widget_types in pairs(WiboxElement.widgets) do for widget_type,widgets in pairs(widget_types) do for widget_name,widget in pairs(widgets) do local widget_full_name=table.concat({provider,widget_type,widget_name},".")
if type(widget) == "function" and widget_type == "mod" then table.insert(components,widget_full_name) end
if type(widget) == "table" and widget_name ~= "base" then if (getmetatable(widget) or {}).__call then table.insert(components,widget_full_name) elseif widget.horizontal and widget.vertical then table.insert(components,widget_full_name .. ".horizontal")
table.insert(components,widget_full_name .. ".vertical") elseif widget.month and widget.year then table.insert(components,widget_full_name .. ".month")
table.insert(components,widget_full_name .. ".year") else (widget_type == "mod" and error or warn)(string.format("Widget %s has no __call or horizontal/vertical",widget_full_name)) end end end end end
WiboxElement.components=components end
WiboxElement.rebuild_component_list()
function WiboxElement.add_mod(name,widget) if name:match"[%s.]" then error"wibox mod names may not contain whitespace, or the period character" end
WiboxElement.widgets.wibox.mod[name]=widget
WiboxElement.rebuild_component_list() end
return WiboxElement