local RenderInfo={}
function RenderInfo.inherit(new,old) new=new
old=old or RenderInfo.get()
if  not old then return new end
local old_context=old.context
new.context=new.context or {}
local new_context=new.context
for k,v in pairs(old_context) do new_context[k]=v end
new.draw_group=old.draw_group
return new end
function RenderInfo.get() return RenderInfo.current end
function RenderInfo.set(info) local old=RenderInfo.get()
RenderInfo.current=info
return old end
function RenderInfo.bind(props,info) props.__luax_internal={info.context}
return props end
function RenderInfo.clone(info) local ret={}
for k,v in pairs(info) do ret[k]=v end
return ret end
return RenderInfo