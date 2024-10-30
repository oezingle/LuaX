local function tostr(x) if type(x) == "string" then return ("%q"):format(x) end
return tostring(x) end
local function prependmsg(msg,str) return (msg and (tostring(msg) .. ": ") or "") .. str end
local function asserttype(x,t,msg,...) local xt=type(x)
if xt ~= t then error(prependmsg(msg,"expected " .. tostring(t) .. " found " .. tostring(xt))) end
return x,t,msg,... end
local function assertis(obj,cl,msg,...) if  not cl.isa then error(prependmsg(msg,"assertis expected 2nd arg to be a class")) end
if  not cl:isa(obj) then error(prependmsg(msg,"object " .. tostring(obj) .. " is not of class " .. tostring(class))) end
return obj,cl,msg,... end
local function asserttypes(msg,n,...) asserttype(n,"number",prependmsg(msg,"asserttypes number of args"))
for i = 1,n do asserttype(select(n + i,...),select(i,...),prependmsg(msg,"asserttypes arg " .. i)) end
return select(n + 1,...) end
local function asserteq(a,b,msg,...) if  not (a == b) then error(prependmsg(msg,"got " .. tostr(a) .. " == " .. tostr(b))) end
return a,b,msg,... end
local function asserteqeps(a,b,eps,msg,...) eps=eps or 1e-7
if math.abs(a - b) > eps then error((msg and msg .. ": " or "") .. "expected |" .. a .. " - " .. b .. "| < " .. eps) end
return a,b,eps,msg,... end
local function assertne(a,b,msg,...) if  not (a ~= b) then error(prependmsg(msg,"got " .. tostr(a) .. " ~= " .. tostr(b))) end
return a,b,msg,... end
local function assertlt(a,b,msg,...) if  not (a < b) then error(prependmsg(msg,"got " .. tostr(a) .. " < " .. tostr(b))) end
return a,b,msg,... end
local function assertle(a,b,msg,...) if  not (a <= b) then error(prependmsg(msg,"got " .. tostr(a) .. " <= " .. tostr(b))) end
return a,b,msg,... end
local function assertgt(a,b,msg,...) if  not (a > b) then error(prependmsg(msg,"got " .. tostr(a) .. " > " .. tostr(b))) end
return a,b,msg,... end
local function assertge(a,b,msg,...) if  not (a >= b) then error(prependmsg(msg,"got " .. tostr(a) .. " >= " .. tostr(b))) end
return a,b,msg,... end
local function assertindex(t,k,msg,...) if  not t then error(prependmsg(msg,"object is nil")) end
local v=t[k]
assert(v,prependmsg(msg,"expected " .. tostr(t) .. "[" .. tostr(k) .. " ]"))
return v,msg,... end
local function asserttableieq(t1,t2,msg,...) asserteq( # t1, # t2,msg)
for i = 1, # t1 do asserteq(t1[i],t2[i],msg) end
return t1,t2,msg,... end
local function assertlen(t,n,msg,...) asserteq( # t,n,msg)
return t,n,msg,... end
local function asserterror(f,msg,...) asserteq(pcall(f,...),false,msg)
return f,msg,... end
local origassert=_G.assert
return setmetatable({["type"] = asserttype,["types"] = asserttypes,["is"] = assertis,["eq"] = asserteq,["ne"] = assertne,["lt"] = assertlt,["le"] = assertle,["gt"] = assertgt,["ge"] = assertge,["index"] = assertindex,["eqeps"] = asserteqeps,["tableieq"] = asserttableieq,["len"] = assertlen,["error"] = asserterror},{["__call"] = function (t,...) return origassert(...) end})