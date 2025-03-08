-- luajit doesn't support requiring my/module/init.lua as require("my.module")

do
    local sep = package.path:match("[/\\]")
    local local_init = ("./?/init.lua"):gsub("/", sep)

    if not package.path:match("%.[/\\]?[/\\]init%.lua") then
        package.path = package.path .. ";" .. local_init
    end
end

local env = os.getenv("LUA_ENV") or "development"

if env == "production" then
    -- make sure debug tools don't load
    package.preload["lib.log"] = function()
        error("logging should not be imported in production")
    end

    if debug then
        local vanilla_require = require
        require = function(mod)
            local caller = debug.getinfo(2)

            if mod:match("^spec") and not caller.source:match("^@%.?[/\\]?spec") then
                print(caller.source)

                error("files from spec/ should not be imported in production")
            end

            return vanilla_require(mod)
        end
    end

    -- TODO FIXME tag tests that require debug (ie Inline), retest where
    -- debug=nil with only non-debug. test Inline for post-transpile without
    -- debug.
else
    ---@diagnostic disable-next-line:lowercase-global
    inspect = require("lib.inspect.inspect")
end
