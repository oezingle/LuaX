local pairs=pairs
local next=next
local type=type
---@type fun(a: table, b: table, traversed: table): boolean, table
local getmetatable=getmetatable

---@param value any
---@return boolean
local fchk_table_keys
local function is_primitive(value) local t=type(value)
return t == "nil" or t == "string" or t == "number" or t == "boolean" end
---@param a any first object to check
---@param b any second object to check
---@param level number? to what degree objects should be checked for equality:




---@param traversed table<any, any[]>? Internally used to track objects that are accounted for
local function deep_equals(a,b,level,traversed) level=level or 3

traversed=traversed or {}
do local traversed_a=traversed[a]
local traversed_b=traversed[b]
if traversed_a and traversed_b and traversed_a[b] and traversed_b[a] then return true end end
if a == b then return true end

local t=type(a)
if t ~= type(b) then return false end
if t == "function" then 
return level < 2 or (level == 3 and error"Cannot determine equality of function data") end
if t == "userdata" then if level < 1 then return true end
if  not deep_equals(getmetatable(a),getmetatable(b),nil,traversed) then return false end

if getmetatable(a).__pairs then if  not fchk_table_keys(a,b,traversed) then return false end
for k,value_a in pairs(a) do local value_b=b[k]
if  not deep_equals(value_a,value_b,nil,traversed) then return false end end elseif getmetatable(a).__ipairs and getmetatable(a).__len then if  # a ~=  # b then return false end
for i,value_a in ipairs(a) do local value_b=b[i]
if  not deep_equals(value_a,value_b,nil,traversed) then return false end end end
return true end
if t == "thread" then return level < 2 or (level == 3 and error"Cannot determine equality of thread data") end
if t == "table" then if level < 1 then return true end
traversed[a]=traversed[a] or {}
traversed[a][b]=true
traversed[b]=traversed[b] or {}
traversed[b][a]=true
if  # a ~=  # b then return false end


if  not deep_equals(getmetatable(a),getmetatable(b),level,traversed) then return false end

local keys_ok,exotic_b=fchk_table_keys(a,b,traversed)
if  not keys_ok then return false end

for k,value_a in pairs(a) do if  not is_primitive(k) then local has_key_match=false
for _,k_b in pairs(exotic_b) do if deep_equals(k,k_b,level,traversed) then if  not deep_equals(value_a,b[k_b],level,traversed) then return false end
has_key_match=true
break end end
if  not has_key_match then return false end elseif  not deep_equals(value_a,b[k],level,traversed) then return false end end
return true end
return false end


---@param a table
---@param b table
---@param traversed table
---@return boolean key_match
---@return table exotic_keys
fchk_table_keys=function (a,b,traversed) local primitive_keys_a={}
local exotic_keys_a={}
for k in pairs(a) do if is_primitive(k) then primitive_keys_a[k]=true else table.insert(exotic_keys_a,k) end end
local exotic_keys_b={}
for k_b in pairs(b) do if is_primitive(k_b) then if  not primitive_keys_a[k_b] then return false,exotic_keys_b end
primitive_keys_a[k_b]=nil else table.insert(exotic_keys_b,k_b)
local has_match=false
for i,k_a in ipairs(exotic_keys_a) do if deep_equals(k_a,k_b,nil,traversed) then has_match=true
table.remove(exotic_keys_a,i)
break end end
if  not has_match then return false,exotic_keys_b end end end
return next(primitive_keys_a) == nil and  # exotic_keys_a == 0,exotic_keys_b end
return deep_equals