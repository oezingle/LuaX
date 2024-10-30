local table=require"ext.table"
local string=require"ext.string"
local class=require"ext.class"
local BaseAST=class()
function BaseAST:setspan(span) self.span=span
return self end
function BaseAST:ancestors() local n=self
local t=table()
repeat t:insert(n)
n=n.parent until  not n
return t end
return BaseAST