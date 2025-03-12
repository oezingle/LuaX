
# The LuaX Web sample

This sample gives you a jumping-off point for developing web apps with LuaX. It
uses webpack to load either [wasmoon](https://github.com/ceifa/wasmoon) or
[Fengari](https://github.com/fengari-lua/fengari) along with a custom nodejs
script that hot-bundles lua as an entrypoint for either loader.

## Wasmoon and Fengari

The LuaX web sample dynamically selects between two web-ready implementations of
the Lua VM. Wasmoon uses the official Lua VM, compiled to WebAssembly which is
baseline available in browsers [since 2017](https://caniuse.com/wasm). Fengari
is a re-implementation of Lua in pure JavaScript, meaning it has support for
extremely out-of-date browsers. 

Wasmoon is faster than Fengari by an order of magnitude so the website's
JavaScript core loads it if `WebAssembly` exists. However, if you wish to force
Fengari to be loaded, change `ALLOW_WASM` to `false` in `src/index.js`

## Installation

```bash
# install dependencies
npm install

# build the js & lua bundle
npm run build
# serve the bundles from a tiny express server
npm run serve
```

## Development

If you want to modify the app on-the-fly, you can start a hot-reloading
development server:

```bash
npm run dev
```

Webpack will automatically reload the website when the lua bundle changes.