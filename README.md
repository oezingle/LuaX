
# LuaX

LuaX is a Pure-Lua user interface component system and language designed to
support any and all user interface libraries. It features a React-like hooks
system and a JSX-like markup-programming combination language that can be
evaluated at runtime.

LuaX aims to be API-compatible with Lua 5.4 and LuaJIT. However, LuaX assumes a
searcher for `./?/init.lua` exists. If it does not, you must provide it. See the
[`sample/`](./sample/) directory for examples on how to accomplish this.

# Installing 

LuaX currently isn't available on luarocks, though it may in the future. In
order to use LuaX, simply `git clone` the `build` or `build-dev` branch into
your project directory. Projects with existing git repositories should use `git
submodule add`. 

Here's an installation example:
```bash
# Create a repository for this project
git init .
# Add LuaX as a submodule in ./lib/LuaX/
git submodule add -b build https://github.com/oezingle/LuaX lib/LuaX

# Check it all works
lua lib/LuaX/init.lua
```

You should see this message if LuaX is installed properly
```
Usage: LuaX [--remap <remap> <remap>] [-a] [-h] <input> <output>
       [-r [<recursive>]]

Error: missing argument 'input'
Process Exited [1]
```

# Examples 

See the [`sample/`](./sample/) directory

# Documentation

Developers familiar with React will find LuaX very familiar, but some semantics
have changed - most notably Portals. The [`doc/`](./doc/) directory contains
help articles for new LuaX developers. We recommend first-time LuaX users read
[Rendering](./doc/rendering.md) first.
