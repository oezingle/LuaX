local function key_add(key,value) local copy={table.unpack(key)}
table.insert(copy,value)
return copy end
return key_add