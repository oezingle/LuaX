local table=require"ext.table"
local string=require"ext.string"
local class=require"ext.class"
local assert=require"ext.assert"
local DataReader=require"parser.base.datareader"
local Tokenizer=class()
function Tokenizer:initSymbolsAndKeywords(...)  end
function Tokenizer:init(data,...) self.symbols=table(self.symbols)
self.keywords=table(self.keywords):setmetatable(nil)
self:initSymbolsAndKeywords(...)
self.r=DataReader(data)
self.gettokenthread=coroutine.create(function () local r=self.r
while  not r:done() do self:skipWhiteSpaces()
if r:done() then break end
if self:parseComment() then  elseif self:parseString() then  elseif self:parseName() then  elseif self:parseNumber() then  elseif self:parseSymbol() then  else error{["msg"] = "unknown token " .. r.data:sub(r.index)} end end end) end
function Tokenizer:skipWhiteSpaces() local r=self.r
r:canbe"%s+" end
Tokenizer.singleLineComment=string.patescape"--"
function Tokenizer:parseComment() local r=self.r
if r:canbe(self.singleLineComment) then local start=r.index -  # r.lasttoken
if  not r:readblock() then if  not r:seekpast"\n" then r:seekpast"$" end end
return true end end
function Tokenizer:parseString() if self:parseBlockString() then return true end
if self:parseQuoteString() then return true end end
function Tokenizer:parseBlockString() local r=self.r
if r:readblock() then coroutine.yield(r.lasttoken,"string")
return true end end
function Tokenizer:parseQuoteString() local r=self.r
if r:canbe"[\"']" then local quote=r.lasttoken
local s=table()
while true do r:seekpast"."
if r.lasttoken == quote then break end
if r:done() then error{["msg"] = "unfinished string"} end
if r.lasttoken == "\\" then local esc=r:canbe"."
local escapeCodes={["a"] = "\7",["b"] = "\8",["f"] = "\12",["n"] = "\n",["r"] = "\13",["t"] = "\9",["v"] = "\11",["\\"] = "\\",["\""] = "\"",["'"] = "'",["0"] = "\0",["\13"] = "\n",["\n"] = "\n"}
local escapeCode=escapeCodes[esc]
if escapeCode then s:insert(escapeCode) elseif esc == "x" and self.version >= "5.2" then esc=r:mustbe"%x" .. r:mustbe"%x"
s:insert(string.char(tonumber(esc,16))) elseif esc == "u" and self.version >= "5.3" then r:mustbe"{"
local code=0
while true do local ch=r:canbe"%x"
if  not ch then break end
code=code * 16 + tonumber(ch,16) end
r:mustbe"}"
local bit=bit32 or require"bit"
if code < 0x80 then s:insert(string.char(code)) elseif code < 0x800 then s:insert(string.char(bit.bor(0xc0,bit.band(0x1f,bit.rshift(code,6)))) .. string.char(bit.bor(0x80,bit.band(0x3f,code)))) elseif code < 0x10000 then s:insert(string.char(bit.bor(0xe0,bit.band(0x0f,bit.rshift(code,12)))) .. string.char(bit.bor(0x80,bit.band(0x3f,bit.rshift(code,6)))) .. string.char(bit.bor(0x80,bit.band(0x3f,code)))) else s:insert(string.char(bit.bor(0xf0,bit.band(0x07,bit.rshift(code,18)))) .. string.char(bit.bor(0x80,bit.band(0x3f,bit.rshift(code,12)))) .. string.char(bit.bor(0x80,bit.band(0x3f,bit.rshift(code,6)))) .. string.char(bit.bor(0x80,bit.band(0x3f,code)))) end elseif esc:match"%d" then if r:canbe"%d" then esc=esc .. r.lasttoken end
if r:canbe"%d" then esc=esc .. r.lasttoken end
s:insert(string.char(tonumber(esc))) else if self.version >= "5.2" then error{["msg"] = "invalid escape sequence " .. esc} end end else s:insert(r.lasttoken) end end
coroutine.yield(s:concat(),"string")
return true end end
function Tokenizer:parseName() local r=self.r
if r:canbe"[%a_][%w_]*" then coroutine.yield(r.lasttoken,self.keywords[r.lasttoken] and "keyword" or "name")
return true end end
function Tokenizer:parseNumber() local r=self.r
if r.data:match("^[%.%d]",r.index) and (r.data:match("^%d",r.index) or r.data:match("^%.%d",r.index)) then if r:canbe"0[xX]" then self:parseHexNumber() else self:parseDecNumber() end
return true end end
function Tokenizer:parseHexNumber() local r=self.r
local token=r:mustbe("[%da-fA-F]+","malformed number")
coroutine.yield("0x" .. token,"number") end
function Tokenizer:parseDecNumber() local r=self.r
local token=r:canbe"[%.%d]+"
assert.le( # token:gsub("[^%.]",""),1,"malformed number")
local n=table{token}
if r:canbe"e" then n:insert(r.lasttoken)
n:insert(r:mustbe("[%+%-]%d+","malformed number")) end
coroutine.yield(n:concat(),"number") end
function Tokenizer:parseSymbol() local r=self.r
for _,symbol in ipairs(self.symbols) do if r:canbe(string.patescape(symbol)) then coroutine.yield(r.lasttoken,"symbol")
return true end end end
function Tokenizer:start() self.symbols=self.symbols:mapi(function (v,k) return true,v end):keys()
self.symbols:sort(function (a,b) return  # a >  # b end)
self:consume()
self:consume() end
function Tokenizer:consume() self.prev2index=self.previndex
self.prev2tokenIndex=self.prevtokenIndex
self.previndex=self.r.index
self.prevtokenIndex= # self.r.tokenhistory + 1
self.token=self.nexttoken
self.tokentype=self.nexttokentype
if coroutine.status(self.gettokenthread) == "dead" then self.nexttoken=nil
self.nexttokentype=nil
return  end
local status,nexttoken,nexttokentype=coroutine.resume(self.gettokenthread)
if  not status then local err=nexttoken
error{["msg"] = err,["token"] = self.token,["tokentype"] = self.tokentype,["pos"] = self:getpos(),["traceback"] = debug.traceback(self.gettokenthread)} end
self.nexttoken=nexttoken
self.nexttokentype=nexttokentype end
function Tokenizer:getpos() return "line " .. self.r.line .. " col " .. self.r.col .. " code \"" .. self.r.data:sub(self.r.index):match"^[^\n]*" .. "\"" end
function Tokenizer:getloc() local r=self.r
local line=self.r.line
local col=self.r.col
return {["line"] = line,["col"] = col,["index"] = self.prev2index,["tokenIndex"] = self.prev2tokenIndex} end
return Tokenizer