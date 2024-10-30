local table=require"ext.table"
local function newmember(class,...) local obj=setmetatable({},class)
if obj.init then return obj,obj:init(...) end
return obj end
local classmeta={["__call"] = function (self,...) return self:new(...) end}
local function isa(cl,obj) assert(cl,"isa: argument 1 is nil, should be the class object")
if type(obj) ~= "table" then return false end
if  not obj.isaSet then return false end
return obj.isaSet[cl] or false end
local function class(...) local cl=table(...)
cl.class=cl
cl.super=...
cl.isaSet={[cl] = true}
for i = 1,select("#",...) do local parent=select(i,...)
if parent ~= nil then cl.isaSet[parent]=true
if parent.isaSet then for grandparent,_ in pairs(parent.isaSet) do cl.isaSet[grandparent]=true end end end end
for ancestor,_ in pairs(cl.isaSet) do ancestor.descendantSet=ancestor.descendantSet or {}
ancestor.descendantSet[cl]=true end
cl.__index=cl
cl.new=newmember
cl.isa=isa
cl.subclass=class
setmetatable(cl,classmeta)
return cl end
return class