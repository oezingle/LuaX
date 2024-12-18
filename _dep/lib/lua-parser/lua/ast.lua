local table=require"ext.table"
local assert=require"ext.assert"
local tolua=require"ext.tolua"
local BaseAST=require"parser.base.ast"
local ast={}
local LuaAST=BaseAST:subclass()
ast.node=LuaAST
local slashNByte=("\n"):byte()
function LuaAST:serializeRecursiveMember(field,args) local maintainSpan
if args then maintainSpan=args.maintainSpan end
local s=""
local line=1
local col=1
local index=1
local consume
local lastspan
consume=function (x) if type(x) == "number" then x=tostring(x) end
if type(x) == "string" then local function append(u) for i = 1, # u do if u:byte(i) == slashNByte then col=1
line=line + 1 else col=col + 1 end end
index=index +  # u
s=s .. u end
if maintainSpan and lastspan then while line < lastspan.from.line do append"\n" end end
local namelhs=s:sub( - 1):match"[_%w]"
local namerhs=x:sub(1,1):match"[_%w]"
if namelhs and namerhs then append" " elseif  not namelhs and  not namerhs then append" " end
append(x) elseif type(x) == "table" then lastspan=x.span
assert.is(x,BaseAST)
assert.index(x,field)
x[field](x,consume) else error("here with unknown type " .. type(x)) end end
self[field](self,consume)
return s end
function LuaAST:toLua(args) return self:serializeRecursiveMember("toLua_recursive",args) end
function LuaAST:toLua_recursive(consume) return self:serialize(consume) end
LuaAST.__tostring=string.nametostring
function LuaAST:exec(...) local code=self:toLua()
local f,msg=load(code,...)
if  not f then return nil,msg,code end
return f end
local fields={{"name","field"},{"index","field"},{"value","field"},{"cond","one"},{"var","one"},{"min","one"},{"max","one"},{"step","one"},{"func","one"},{"arg","one"},{"key","one"},{"expr","one"},{"stmt","one"},{"args","many"},{"exprs","many"},{"elseifs","many"},{"elsestmt","many"},{"vars","many"}}
ast.exec=LuaAST.exec
local function traverseRecurse(node,parentFirstCallback,childFirstCallback,parentNode) if  not LuaAST:isa(node) then return node end
if parentFirstCallback then local ret=parentFirstCallback(node,parentNode)
if ret ~= node then return ret end end
if type(node) == "table" then for i = 1, # node do node[i]=traverseRecurse(node[i],parentFirstCallback,childFirstCallback,node) end
for _,field in ipairs(fields) do local name=field[1]
local howmuch=field[2]
if node[name] then if howmuch == "one" then node[name]=traverseRecurse(node[name],parentFirstCallback,childFirstCallback,node) elseif howmuch == "many" then local value=node[name]
for i =  # value,1, - 1 do value[i]=traverseRecurse(value[i],parentFirstCallback,childFirstCallback,node) end elseif howmuch == "field" then  else error("unknown howmuch " .. howmuch) end end end end
if childFirstCallback then node=childFirstCallback(node,parentNode) end
return node end
function ast.refreshparents(node) traverseRecurse(node,function (node,parent) node.parent=parent
return node end) end
local function traverse(node,...) local newnode=traverseRecurse(node,...)
ast.refreshparents(newnode)
return newnode end
LuaAST.traverse=traverse
ast.traverse=traverse
function LuaAST.copy(n) local newn={}
setmetatable(newn,getmetatable(n))
for i = 1, # n do newn[i]=LuaAST.copy(n[i]) end
for _,field in ipairs(fields) do local name=field[1]
local howmuch=field[2]
local value=n[name]
if value then if howmuch == "one" then if type(value) == "table" then newn[name]=LuaAST.copy(value) else newn[name]=value end elseif howmuch == "many" then local newmany={}
for k,v in ipairs(value) do if type(v) == "table" then newmany[k]=LuaAST.copy(v) else newmany[k]=v end end
newn[name]=newmany elseif howmuch == "field" then newn[name]=value else error("unknown howmuch " .. howmuch) end end end
return newn end
ast.copy=LuaAST.copy
function LuaAST.flatten(f,varmap) f=LuaAST.copy(f)
traverseRecurse(f,function (n) if type(n) == "table" and ast._call:isa(n) then local funcname=n.func:toLua()
assert(funcname,"can't flatten a function with anonymous calls")
local f=varmap[funcname]
if f and  # f == 1 and ast._return:isa(f[1]) then local retexprs={}
for i,e in ipairs(f[1].exprs) do retexprs[i]=LuaAST.copy(e)
traverseRecurse(retexprs[i],function (v) if ast._arg:isa(v) then return LuaAST.copy(n.args[i]) end end)
retexprs[i]=ast._par(retexprs[i]) end
return ast._block(table.unpack(retexprs)) end end
return n end)
return f end
ast.flatten=LuaAST.flatten
local function consumeconcat(consume,t,sep) for i,x in ipairs(t) do consume(x)
if sep and i <  # t then consume(sep) end end end
local function spacesep(stmts,consume) consumeconcat(consume,stmts) end
local function commasep(exprs,consume) consumeconcat(consume,exprs,",") end
local function nodeclass(type,parent,args) parent=parent or LuaAST
local cl=parent:subclass(args)
cl.type=type
cl.__name=type
ast["_" .. type]=cl
return cl end
ast.nodeclass=nodeclass
local function isLuaName(s) return s:match"^[_%a][_%w]*$" end
function ast.keyIsName(key,parser) return ast._string:isa(key) and isLuaName(key.value) and ( not parser or  not parser.t.keywords[key.value]) end
local _block=nodeclass"block"
function _block:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function _block:serialize(consume) spacesep(self,consume) end
local _stmt=nodeclass"stmt"
local _assign=nodeclass("assign",_stmt)
function _assign:init(vars,exprs) self.vars=table(vars)
self.exprs=table(exprs) end
function _assign:serialize(consume) commasep(self.vars,consume)
consume"="
commasep(self.exprs,consume) end
local _do=nodeclass("do",_stmt)
function _do:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function _do:serialize(consume) consume"do"
spacesep(self,consume)
consume"end" end
local _while=nodeclass("while",_stmt)
function _while:init(cond,...) self.cond=cond
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _while:serialize(consume) consume"while"
consume(self.cond)
consume"do"
spacesep(self,consume)
consume"end" end
local _repeat=nodeclass("repeat",_stmt)
function _repeat:init(cond,...) self.cond=cond
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _repeat:serialize(consume) consume"repeat"
spacesep(self,consume)
consume"until"
consume(self.cond) end
local _if=nodeclass("if",_stmt)
function _if:init(cond,...) local elseifs=table()
local elsestmt,laststmt
for i = 1,select("#",...) do local stmt=select(i,...)
if ast._elseif:isa(stmt) then elseifs:insert(stmt) elseif ast._else:isa(stmt) then assert( not elsestmt)
elsestmt=stmt else if laststmt then assert(laststmt.type ~= "elseif" and laststmt.type ~= "else","got a bad stmt in an if after an else: " .. laststmt.type) end
table.insert(self,stmt) end
laststmt=stmt end
self.cond=cond
self.elseifs=elseifs
self.elsestmt=elsestmt end
function _if:serialize(consume) consume"if"
consume(self.cond)
consume"then"
spacesep(self,consume)
for _,ei in ipairs(self.elseifs) do consume(ei) end
if self.elsestmt then consume(self.elsestmt) end
consume"end" end
local _elseif=nodeclass("elseif",_stmt)
function _elseif:init(cond,...) self.cond=cond
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _elseif:serialize(consume) consume"elseif"
consume(self.cond)
consume"then"
spacesep(self,consume) end
local _else=nodeclass("else",_stmt)
function _else:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function _else:serialize(consume) consume"else"
spacesep(self,consume) end
local _foreq=nodeclass("foreq",_stmt)
function _foreq:init(var,min,max,step,...) self.var=var
self.min=min
self.max=max
self.step=step
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _foreq:serialize(consume) consume"for"
consume(self.var)
consume"="
consume(self.min)
consume","
consume(self.max)
if self.step then consume","
consume(self.step) end
consume"do"
spacesep(self,consume)
consume"end" end
local _forin=nodeclass("forin",_stmt)
function _forin:init(vars,iterexprs,...) self.vars=vars
self.iterexprs=iterexprs
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _forin:serialize(consume) consume"for"
commasep(self.vars,consume)
consume"in"
commasep(self.iterexprs,consume)
consume"do"
spacesep(self,consume)
consume"end" end
local _function=nodeclass("function",_stmt)
function _function:init(name,args,...) for i = 1, # args do args[i].index=i
args[i].param=true end
self.name=name
self.args=args
for i = 1,select("#",...) do self[i]=select(i,...) end end
function _function:serialize(consume) consume"function"
if self.name then consume(self.name) end
consume"("
commasep(self.args,consume)
consume")"
spacesep(self,consume)
consume"end" end
local _arg=nodeclass"arg"
function _arg:init(index) self.index=index end
function _arg:serialize(consume) consume("arg" .. self.index) end
local _local=nodeclass("local",_stmt)
function _local:init(exprs) if ast._function:isa(exprs[1]) or ast._assign:isa(exprs[1]) then assert( # exprs == 1,"local functions or local assignments must be the only child") end
self.exprs=table(assert(exprs)) end
function _local:serialize(consume) if ast._function:isa(self.exprs[1]) or ast._assign:isa(self.exprs[1]) then consume"local"
consume(self.exprs[1]) else consume"local"
commasep(self.exprs,consume) end end
local _return=nodeclass("return",_stmt)
function _return:init(...) self.exprs={...} end
function _return:serialize(consume) consume"return"
commasep(self.exprs,consume) end
local _break=nodeclass("break",_stmt)
function _break:serialize(consume) consume"break" end
local _call=nodeclass"call"
function _call:init(func,...) self.func=func
self.args={...} end
function _call:serialize(consume) if  # self.args == 1 and (ast._table:isa(self.args[1]) or ast._string:isa(self.args[1])) then consume(self.func)
consume(self.args[1]) else consume(self.func)
consume"("
commasep(self.args,consume)
consume")" end end
local _nil=nodeclass"nil"
_nil.const=true
function _nil:serialize(consume) consume"nil" end
local _boolean=nodeclass"boolean"
local _true=nodeclass("true",_boolean)
_true.const=true
_true.value=true
function _true:serialize(consume) consume"true" end
local _false=nodeclass("false",_boolean)
_false.const=true
_false.value=false
function _false:serialize(consume) consume"false" end
local _number=nodeclass"number"
function _number:init(value) self.value=value end
function _number:serialize(consume) consume(tostring(self.value)) end
local _string=nodeclass"string"
function _string:init(value) self.value=value end
function _string:serialize(consume) consume(tolua(self.value)) end
local _vararg=nodeclass"vararg"
function _vararg:serialize(consume) consume"..." end
local _table=nodeclass"table"
function _table:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function _table:serialize(consume) consume"{"
for i,arg in ipairs(self) do if ast._assign:isa(arg) then assert.len(arg.vars,1)
assert.len(arg.exprs,1)
if ast.keyIsName(arg.vars[1],self.parser) then consume(arg.vars[1].value) else consume"["
consume(arg.vars[1])
consume"]" end
consume"="
consume(arg.exprs[1]) else consume(arg) end
if i <  # self then consume"," end end
consume"}" end
local _var=nodeclass"var"
function _var:init(name,attrib) self.name=name
self.attrib=attrib end
function _var:serialize(consume) consume(self.name)
if self.attrib then consume"<"
consume(self.attrib)
consume">" end end
local _par=nodeclass"par"
ast._par=_par
ast._parenthesis=nil
function _par:init(expr) self.expr=expr end
function _par:serialize(consume) consume"("
consume(self.expr)
consume")" end
local _index=nodeclass"index"
function _index:init(expr,key) self.expr=expr
if type(key) == "string" then key=ast._string(key) elseif type(key) == "number" then key=ast._number(key) end
self.key=key end
function _index:serialize(consume) if ast.keyIsName(self.key,self.parser) then consume(self.expr)
consume"."
consume(self.key.value) else consume(self.expr)
consume"["
consume(self.key)
consume"]" end end
local _indexself=nodeclass"indexself"
function _indexself:init(expr,key) self.expr=assert(expr)
assert(isLuaName(key))
self.key=assert(key) end
function _indexself:serialize(consume) consume(self.expr)
consume":"
consume(self.key) end
local _op=nodeclass"op"
function _op:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function _op:serialize(consume) for i,x in ipairs(self) do consume(x)
if i <  # self then consume(self.op) end end end
for _,info in ipairs{{"add","+"},{"sub","-"},{"mul","*"},{"div","/"},{"pow","^"},{"mod","%"},{"concat",".."},{"lt","<"},{"le","<="},{"gt",">"},{"ge",">="},{"eq","=="},{"ne","~="},{"and","and"},{"or","or"},{"idiv","//"},{"band","&"},{"bxor","~"},{"bor","|"},{"shl","<<"},{"shr",">>"}} do local op=info[2]
local cl=nodeclass(info[1],_op)
cl.op=op end
for _,info in ipairs{{"unm","-"},{"not","not"},{"len","#"},{"bnot","~"}} do local op=info[2]
local cl=nodeclass(info[1],_op)
cl.op=op
function cl:init(...) for i = 1,select("#",...) do self[i]=select(i,...) end end
function cl:serialize(consume) consume(self.op)
consume(self[1]) end end
local _goto=nodeclass("goto",_stmt)
function _goto:init(name) self.name=name end
function _goto:serialize(consume) consume"goto"
consume(self.name) end
local _label=nodeclass("label",_stmt)
function _label:init(name) self.name=name end
function _label:serialize(consume) consume"::"
consume(self.name)
consume"::" end
return ast