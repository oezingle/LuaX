
# The big plan

- write react-like features
    - function components
    - use_state, use_effect
        - maybe contexts?
    - figure out state management
    - maybe helper function generates class instance
        - props as statically checked

- outside state changes somehow

- write library that wraps awful components to this library

- XML support
    - xml code snippets
    - lua loader -> convert .x.lua to plain lua
    

- Function or Component -> Element
- Element { props, type }

- render_nth_child should take keys as an array, as does <get/set>_child[ren]_by_key()
    - FC's pass { ...keys, child_index }

- no more key in ElementNode? seems unnecessary as of now.

### divider
- FRAGMENTS
- returning array of children works in React so I have to make it work.
- contexts
- I could do a neat thing using a setfenv analog to (unsafely) monitor state without expensive waste (i think)

- TODO test FC that sometimes returns Fragment and sometimes returns single child - how does NativeElement respond?

### Links
- [Didact](https://pomb.us/build-your-own-react/)