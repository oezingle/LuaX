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
local library_root=folder_of_this_file:sub(1, - 1 -  # "components.")
require(library_root .. "_shim") end
local DrawGroup=require"lib_LuaX.util.Renderer.DrawGroup"
local RenderInfo=require"lib_LuaX.util.Renderer.RenderInfo"
local NativeTextElement=require"lib_LuaX.util.NativeElement.NativeTextElement"
local VirtualElement=require"lib_LuaX.util.NativeElement.VirtualElement"
local traceback=require"lib_LuaX.util.debug.traceback"
local use_effect=require"lib_LuaX.hooks.use_effect"
local use_state=require"lib_LuaX.hooks.use_state"
local use_memo=require"lib_LuaX.hooks.use_memo"
local create_element=require"lib_LuaX.create_element"
local no_op=function ()  end
local function Suspense(props) local complete,set_complete=use_state(false)
local info=use_memo(function () local info=RenderInfo.clone(RenderInfo.current)
local group=DrawGroup.create(info.draw_group.on_error,function () set_complete(true) end,function () set_complete(false) end)
info.draw_group=group
return info end,{})
local key=info.key
local container=info.container
local renderer=info.renderer
local clone=use_memo(function () local ok,ret=xpcall(container:get_class().get_root,traceback)
if  not ok then error("Looks like this NativeElement implementation doesn't support nil root elements. This is required for Suspense to work. " .. tostring(ret)) end
local instance=ret
instance.insert_child=no_op
instance.delete_child=no_op
return instance end,{container})
use_effect(function () renderer.workloop:add(renderer.render_keyed_child,renderer,props.children,clone,key,info)
renderer.workloop:safely_start() end,{renderer,props.children,clone,key,info})
use_effect(function () local children=container:flatten_children(key)
local delete_index=container:count_children_by_key(key)
for i =  # children,1, - 1 do local child=children[i].element
if child.class ~= VirtualElement then local is_text=NativeTextElement:classOf(child.class) or false
container:delete_child(delete_index,is_text)
delete_index=delete_index - 1 end end
container:set_child_by_key(key,nil)
if complete then local children=clone:flatten_children(key)
for _,child in ipairs(children) do container:insert_child_by_key(child.key,child.element) end end end,{complete,container,clone,key})
if complete then return props.children else local fallback=props.fallback
if type(fallback) == "string" or type(fallback) == "function" then return create_element(fallback,{}) else return fallback end end end
return Suspense