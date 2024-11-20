local table=require"ext.table"
local assert=require"ext.assert"
local Parser=require"parser.base.parser"
local ast=require"parser.lua.ast"
local LuaTokenizer=require"parser.lua.tokenizer"
local LuaParser=Parser:subclass()
LuaParser.ast=ast
function LuaParser.parse(...) return LuaParser(...).tree end
function LuaParser:init(data,version,source,useluajit) self.version=version or _VERSION:match"^Lua (.*)$"
if useluajit == nil then useluajit= not  not _G.jit end
self.useluajit= not  not useluajit
self.parseExprPrecedenceRulesAndClassNames=table{{["name"] = "or",["rules"] = {{["token"] = "or",["className"] = "_or"}}},{["name"] = "and",["rules"] = {{["token"] = "and",["className"] = "_and"}}},{["name"] = "cmp",["rules"] = {{["token"] = "<",["className"] = "_lt"},{["token"] = ">",["className"] = "_gt"},{["token"] = "<=",["className"] = "_le"},{["token"] = ">=",["className"] = "_ge"},{["token"] = "~=",["className"] = "_ne"},{["token"] = "==",["className"] = "_eq"}}}}:append(self.version < "5.3" and nil or table{{["name"] = "bor",["rules"] = {{["token"] = "|",["className"] = "_bor"}}},{["name"] = "bxor",["rules"] = {{["token"] = "~",["className"] = "_bxor"}}},{["name"] = "band",["rules"] = {{["token"] = "&",["className"] = "_band"}}},{["name"] = "shift",["rules"] = {{["token"] = "<<",["className"] = "_shl"},{["token"] = ">>",["className"] = "_shr"}}}}):append{{["name"] = "concat",["rules"] = {{["token"] = "..",["className"] = "_concat"}}},{["name"] = "addsub",["rules"] = {{["token"] = "+",["className"] = "_add"},{["token"] = "-",["className"] = "_sub"}}},{["name"] = "muldivmod",["rules"] = {{["token"] = "*",["className"] = "_mul"},{["token"] = "/",["className"] = "_div"},{["token"] = "%",["className"] = "_mod"},{["token"] = "//",["className"] = "_idiv"}}},{["name"] = "unary",["unaryLHS"] = true,["rules"] = {{["token"] = "not",["className"] = "_not"},{["token"] = "#",["className"] = "_len"},{["token"] = "-",["className"] = "_unm"},{["token"] = "~",["className"] = "_bnot"}}},{["name"] = "pow",["rules"] = {{["token"] = "^",["className"] = "_pow",["nextLevel"] = "unary"}}}}
if data then self:setData(data,source) end end
function LuaParser:getloc() local loc=self.t:getloc()
loc.source=self.source
return loc end
function LuaParser:setData(data,source) self.gotos={}
self.labels={}
self.source=source
self.blockStack=table()
self.functionStack=table{"function-vararg"}
LuaParser.super.setData(self,data)
for _,g in pairs(self.gotos) do assert(self.labels[g.name],"no visible label '" .. g.name .. "' for <goto> at line " .. g.span.to.line) end end
function LuaParser:buildTokenizer(data) return LuaTokenizer(data,self.version,self.useluajit) end
function LuaParser:parseTree() return self:parse_chunk() end
function LuaParser:parse_chunk() local from=self:getloc()
local stmts=table()
repeat local stmt=self:parse_stat()
if  not stmt then break end
stmts:insert(stmt)
if self.version == "5.1" then self:canbe(";","symbol") end until false
local laststat=self:parse_retstat()
if laststat then stmts:insert(laststat)
if self.version == "5.1" then self:canbe(";","symbol") end end
return self:node("_block",table.unpack(stmts)):setspan{["from"] = from,["to"] = self:getloc()} end
function LuaParser:parse_block(blockName) if blockName then self.blockStack:insert(blockName) end
local chunk=self:parse_chunk()
if blockName then assert.eq(self.blockStack:remove(),blockName) end
return chunk end
function LuaParser:parse_stat() if self.version >= "5.2" then repeat  until  not self:canbe(";","symbol") end
local from=self:getloc()
if self:canbe("local","keyword") then local ffrom=self:getloc()
if self:canbe("function","keyword") then local name=self:mustbe(nil,"name")
return self:node("_local",{self:makeFunction(self:node("_var",name),table.unpack(assert(self:parse_funcbody()))):setspan{["from"] = ffrom,["to"] = self:getloc()}}):setspan{["from"] = from,["to"] = self:getloc()} else local afrom=self:getloc()
local namelist=assert(self:parse_attnamelist())
if self:canbe("=","symbol") then local explist=assert(self:parse_explist())
local assign=self:node("_assign",namelist,explist):setspan{["from"] = ffrom,["to"] = self:getloc()}
return self:node("_local",{assign}):setspan{["from"] = from,["to"] = self:getloc()} else return self:node("_local",namelist):setspan{["from"] = from,["to"] = self:getloc()} end end elseif self:canbe("function","keyword") then local funcname=self:parse_funcname()
return self:makeFunction(funcname,table.unpack(assert(self:parse_funcbody()))):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("for","keyword") then local namelist=assert(self:parse_namelist())
if self:canbe("=","symbol") then assert.eq( # namelist,1)
local explist=assert(self:parse_explist())
assert.ge( # explist,2)
assert.le( # explist,3)
self:mustbe("do","keyword")
local block=assert(self:parse_block"for =")
self:mustbe("end","keyword")
return self:node("_foreq",namelist[1],explist[1],explist[2],explist[3],table.unpack(block)):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("in","keyword") then local explist=assert(self:parse_explist())
self:mustbe("do","keyword")
local block=assert(self:parse_block"for in")
self:mustbe("end","keyword")
return self:node("_forin",namelist,explist,table.unpack(block)):setspan{["from"] = from,["to"] = self:getloc()} else error"'=' or 'in' expected" end elseif self:canbe("if","keyword") then local cond=assert(self:parse_exp(),"unexpected symbol")
self:mustbe("then","keyword")
local block=self:parse_block()
local stmts=table(block)
local efrom=self:getloc()
while self:canbe("elseif","keyword") do local cond=assert(self:parse_exp(),"unexpected symbol")
self:mustbe("then","keyword")
stmts:insert(self:node("_elseif",cond,table.unpack(assert(self:parse_block()))):setspan{["from"] = efrom,["to"] = self:getloc()})
efrom=self:getloc() end
if self:canbe("else","keyword") then stmts:insert(self:node("_else",table.unpack(assert(self:parse_block()))):setspan{["from"] = efrom,["to"] = self:getloc()}) end
self:mustbe("end","keyword")
return self:node("_if",cond,table.unpack(stmts)):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("repeat","keyword") then local block=assert(self:parse_block"repeat")
self:mustbe("until","keyword")
return self:node("_repeat",assert(self:parse_exp(),"unexpected symbol"),table.unpack(block)):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("while","keyword") then local cond=assert(self:parse_exp(),"unexpected symbol")
self:mustbe("do","keyword")
local block=assert(self:parse_block"while")
self:mustbe("end","keyword")
return self:node("_while",cond,table.unpack(block)):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("do","keyword") then local block=assert(self:parse_block())
self:mustbe("end","keyword")
return self:node("_do",table.unpack(block)):setspan{["from"] = from,["to"] = self:getloc()} elseif self.version >= "5.2" then if self:canbe("goto","keyword") then local name=self:mustbe(nil,"name")
local g=self:node("_goto",name):setspan{["from"] = from,["to"] = self:getloc()}
self.gotos[name]=g
return g elseif self:canbe("break","keyword") then return self:parse_break():setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe("::","symbol") then local name=self:mustbe(nil,"name")
local l=self:node("_label",name)
self.labels[name]=true
self:mustbe("::","symbol")
return l:setspan{["from"] = from,["to"] = self:getloc()} end end
local prefixexp=self:parse_prefixexp()
if prefixexp then if self.ast._call:isa(prefixexp) then return prefixexp else local vars=table{prefixexp}
while self:canbe(",","symbol") do local var=assert(self:parse_prefixexp())
assert.ne(var.type,"call","syntax error")
vars:insert(var) end
return self:parse_assign(vars,from) end end end
function LuaParser:parse_assign(vars,from) self:mustbe("=","symbol")
return self:node("_assign",vars,assert(self:parse_explist())):setspan{["from"] = from,["to"] = self:getloc()} end
function LuaParser:parse_retstat() local from=self:getloc()
if self.version == "5.1" and self:canbe("break","keyword") then return self:parse_break():setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe("return","keyword") then local explist=self:parse_explist() or {}
if self.version >= "5.2" then self:canbe(";","symbol") end
return self:node("_return",table.unpack(explist)):setspan{["from"] = from,["to"] = self:getloc()} end end
function LuaParser:parse_break() local from=self:getloc()
if  not ({["while"] = 1,["repeat"] = 1,["for ="] = 1,["for in"] = 1})[self.blockStack:last()] then error"break not inside loop" end
return self:node"_break":setspan{["from"] = from,["to"] = self:getloc()} end
function LuaParser:parse_funcname() if  not self:canbe(nil,"name") then return  end
local from=self:getloc()
local name=self:node("_var",self.lasttoken):setspan{["from"] = from,["to"] = self:getloc()}
while self:canbe(".","symbol") do local sfrom=self.t:getloc()
name=self:node("_index",name,self:node("_string",self:mustbe(nil,"name")):setspan{["from"] = sfrom,["to"] = self:getloc()}):setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe(":","symbol") then name=self:node("_indexself",name,self:mustbe(nil,"name")):setspan{["from"] = from,["to"] = self:getloc()} end
return name end
function LuaParser:parse_namelist() local from=self:getloc()
local name=self:canbe(nil,"name")
if  not name then return  end
local names=table{self:node("_var",name):setspan{["from"] = from,["to"] = self:getloc()}}
while self:canbe(",","symbol") do from=self:getloc()
names:insert(self:node("_var",(self:mustbe(nil,"name"))):setspan{["from"] = from,["to"] = self:getloc()}) end
return names end
function LuaParser:parse_attnamelist() local from=self:getloc()
local name=self:canbe(nil,"name")
if  not name then return  end
local attrib=self:parse_attrib()
local names=table{self:node("_var",name,attrib):setspan{["from"] = from,["to"] = self:getloc()}}
while self:canbe(",","symbol") do from=self:getloc()
local name=self:mustbe(nil,"name")
local attrib=self:parse_attrib()
names:insert(self:node("_var",name,attrib):setspan{["from"] = from,["to"] = self:getloc()}) end
return names end
function LuaParser:parse_attrib() if self.version < "5.4" then return  end
local attrib
if self:canbe("<","symbol") then attrib=self:mustbe(nil,"name")
self:mustbe(">","symbol") end
return attrib end
function LuaParser:parse_explist() local exp=self:parse_exp()
if  not exp then return  end
local exps=table{exp}
while self:canbe(",","symbol") do exps:insert((assert(self:parse_exp(),"unexpected symbol"))) end
return exps end
function LuaParser:parse_exp() return self:parse_expr_precedenceTable(1) end
function LuaParser:getNextRule(rules) for _,rule in pairs(rules) do local keywordOrSymbol=rule.token:match"^[_a-zA-Z][_a-zA-Z0-9]*$" and "keyword" or "symbol"
if self:canbe(rule.token,keywordOrSymbol) then return rule end end end
function LuaParser:getClassNameForRule(rules) local rule=self:getNextRule(rules)
if rule then return rule.className end end
function LuaParser:parse_expr_precedenceTable(i) local precedenceLevel=self.parseExprPrecedenceRulesAndClassNames[i]
if precedenceLevel.unaryLHS then local from=self:getloc()
local rule=self:getNextRule(precedenceLevel.rules)
if rule then local nextLevel=i
if rule.nextLevel then nextLevel=self.parseExprPrecedenceRulesAndClassNames:find(nil,function (level) return level.name == rule.nextLevel end) or error("couldn't find precedence level named " .. tostring(rule.nextLevel)) end
return self:node(rule.className,assert(self:parse_expr_precedenceTable(nextLevel))):setspan{["from"] = from,["to"] = self:getloc()} end
return self:parse_expr_precedenceTable(i + 1) else local a
if i <  # self.parseExprPrecedenceRulesAndClassNames then a=self:parse_expr_precedenceTable(i + 1) else a=self:parse_subexp() end
if  not a then return  end
local rule=self:getNextRule(precedenceLevel.rules)
if rule then local nextLevel=i
if rule.nextLevel then nextLevel=self.parseExprPrecedenceRulesAndClassNames:find(nil,function (level) return level.name == rule.nextLevel end) or error("couldn't find precedence level named " .. tostring(rule.nextLevel)) end
a=self:node(rule.className,a,assert(self:parse_expr_precedenceTable(nextLevel))):setspan{["from"] = a.span.from,["to"] = self:getloc()} end
return a end end
function LuaParser:parse_subexp() local tableconstructor=self:parse_tableconstructor()
if tableconstructor then return tableconstructor end
local prefixexp=self:parse_prefixexp()
if prefixexp then return prefixexp end
local functiondef=self:parse_functiondef()
if functiondef then return functiondef end
local from=self:getloc()
if self:canbe("...","symbol") then assert.eq(self.functionStack:last(),"function-vararg")
return self:node"_vararg":setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe(nil,"string") then return self:node("_string",self.lasttoken):setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe(nil,"number") then return self:node("_number",self.lasttoken):setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe("true","keyword") then return self:node"_true":setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe("false","keyword") then return self:node"_false":setspan{["from"] = from,["to"] = self:getloc()} end
if self:canbe("nil","keyword") then return self:node"_nil":setspan{["from"] = from,["to"] = self:getloc()} end end
function LuaParser:parse_prefixexp() local prefixexp
local from=self:getloc()
if self:canbe("(","symbol") then local exp=assert(self:parse_exp(),"unexpected symbol")
self:mustbe(")","symbol")
prefixexp=self:node("_par",exp):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe(nil,"name") then prefixexp=self:node("_var",self.lasttoken):setspan{["from"] = from,["to"] = self:getloc()} else return  end
while true do if self:canbe("[","symbol") then prefixexp=self:node("_index",prefixexp,(assert(self:parse_exp(),"unexpected symbol")))
self:mustbe("]","symbol")
prefixexp:setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe(".","symbol") then local sfrom=self:getloc()
prefixexp=self:node("_index",prefixexp,self:node("_string",self:mustbe(nil,"name")):setspan{["from"] = sfrom,["to"] = self:getloc()}):setspan{["from"] = from,["to"] = self:getloc()} elseif self:canbe(":","symbol") then prefixexp=self:node("_indexself",prefixexp,self:mustbe(nil,"name")):setspan{["from"] = from,["to"] = self:getloc()}
local args=self:parse_args()
if  not args then error"function arguments expected" end
prefixexp=self:node("_call",prefixexp,table.unpack(args)):setspan{["from"] = from,["to"] = self:getloc()} else local args=self:parse_args()
if  not args then break end
prefixexp=self:node("_call",prefixexp,table.unpack(args)):setspan{["from"] = from,["to"] = self:getloc()} end end
return prefixexp end
function LuaParser:parse_args() local from=self:getloc()
if self:canbe(nil,"string") then return {self:node("_string",self.lasttoken):setspan{["from"] = from,["to"] = self:getloc()}} end
local tableconstructor=self:parse_tableconstructor()
if tableconstructor then return {tableconstructor} end
if self:canbe("(","symbol") then local explist=self:parse_explist()
self:mustbe(")","symbol")
return explist or {} end end
function LuaParser:makeFunction(...) return self:node("_function",...) end
function LuaParser:parse_functiondef() local from=self:getloc()
if  not self:canbe("function","keyword") then return  end
return self:makeFunction(nil,table.unpack(assert(self:parse_funcbody()))):setspan{["from"] = from,["to"] = self:getloc()} end
function LuaParser:parse_funcbody() if  not self:canbe("(","symbol") then return  end
local args=self:parse_parlist() or table()
local lastArg=args:last()
local functionType=self.ast._vararg:isa(lastArg) and "function-vararg" or "function"
self:mustbe(")","symbol")
self.functionStack:insert(functionType)
local block=self:parse_block(functionType)
assert.eq(self.functionStack:remove(),functionType)
self:mustbe("end","keyword")
return table{args,table.unpack(block)} end
function LuaParser:parse_parlist() local from=self:getloc()
if self:canbe("...","symbol") then return table{self:node"_vararg":setspan{["from"] = from,["to"] = self:getloc()}} end
local name=self:canbe(nil,"name")
if  not name then return  end
local names=table{self:node("_var",name):setspan{["from"] = from,["to"] = self:getloc()}}
while self:canbe(",","symbol") do from=self:getloc()
if self:canbe("...","symbol") then names:insert(self:node"_vararg":setspan{["from"] = from,["to"] = self:getloc()})
return names end
names:insert(self:node("_var",(self:mustbe(nil,"name"))):setspan{["from"] = from,["to"] = self:getloc()}) end
return names end
function LuaParser:parse_tableconstructor() local from=self:getloc()
if  not self:canbe("{","symbol") then return  end
local fields=self:parse_fieldlist()
self:mustbe("}","symbol")
return self:node("_table",table.unpack(fields or {})):setspan{["from"] = from,["to"] = self:getloc()} end
function LuaParser:parse_fieldlist() local field=self:parse_field()
if  not field then return  end
local fields=table{field}
while self:parse_fieldsep() do local field=self:parse_field()
if  not field then break end
fields:insert(field) end
self:parse_fieldsep()
return fields end
function LuaParser:parse_field() local from=self:getloc()
if self:canbe("[","symbol") then local keyexp=assert(self:parse_exp(),"unexpected symbol")
self:mustbe("]","symbol")
self:mustbe("=","symbol")
local valexp=self:parse_exp()
if  not valexp then error("expected expression but found " .. self.t.token) end
return self:node("_assign",{keyexp},{valexp}):setspan{["from"] = from,["to"] = self:getloc()} end
local exp=self:parse_exp()
if  not exp then return  end
if self.ast._var:isa(exp) and self:canbe("=","symbol") then return self:node("_assign",{self:node("_string",exp.name):setspan(exp.span)},{(assert(self:parse_exp(),"unexpected symbol"))}):setspan{["from"] = from,["to"] = self:getloc()} else return exp end end
function LuaParser:parse_fieldsep() return self:canbe(",","symbol") or self:canbe(";","symbol") end
return LuaParser