
# Typing

All LuaX functionality uses type annotations from [lua-language-server](https://github.com/LuaLS/lua-language-server).

Types are not statically checked in code, but your editor can give helpful
warnings if you set it up. As the Lua language server does not read types from
submodules, types should be copied from `LuaX_types.lua.txt` to a convenient location