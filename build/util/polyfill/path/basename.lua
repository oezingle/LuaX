local function path_basename(path) path=path:gsub("[\\/][^\\/]+%.%S+$","")
return path end
return path_basename