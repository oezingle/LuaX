local table_pack=table.pack or function (...) local t={...}
local len=select("#",...)
t.n=len
return t end
return table_pack