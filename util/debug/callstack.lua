local function callstack() print"Callstack dump"
for i = 20,1, - 1 do local info=debug.getinfo(i,"nfS")
if info then print(info.name,info.short_src,info.func) end end end
return callstack