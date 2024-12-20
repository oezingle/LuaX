---@nospec

---@param ... string
---@return boolean
local warn_enabled=false
local function test_control_flag(...) local arg1=({...})[1]
if arg1 == "@on" then 
warn_enabled=true
return false elseif arg1 == "@off" then warn_enabled=false end
return warn_enabled end
local function nocolor_warn(...) if test_control_flag(...) then print("Lua warning:",...) end end

local colors={["YELLOW"] = "\27[33m",["RESET"] = "\27[0m"}
local function color_warn(...) if test_control_flag(...) then io.stdout:write(colors.YELLOW)
io.stdout:write(table.concat(table.pack(...),"\9"))
io.stdout:write(colors.RESET,"\n") end end
local function ensure_warn() 
if warn then return  end
local term=os.getenv"TERM" or ""
if term:match"xterm" then warn=color_warn else warn=nocolor_warn end end
return ensure_warn