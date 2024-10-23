local function to_luapath(realpath) local path=realpath:gsub("[/\\]",".")
if path:sub(1,1) == "." then path=path:sub(2) end
if path:sub( - 1, - 1) == "." then path=path:sub(1, - 2) end
return path end
return to_luapath