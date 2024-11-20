local class=require"ext.class"
local tolua=require"ext.tolua"
local Parser=class()
function Parser:init(data,...) if data then self:setData(data,...) end end
function Parser:setData(data) assert(data,"expected data")
data=tostring(data)
local t=self:buildTokenizer(data)
t:start()
self.t=t
assert(xpcall(function () self.tree=self:parseTree() end,function (err) return err .. "\n" .. self.t:getpos() .. "\n" .. debug.traceback() end))
self.ast.refreshparents(self.tree)
if self.t.token then error("expected eof, found " .. self.t.token .. "\n" .. self.t:getpos()) end end
function Parser:canbe(token,tokentype) assert(tokentype)
if ( not token or token == self.t.token) and tokentype == self.t.tokentype then self.lasttoken,self.lasttokentype=self.t.token,self.t.tokentype
self.t:consume()
return self.lasttoken,self.lasttokentype end end
function Parser:mustbe(token,tokentype) local lasttoken,lasttokentype=self.t.token,self.t.tokentype
self.lasttoken,self.lasttokentype=self:canbe(token,tokentype)
if  not self.lasttoken then error("expected token=" .. tolua(token) .. " tokentype=" .. tolua(tokentype) .. " but found token=" .. tolua(lasttoken) .. " type=" .. tolua(lasttokentype)) end
return self.lasttoken,self.lasttokentype end
function Parser:node(index,...) local node=self.ast[index](...)
node.parser=self
return node end
return Parser