---@param inpath string
---@param outpath string
local function cp(inpath,outpath) local f_in=io.open(inpath,"r")
if  not f_in then error(string.format("Unable to open file %q for reading",inpath)) end
local f_out=io.open(outpath,"w")
if  not f_out then error(string.format("Unable to open file %q for writing",outpath)) end
for line in f_in:lines"L" do f_out:write(line) end
f_in:close()
f_out:flush()
f_out:close() end
return cp