
const ALLOW_WASM = true

// TODO polyfill promises for OLD browsers

fetch("/bundle.lua")
    .then(res => res.text())
    .then((code) => {
        if (WebAssembly && ALLOW_WASM) {
            console.log("Loading Lua via Wasmoon")

            return import("wasmoon")
                .then(({ LuaFactory }) => {
                    const factory = new LuaFactory()

                    return factory.mountFile("bundle.lua", code)
                        .then(() => factory.createEngine({
                            injectObjects: true
                        }))
                        .then(engine => {
                            engine.global.set("jstmp", globalThis)
                            engine.doString(`package.loaded["js"] = { global = jstmp, null=null, wasm = true }; jstmp = nil`)

                            engine.doString(`require("bundle")`)
                        })
                })
        } else {
            console.warn("WASM Support not found - loading Lua via Fengari")

            return import('fengari-web')
                .then(fengari_web => {
                    fengari_web.load(code)()

                })
        }
    })
    .catch(console.error)
