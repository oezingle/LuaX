local string={}
for k,v in pairs(require"string") do string[k]=v end
local table=require"ext.table"
function string.split(s,exp) exp=exp or ""
s=tostring(s)
local t=table()
if exp == "" then for i = 1, # s do t:insert(s:sub(i,i)) end else local searchpos=1
local start,fin=s:find(exp,searchpos)
while start do t:insert(s:sub(searchpos,start - 1))
searchpos=fin + 1
start,fin=s:find(exp,searchpos) end
t:insert(s:sub(searchpos)) end
return t end
function string.trim(s) return s:match"^%s*(.-)%s*$" end
function string.bytes(s) return table{s:byte(1, # s)} end
string.load=load or loadstring
function string.csub(d,start,size) if  not size then return string.sub(d,start + 1) end
return string.sub(d,start + 1,start + size) end
function string.hexdump(d,l,w,c) d=tostring(d)
l=tonumber(l)
w=tonumber(w)
c=tonumber(c)
if  not l or l < 1 then l=32 end
if  not w or w < 1 then w=1 end
if  not c or c < 1 then c=8 end
local s=table()
local rhs=table()
local col=0
for i = 1, # d,w do if i % l == 1 then s:insert(string.format("%.8x ",(i - 1)))
rhs=table()
col=1 end
s:insert" "
for j = w,1, - 1 do local e=i + j - 1
local sub=d:sub(e,e)
if  # sub > 0 then local b=string.byte(sub)
s:insert(string.format("%.2x",b))
rhs:insert(b >= 32 and sub or ".") end end
if col % c == 0 then s:insert" " end
if (i + w - 1) % l == 0 or i + w >  # d then s:insert" "
s:insert(rhs:concat()) end
if (i + w - 1) % l == 0 then s:insert"\n" end
col=col + 1 end
return s:concat() end
local escapeFind="[" .. ("^$()%.[]*+-?"):gsub(".","%%%1") .. "]"
function string.patescape(s) return (s:gsub(escapeFind,"%%%1")) end
function string.concat(...) local n=select("#",...)
if n == 0 then return  end
local s=tostring((...))
if n == 1 then return s end
return s .. string.concat(select(2,...)) end
function string:nametostring() local mt=getmetatable(self)
setmetatable(self,nil)
local s=tostring(self)
setmetatable(self,mt)
local name=mt.__name
return name and tostring(name) .. s:sub(6) or s end
return string