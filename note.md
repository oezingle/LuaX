
### TODO
- outside state changes somehow
- Remove any mention of XML, for XML isn't hot and sexy enough for React-like syntax (slaxml tried its best but no implicit props)
- text parsing option - remove newlines, use only double-newlines as newlines (similar to markdown)
- wiki
- small bit of library code for shims
    - https://stackoverflow.com/questions/45425374/can-i-use-luas-require-to-set-environment-of-the-calling-file
- https://luals.github.io/wiki/plugins/
- how the fuck do context consumers work
- LuaXParser should take option where Capitalized components are assumed local, and lowercase are assumed globals
- https://github.com/Kampfkarren/full-moon
- LuaXParser has far too many 'unable to find end tag' type errors
- LuaXParser loader / inline should provide ... - does it?
- LuaXParser only matches return keyword but really should match all keywords.
    - this is also extremely easy, i'm just lazy.
- elements should have unmount handlers
- create_element should have a metatable or something to check against.
- profile and see what i need to improve
    - https://github.com/tarantool/gperftools
        - needs customized tarantool lua runtime
    - https://jan.kneschke.de/projects/misc/profiling-lua-with-kcachegrind/
        - looks like a really good option but requires modification and kcachegrind

- probably only 1 literal can be rendered at once
    - WiboxText & NativeElement:116 are to blame for this

- redo literals?
    - literals could just be strings
        - would save a lot of work with props
        - would mean a lot of refactoring

- does NativeElement:delete_children_by_key() handle nested fragments?
    - nested keys.

- NativeTextElement seems to call render stuff twice. bizarre.
    - are props always set twice or something?
        - state updates?

### Links
- [Didact](https://pomb.us/build-your-own-react/)
- [bundle with darklua](https://darklua.com/)




`lua src/init.lua awesome/Button.luax`