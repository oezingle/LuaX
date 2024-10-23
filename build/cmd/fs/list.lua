local has_lfs,lfs=pcall(require,"lfs")
local is_windows=package.config:sub(1,1) == "\\"
local function ls_lfs(path) local children={}
for child in lfs.dir(path) do if child ~= "." and child ~= ".." then table.insert(children,child) end end
return children end
local function ls_unix(path) local children={}
local command=string.format("ls -A %q",path)
local handle,err=io.popen(command,"r")
if  not handle then error(string.format("Unable to run %q: %q",command,err)) end
for child in handle:lines"l" do table.insert(children,child) end
return children end
local function ls_windows(path) local children={}
local command=string.format("dir /b %q",path)
local handle,err=io.popen(command,"r")
if  not handle then error(string.format("Unable to run %q: %q",command,err)) end
for child in handle:lines"l" do table.insert(children,child) end
return children end
local ls=nil
if has_lfs then ls=ls_lfs elseif is_windows then ls=ls_windows else ls=ls_unix end
return {["has_lfs"] = has_lfs,["is_windows"] = is_windows,["ls_lfs"] = ls_lfs,["ls_unix"] = ls_unix,["ls_windows"] = ls_windows,["ls"] = ls}