local function callstack() print"Callstack dump"
for i = 21,2, - 1 do local info=debug.getinfo(i,"nfS")
if info and info.name ~= nil then print(i - 1,info.name,info.short_src .. ":" .. info.linedefined) end end
print() end
return callstack