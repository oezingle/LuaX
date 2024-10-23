local function key_first(key) local copy={table.unpack(key)}
table.remove(copy,1)
return key[1],copy end
return key_first