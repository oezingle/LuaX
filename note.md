
### TODO
- outside state changes somehow
- XML support
    - xml code snippets
    - lua loader -> convert .x.lua to plain lua
- contexts
- I could do a neat thing using a setfenv analog to (unsafely) monitor state without expensive waste (i think)
    - definitely can get rid of the LuaX global using setfenv
- text parsing option - remove newlines, use only double-newlines as newlines (similar to markdown)
- test FC that sometimes returns Fragment and sometimes returns single child - how does NativeElement respond?
- wiki

### Links
- [Didact](https://pomb.us/build-your-own-react/)