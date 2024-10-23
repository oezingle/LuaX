local table=require"ext.table"
local class=require"ext.class"
local assert=require"ext.assert"
local DataReader=class()
DataReader.tracktokens=true
function DataReader:init(data) self.data=data
self.index=1
self.tokenhistory=table()
self.line=1
self.col=1
if self.data:sub(1,1) == "#" then if  not self:seekpast"\n" then self:seekpast"$" end end end
function DataReader:done() return self.index >  # self.data end
local slashNByte=("\n"):byte()
function DataReader:updatelinecol() if  not self.lastUpdateLineColIndex then self.lastUpdateLineColIndex=1 else assert(self.index >= self.lastUpdateLineColIndex) end
for i = self.lastUpdateLineColIndex,self.index do if self.data:byte(i,i) == slashNByte then self.col=1
self.line=self.line + 1 else self.col=self.col + 1 end end
self.lastUpdateLineColIndex=self.index + 1 end
function DataReader:setlasttoken(lasttoken,skipped) self.lasttoken=lasttoken
if self.tracktokens then if skipped and  # skipped > 0 then self.tokenhistory:insert(skipped) end
self.tokenhistory:insert(self.lasttoken) end
return self.lasttoken end
function DataReader:seekpast(pattern) local from,to=self.data:find(pattern,self.index)
if  not from then return  end
local skipped=self.data:sub(self.index,from - 1)
self.index=to + 1
self:updatelinecol()
return self:setlasttoken(self.data:sub(from,to),skipped) end
function DataReader:canbe(pattern) return self:seekpast("^" .. pattern) end
function DataReader:mustbe(pattern,msg) if  not self:canbe(pattern) then error(msg or "expected " .. pattern) end
return self.lasttoken end
function DataReader:readblock() if  not self:canbe"%[=*%[" then return  end
local eq=assert(self.lasttoken:match"^%[(=*)%[$")
self:canbe"\n"
local start=self.index
if  not self:seekpast("%]" .. eq .. "%]") then error"expected closing block" end
self.lasttoken=self.data:sub(start,self.index -  # self.lasttoken - 1)
return self.lasttoken end
return DataReader