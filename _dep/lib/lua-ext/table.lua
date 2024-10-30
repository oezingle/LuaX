local table={}
for k,v in pairs(require"table") do table[k]=v end
table.__index=table
function table.new(...) return setmetatable({},table):union(...) end
setmetatable(table,{["__call"] = function (t,...) return table.new(...) end})
table.unpack=table.unpack or unpack
local origTableUnpack=table.unpack
function table.unpack(...) local nargs=select("#",...)
local t,i,j=...
if nargs < 3 and t.n ~= nil then return origTableUnpack(t,i or 1,t.n) end
return origTableUnpack(...) end
if  not table.pack then function table.pack(...) local t={...}
t.n=select("#",...)
return setmetatable(t,table) end else local oldpack=table.pack
function table.pack(...) return setmetatable(oldpack(...),table) end end
if  not table.maxn then function table.maxn(t) local max=0
for k,v in pairs(t) do if type(k) == "number" then max=math.max(max,k) end end
return max end end
function table:union(...) for i = 1,select("#",...) do local o=select(i,...)
if o then for k,v in pairs(o) do self[k]=v end end end
return self end
function table:append(...) for i = 1,select("#",...) do local u=select(i,...)
if u then for _,v in ipairs(u) do table.insert(self,v) end end end
return self end
function table:removeKeys(...) for i = 1,select("#",...) do local v=select(i,...)
self[v]=nil end end
function table:map(cb) local t=table()
for k,v in pairs(self) do local nv,nk=cb(v,k,t)
if nk == nil then nk=k end
t[nk]=nv end
return t end
function table:mapi(cb) local t=table()
for k = 1, # self do local v=self[k]
local nv,nk=cb(v,k,t)
if nk == nil then nk=k end
t[nk]=nv end
return t end
function table:filter(f) local t=table()
if type(f) == "function" then for k,v in pairs(self) do if f(v,k) then if type(k) == "string" then t[k]=v else t:insert(v) end end end else error"table.filter second arg must be a function" end
return t end
function table:keys() local t=table()
for k,_ in pairs(self) do t:insert(k) end
return t end
function table:values() local t=table()
for _,v in pairs(self) do t:insert(v) end
return t end
function table:find(value,eq) if eq then for k,v in pairs(self) do if eq(v,value) then return k,v end end else for k,v in pairs(self) do if v == value then return k,v end end end end
function table:insertUnique(value,eq) if  not table.find(self,value,eq) then table.insert(self,value) end end
function table:removeObject(...) local removedKeys=table()
local len= # self
local k=table.find(self,...)
while k ~= nil do if type(k) == "number" and tonumber(k) <= len then table.remove(self,k) else self[k]=nil end
removedKeys:insert(k)
k=table.find(self,...) end
return table.unpack(removedKeys) end
function table:kvpairs() local t=table()
for k,v in pairs(self) do table.insert(t,{[k] = v}) end
return t end
function table:sup(cmp) local bestk,bestv
if cmp then for k,v in pairs(self) do if bestv == nil or cmp(v,bestv) then bestk,bestv=k,v end end else for k,v in pairs(self) do if bestv == nil or v > bestv then bestk,bestv=k,v end end end
return bestv,bestk end
function table:inf(cmp) local bestk,bestv
if cmp then for k,v in pairs(self) do if bestv == nil or cmp(v,bestv) then bestk,bestv=k,v end end else for k,v in pairs(self) do if bestv == nil or v < bestv then bestk,bestv=k,v end end end
return bestv,bestk end
function table:combine(callback) local s
for _,v in pairs(self) do if s == nil then s=v else s=callback(s,v) end end
return s end
local op=require"ext.op"
function table:sum() return table.combine(self,op.add) end
function table:product() return table.combine(self,op.mul) end
function table:last() return self[ # self] end
function table.sub(t,i,j) if i < 0 then i=math.max(1, # t + i + 1) end
j=j or  # t
j=math.min(j, # t)
if j < 0 then j=math.min( # t, # t + j + 1) end
local res={}
for k = i,j do res[k - i + 1]=t[k] end
setmetatable(res,table)
return res end
function table.reverse(t) local r=table()
for i =  # t,1, - 1 do r:insert(t[i]) end
return r end
function table.rep(t,n) local c=table()
for i = 1,n do c:append(t) end
return c end
local oldsort=require"table".sort
function table:sort(...) oldsort(self,...)
return self end
function table.shuffle(t) t=table(t)
for i =  # t,2, - 1 do local j=math.random(i - 1)
t[i],t[j]=t[j],t[i] end
return t end
function table.pickRandom(t) return t[math.random( # t)] end
function table.wrapfor(f,s,var) local t=table()
while true do local vars=table.pack(f(s,var))
local var_1=vars[1]
if var_1 == nil then break end
var=var_1
t:insert(vars) end
return t end
local function permgen(t,n) if n < 1 then coroutine.yield(t) else for i = n,1, - 1 do t[n],t[i]=t[i],t[n]
permgen(t,n - 1)
t[n],t[i]=t[i],t[n] end end end
function table.permutations(t) return coroutine.wrap(function () permgen(t,table.maxn(t)) end) end
table.setmetatable=setmetatable
return table