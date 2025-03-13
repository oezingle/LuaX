
/**
 * File: bundle_lua.js
 * Description: Use quite a few hacky workarounds to bundle multiple Lua or LuaX files as a single one, with hot reloading (-w flag)
 * Author: Zingle Zingle (https://www.github.com/oezingle)
 */

const path = require("path")
const luabundle = require("luabundle")
const luamin = require('luamin')
const process = require("process")
const fs = require("fs")
const fsp = require("fs/promises")
const { LuaFactory } = require("wasmoon")
const { filesize } = require("filesize")


const isProd = process.env.NODE_ENV == "production"


const LuaXRoot = path.join(__dirname, "../../")
const bundleOutPath = path.resolve(__dirname, "public/bundle.lua")
const entrypoint = path.resolve(__dirname, "src/init.lua")


const preprocessLua = (content) => {
    // hack to replace chunk-level ... with the module's name
    content = content.replace("table_pack\(\.\.\.\)\[1\]", `"${module.name}"`)

    // hardwire _IS_BUNDLED to true
    content = content.replace(/_IS_BUNDLED/g, "true")

    // remove shebang
    const pat_shebang = /^[\n\r]*#![^\n\r]*/gm

    content = content.replace(pat_shebang, "")

    return content
}

let cachedLuaXEngine
const getLuaXEngine = () => {
    if (!cachedLuaXEngine) {
        const factory = new LuaFactory()

        const dirs = {
            src: path.join(LuaXRoot, "src"),
            lib: path.join(LuaXRoot, "lib")
        }

        // Load LuaX project structure into the LuaFactory
        return Promise.all(Object.entries(dirs).map(([prefix, dir_path]) => {
            return fsp.readdir(dir_path, {
                recursive: true,
            })
                .then(files => Promise.all(files.map(file => {
                    const filePath = path.join(dir_path, file)
                    return fsp.stat(filePath)
                        .then(stat => stat.isFile() && file)
                })))
                .then(files => files.filter(f => f))
                .then(files => Promise.all(files.map(file => {
                    const filePath = path.join(dir_path, file)

                    return fsp.readFile(filePath).then(content => {
                        return factory.mountFile(path.join(prefix, file), content)
                    })
                })))
        }))
            .then(() => factory.createEngine())
            .then((engine) => {
                return engine.doString(`
                    -- warn("@on")
                `).then(() => engine)
            })
            .then(engine => {
                cachedLuaXEngine = engine;

                return engine
            })
    } else {
        return Promise.resolve(cachedLuaXEngine)
    }
}

const parseLuaX = (code) => {
    return getLuaXEngine()
        .then(engine => {
            engine.global.set("LuaX_code", code)

            return engine.doString(`
                assert(LuaX_code, "Lua bundle not injected!")

                local LuaX = require("src")
                -- this line is important to constrain imports to only runtime
                LuaX.Parser.set_luax_require_name("LuaX")
                
                local parser = LuaX.Parser.from_file_content(LuaX_code)

                LuaX_code = parser:transpile()
            `)
                .then(() => {
                    const global = engine.global.get("LuaX_code")
                    engine.global.set("LuaX_code", 0)
                    return global
                })
        })
        .catch((e) => {
            console.log("Failed to parse with LuaX")

            console.warn(e)

            // return bundle without LuaX parsing
            return code
        })
}

const getBundle = (modules = {}) => {
    const bundle = luabundle.bundle(entrypoint, {
        paths: [path.join(LuaXRoot, '?.lua'), path.join(LuaXRoot, '?/init.lua'), path.join(__dirname, "src/?.lua"), path.join(__dirname, "src/?/init.lua")],
        ignoredModuleNames: [
            "parser.lua.parser", "ext.op", "ext.table", "ext.class",
            "ext.string", "ext.tolua", "ext.assert", "parser.base.ast",
            "parser.lua.ast", "parser.base.datareader",
            "parser.base.tokenizer", "parser.lua.tokenizer",
            "parser.base.parser", "parser.lua.parser",

            "bit", // LuaJIT builtin
            "string",
            "table",

            "js", // Fengari builtin

            "wibox" // Wibox in AwesomeWM
        ],
        preprocess: (module, options) => {
            const modPath = module.resolvedPath ?? entrypoint

            const preloadMod = modules[modPath]
            if (preloadMod) {
                return preloadMod.content
            }

            const content = preprocessLua(module.content)

            modules[modPath] = {
                content,
                path: modPath,
                name: module.name,
                LuaX_has_parsed: false
            }

            return content
        },
        resolveModule: (name, paths) => {
            // hardcoded paths
            if (name == "LuaX") {
                return path.join(LuaXRoot, "src/entry/runtime-web.lua")
            }

            // TODO lua-ext paths

            // default resolver
            const path_name = name.replace(/\./g, path.sep)
            const list = paths
                .map(path => path.replace("?", path_name))
                .filter(path => fs.existsSync(path))

            return list[0]
        }
    })

    return { bundle, modules }
}

let modules = null

const build_bundle = () => {
    console.log("Building lua bundle")
    return Promise.resolve()
        // Load cachedLuaXEngine
        .then(getLuaXEngine)
        .then(() => {
            // I HATE ASYNCHRONOUS CODE I HATE ASYNCHRONOUS CODE I HATE ASYNCHRONOUS CODE
            // Load module map, because we're not allowed to put promises in bundle.preprocess
            if (!modules) {                
                const res = getBundle()
                modules = res.modules
            }
        })
        .then(async () => {
            for (const key in modules) {
                const module = modules[key]

                if (!module.LuaX_has_parsed) {
                    // console.log(`Parsing LuaX for ${module.name}`)

                    await parseLuaX(module.content)
                        .then(content => {
                            module.content = content;
                            module.LuaX_has_parsed = true;
                        })
                }
            }
        })
        .then(() => {
            const { bundle } = getBundle(modules)

            return bundle
        })
        .then(lua_bundle => {
            if (isProd) {
                console.log(" -> Applying minification to lua bundle")

                lua_bundle = luamin.minify(lua_bundle)
            }

            return lua_bundle
        })
        .then(lua_bundle => {
            return fsp.writeFile(bundleOutPath, lua_bundle)
        })
        .then(() => {
            console.log("Done lua bundle")
        })
        .then(() => {
            if (isProd) {
                fsp.stat(bundleOutPath).then(({ size }) => {
                    console.log(`Lua bundle is ${filesize(size)}`)
                })
            }
        })
}

build_bundle()

if (process.argv[2]?.match(/\s?\-w/g)) {
    const chokidar = require("chokidar")

    const watcher = chokidar.watch([
        path.resolve(__dirname, "src"),
        path.resolve(LuaXRoot)
    ], {
        ignored: (path, stats) => stats?.isFile() && !path.endsWith('.lua') || path.endsWith("bundle.lua"),
        persistent: true
    });

    watcher.on("change", path => {
        if (modules) {
            const module = modules[path]

            if (!module) {
                console.log(`Ignoring ${path} - did not find it to be required`)

                return
            }

            console.log(`Rebuilding ${module.name}`)

            fsp.readFile(path)
                .then(content => content.toString())
                .then(preprocessLua)
                .then(parseLuaX)
                .then(content => {
                    if (module.content != content) {
                        module.content = content

                        build_bundle()
                    }
                })
                .catch((err) => {
                    console.log("An error occurred while hot-bundling")

                    console.error(err)
                })
        } else {
            console.log("Ignoring module change - module list not loaded")
        }
    })
}