
# Why isn't there any code in some init.lua files?

init is often a rather large module, and some implementations of 
Lua cache require("<dir>") and require("<dir>.init") as separate objects.

In order to get around this issue, init.lua for a large module returns 
a require for an absolute path. this saves us the memory of requiring that module twice!