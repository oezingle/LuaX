local table=require"ext.table"
local assert=require"ext.assert"
local Tokenizer=require"parser.base.tokenizer"
local LuaTokenizer=Tokenizer:subclass()
function LuaTokenizer:initSymbolsAndKeywords(version,useluajit) self.version=assert(version)
self.useluajit=useluajit
for w in ("... .. == ~= <= >= + - * / % ^ # < > = ( ) { } [ ] ; : , ."):gmatch"%S+" do self.symbols:insert(w) end
for w in ("and break do else elseif end false for function if in local nil not or repeat return then true until while"):gmatch"%S+" do self.keywords[w]=true end
do self.symbols:insert"::"
self.keywords["goto"]=true end
if version >= "5.3" then self.symbols:insert"//"
self.symbols:insert"~"
self.symbols:insert"&"
self.symbols:insert"|"
self.symbols:insert"<<"
self.symbols:insert">>" end end
function LuaTokenizer:parseHexNumber(...) local r=self.r
if self.version >= "5.2" then local token=r:canbe"[%.%da-fA-F]+"
local numdots= # token:gsub("[^%.]","")
assert.le(numdots,1,"malformed number")
local n=table{"0x",token}
if r:canbe"p" then n:insert(r.lasttoken)
n:insert(r:mustbe("[%+%-]%d+","malformed number")) elseif numdots == 0 and self.useluajit then if r:canbe"LL" then n:insert"LL" elseif r:canbe"ULL" then n:insert"ULL" end end
coroutine.yield(n:concat(),"number") else local token=r:mustbe("[%da-fA-F]+","malformed number")
local n=table{"0x",token}
if self.useluajit then if r:canbe"LL" then n:insert"LL" elseif r:canbe"ULL" then n:insert"ULL" end end
coroutine.yield(n:concat(),"number") end end
function LuaTokenizer:parseDecNumber() local r=self.r
local token=r:canbe"[%.%d]+"
local numdots= # token:gsub("[^%.]","")
assert.le(numdots,1,"malformed number")
local n=table{token}
if r:canbe"e" then n:insert(r.lasttoken)
n:insert(r:mustbe("[%+%-]%d+","malformed number")) elseif numdots == 0 and self.useluajit then if r:canbe"LL" then n:insert"LL" elseif r:canbe"ULL" then n:insert"ULL" end end
coroutine.yield(n:concat(),"number") end
return LuaTokenizer