local table=require"ext.table"
local function builtinPairs(t) return next,t,nil end
local _0byte=("0"):byte()
local _9byte=("9"):byte()
local function escapeString(s) local o=("%q"):format(s)
o=o:gsub("\\\n","\\n")
return o end
local reserved={["and"] = true,["break"] = true,["do"] = true,["else"] = true,["elseif"] = true,["end"] = true,["false"] = true,["for"] = true,["function"] = true,["goto"] = true,["if"] = true,["in"] = true,["local"] = true,["nil"] = true,["not"] = true,["or"] = true,["repeat"] = true,["return"] = true,["then"] = true,["true"] = true,["until"] = true,["while"] = true}
local function isVarName(k) return type(k) == "string" and k:match"^[_a-zA-Z][_a-zA-Z0-9]*$" and  not reserved[k] end
local toLuaRecurse
local function toLuaKey(state,k,path) if isVarName(k) then return k,true else local result=toLuaRecurse(state,k,nil,path,true)
if result then return "[" .. result .. "]",false else return false,false end end end
local function maxn(t,state) local max=0
local count=0
for k,v in state.pairs(t) do count=count + 1
if type(k) == "number" then max=math.max(max,k) end end
return max,count end
local defaultSerializeForType={["number"] = function (state,x) if x == math.huge then return "math.huge" end
if x ==  - math.huge then return "-math.huge" end
if x ~= x then return "0/0" end
return tostring(x) end,["boolean"] = function (state,x) return tostring(x) end,["nil"] = function (state,x) return tostring(x) end,["string"] = function (state,x) return escapeString(x) end,["function"] = function (state,x) local result,s=pcall(string.dump,x)
if result then s="load(" .. escapeString(s) .. ")" else if s == "unable to dump given function" then local found
for k,v in state.pairs(_G) do if v == x then found=true
s=k
break elseif type(v) == "table" then for k2,v2 in state.pairs(v) do if v2 == x then s=k .. "." .. k2
found=true
break end end
if found then break end end end
if  not found then s="error('" .. s .. "')" end else return "error('got a function I could neither dump nor lookup in the global namespace nor one level deep')" end end
return s end,["table"] = function (state,x,tab,path,keyRef) local result
local newtab=tab .. state.indentChar
if state.touchedTables[x] then if state.skipRecursiveReferences then result="error(\"recursive reference\")" else result=false
state.wrapWithFunction=true
if keyRef then state.recursiveReferences:insert("root" .. path .. "[" .. state.touchedTables[x] .. "] = error(\"can't handle recursive references in keys\")") else state.recursiveReferences:insert("root" .. path .. " = " .. state.touchedTables[x]) end end else state.touchedTables[x]="root" .. path
local numx,count=maxn(x,state)
local intNilKeys,intNonNilKeys
if numx < 2 * count then intNilKeys,intNonNilKeys=0,0
for i = 1,numx do if x[i] == nil then intNilKeys=intNilKeys + 1 else intNonNilKeys=intNonNilKeys + 1 end end end
local hasSubTable
local s=table()
local addedIntKeys={}
if intNonNilKeys and intNilKeys and intNonNilKeys >= intNilKeys * 2 then for k = 1,numx do if type(x[k]) == "table" then hasSubTable=true end
local nextResult=toLuaRecurse(state,x[k],newtab,path and path .. "[" .. k .. "]")
if nextResult then s:insert(nextResult) end
addedIntKeys[k]=true end end
local mixed=table()
for k,v in state.pairs(x) do if  not addedIntKeys[k] then if type(v) == "table" then hasSubTable=true end
local keyStr,usesDot=toLuaKey(state,k,path)
if keyStr then local newpath
if path then newpath=path
if usesDot then newpath=newpath .. "." end
newpath=newpath .. keyStr end
local nextResult=toLuaRecurse(state,v,newtab,newpath)
if nextResult then mixed:insert{keyStr,nextResult} end end end end
mixed:sort(function (a,b) return a[1] < b[1] end)
mixed=mixed:map(function (kv) return table.concat(kv,"=") end)
s:append(mixed)
local thisNewLineChar,thisNewLineSepChar,thisTab,thisNewTab
if  not hasSubTable and  not state.alwaysIndent then thisNewLineChar=""
thisNewLineSepChar=" "
thisTab=""
thisNewTab="" else thisNewLineChar=state.newlineChar
thisNewLineSepChar=state.newlineChar
thisTab=tab
thisNewTab=newtab end
local rs="{" .. thisNewLineChar
if  # s > 0 then rs=rs .. thisNewTab .. s:concat("," .. thisNewLineSepChar .. thisNewTab) .. thisNewLineChar end
rs=rs .. thisTab .. "}"
result=rs end
return result end}
local function defaultSerializeMetatableFunc(state,m,x,tab,path,keyRef) if type(x) ~= "table" then return "nil" end
return toLuaRecurse(state,m,tab .. state.indentChar,path,keyRef) end
toLuaRecurse=function (state,x,tab,path,keyRef) if  not tab then tab="" end
local xtype=type(x)
local serializeFunction
if state.serializeForType then serializeFunction=state.serializeForType[xtype] end
if  not serializeFunction then serializeFunction=defaultSerializeForType[xtype] end
local result
if serializeFunction then result=serializeFunction(state,x,tab,path,keyRef) else result="[" .. type(x) .. ":" .. tostring(x) .. "]" end
assert(result ~= nil)
if state.serializeMetatables then local m=getmetatable(x)
if m ~= nil then local serializeMetatableFunc=state.serializeMetatableFunc or defaultSerializeMetatableFunc
local mstr=serializeMetatableFunc(state,m,x,tab,path,keyRef)
assert(mstr ~= nil)
if mstr ~= "nil" and mstr ~= false then assert(result ~= false)
result="setmetatable(" .. result .. ", " .. mstr .. ")" end end end
return result end
local function tolua(x,args) local state={["indentChar"] = "",["newlineChar"] = "",["wrapWithFunction"] = false,["recursiveReferences"] = table(),["touchedTables"] = {}}
local indent=true
if args then if args.indent == false then indent=false end
if args.indent == "always" then state.alwaysIndent=true end
state.serializeForType=args.serializeForType
state.serializeMetatables=args.serializeMetatables
state.serializeMetatableFunc=args.serializeMetatableFunc
state.skipRecursiveReferences=args.skipRecursiveReferences end
if indent then state.indentChar="\9"
state.newlineChar="\n" end
state.pairs=builtinPairs
local str=toLuaRecurse(state,x,nil,"")
if state.wrapWithFunction then str="(function()" .. state.newlineChar .. state.indentChar .. "local root = " .. str .. " " .. state.newlineChar .. state.recursiveReferences:concat(" " .. state.newlineChar .. state.indentChar) .. " " .. state.newlineChar .. state.indentChar .. "return root " .. state.newlineChar .. "end)()" end
return str end
return setmetatable({},{["__call"] = function (self,x,args) return tolua(x,args) end,["__index"] = {["escapeString"] = escapeString,["isVarName"] = isVarName,["defaultSerializeForType"] = defaultSerializeForType,["defaultSerializeMetatableFunc"] = defaultSerializeMetatableFunc}})