
### TODO
- text parsing option - remove newlines, use only double-newlines as newlines (similar to markdown)
- wiki
- Modify requires, providing LuaX global in setfenv?
    - https://stackoverflow.com/questions/45425374/can-i-use-luas-require-to-set-environment-of-the-calling-file
- https://luals.github.io/wiki/plugins/
- LuaXParser loader / inline should provide ... - see TODO
- elements should have unmount handlers
    - remove __gc
- literals could just be strings
    - would save a lot of work with props
- add comment support!

- does NativeElement:delete_children_by_key() handle nested fragments?
    - nested keys.

- GLibIdleWorkLoop

- NativeTextElement seems to call render stuff twice. bizarre.
    - check in on this
    - are props always set twice or something?
        - state updates?

### Links
- [Didact](https://pomb.us/build-your-own-react/)
- [bundle with darklua](https://darklua.com/)
