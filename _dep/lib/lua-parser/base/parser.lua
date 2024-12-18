local class=require"ext.class"
local table=require"ext.table"
local tolua=require"ext.tolua"
local Parser=class()
function Parser:init(data,...) if data then assert(self:setData(data,...)) end end
function Parser:setData(data,source) assert(data,"expected data")
data=tostring(data)
self.source=source
local t=self:buildTokenizer(data)
t:start()
self.t=t
local parseError
local result=table.pack(xpcall(function () self.tree=self:parseTree() end,function (err) if type(err) == "table" then parseError=err
return  else return err .. "\n" .. self.t:getpos() .. "\n" .. debug.traceback() end end))
if  not result[1] then if  not parseError then error(result[2]) end
return false,self.t:getpos() .. ": " .. parseError.msg end
self.ast.refreshparents(self.tree)
if self.t.token then return false,self.t:getpos() .. ": expected eof, found " .. self.t.token end
return true end
function Parser:getloc() local loc=self.t:getloc()
loc.source=self.source
return loc end
function Parser:canbe(token,tokentype) assert(tokentype)
if ( not token or token == self.t.token) and tokentype == self.t.tokentype then self.lasttoken,self.lasttokentype=self.t.token,self.t.tokentype
self.t:consume()
return self.lasttoken,self.lasttokentype end end
function Parser:mustbe(token,tokentype) local lasttoken,lasttokentype=self.t.token,self.t.tokentype
self.lasttoken,self.lasttokentype=self:canbe(token,tokentype)
if  not self.lasttoken then error{["msg"] = "expected token=" .. tolua(token) .. " tokentype=" .. tolua(tokentype) .. " but found token=" .. tolua(lasttoken) .. " type=" .. tolua(lasttokentype)} end
return self.lasttoken,self.lasttokentype end
function Parser:node(index,...) local node=self.ast[index](...)
node.parser=self
return node end
return Parser