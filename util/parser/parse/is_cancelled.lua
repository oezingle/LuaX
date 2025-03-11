local function is_cancelled(text,pos) local pos=pos - 1
local char=text:sub(pos,pos)
local cancelled=false
while char == "\\" do cancelled= not cancelled
pos=pos - 1
char=text:sub(pos,pos) end
return cancelled end
return is_cancelled