local function list_map(list,cb) local ret={}
for k,v in pairs(list) do ret[k]=cb(v,k,list) end
return ret end
return list_map