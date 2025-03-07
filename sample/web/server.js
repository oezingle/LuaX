
// Ironic that I'm writing JavaScript to attempt to phase out JavaScript

const express = require('express')
const path = require("path")
const luabundle = require("luabundle")
const morgan = require('morgan')
const fs = require('fs/promises')
const luamin = require('luamin');

const app = express()
const port = 3000

const thisDir = path.dirname(__filename)

// TODO we could bundle a much smaller file - src/entry/runtime.lua (if transpiled ahead-of-time)
let LuaX_bundle = null
const getLuaX = () => {
    if (!LuaX_bundle) {
        const LuaXRoot = path.join(thisDir, "../../")

        LuaX_bundle = luabundle.bundle(path.join(LuaXRoot, "src/entry/export.lua"), {
            paths: [path.join(LuaXRoot, '?.lua'), path.join(LuaXRoot, '?/init.lua') ],
            ignoredModuleNames: [
                "parser.lua.parser",
                "ext.op",
                "ext.table",
                "ext.class",
                "ext.string",
                "ext.tolua",
                "ext.assert",
                "parser.base.ast",
                "parser.lua.ast",
                "parser.base.datareader",
                "parser.base.tokenizer",
                "parser.lua.tokenizer",
                "parser.base.parser",
                "parser.lua.parser",

                "bit", // LuaJIT builtin
                "string",
                "table",

                "js", // Fengari builtin

                "wibox" // Wibox in AwesomeWM
            ],
            preprocess: (module, options) => {                
                let content = module.content

                // hack to replace chunk-level ... with the module's name
                content = content.replace("table_pack\(\.\.\.\)\[1\]", `"${module.name}"`)

                // hardwire _IS_BUNDLED to true
                content = content.replace(/_IS_BUNDLED/g, "true")

                // Skip all targets but web
                content = content.replace(/SKIP_TARGET_WiboxElement/g, "true")
                content = content.replace(/SKIP_TARGET_GtkElement/g, "true")

                // remove shebang
                const pat_shebang = /^[\n\r]*#![^\n\r]*/gm
                
                content = content.replace(pat_shebang, "")

                return content
            }
        })
    }

    // LuaX_bundle = luamin.minify(LuaX_bundle)

    return LuaX_bundle
}
fs.writeFile(path.join(thisDir, "LuaX_bundle.lua"), getLuaX())

app.use(morgan("tiny"))

app.get("/fengari-web.js", (req, res) => {
    res.sendFile(path.join(thisDir, "/fengari-web.js"))
})

app.get("/lua/5.3/WebElement.lua", (req, res) => {
    res.sendFile(path.join(thisDir, "/WebElement.lua"))
})

app.get("/lua/5.3/LuaX.lua", (req, res) => {
    res.set({ "Content-Disposition": "attachment; filename=\"req.params.name\"" });
    res.send(getLuaX())
})

app.get('/', (req, res) => {
    res.sendFile(path.join(thisDir, '/index.html'));
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})