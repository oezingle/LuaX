
### TODO
- outside state changes somehow
- ~~XML~~ HTML support
    - lua loader -> convert .x.lua to plain lua
    - XML loader can't know if a component is a function or built-in, so we need a translation table at some point.
- Remove any mention of XML, for XML isn't cool and good enough for React-like syntax (slaxml tried its best but no implicit props)
- contexts
- I could do a neat thing using a setfenv analog to (unsafely) monitor state without expensive waste (i think)
    - definitely can get rid of the LuaX global using setfenv
- text parsing option - remove newlines, use only double-newlines as newlines (similar to markdown)
- test FC that sometimes returns Fragment and sometimes returns single child - how does NativeElement respond?
- wiki

### Links
- [Didact](https://pomb.us/build-your-own-react/)