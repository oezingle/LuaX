local concat=table.concat
local function key_to_string(key) if  # key == 0 then return "<empty key>" end
return concat(key,".") end
return key_to_string