local function path_dirname(path) if  not path:match"[/\\]" and path:match"%." then return "" end
path=path:gsub("[/\\][^/\\]+%.%S+$","")
return path end
return path_dirname