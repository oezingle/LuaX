
# The LuaX Parser

If you've read other LuaX documentation articles, you may have noticed that it
supports an HTML-like syntax. This allows you to write component declarations in
a quick and straightforward manner, similar to many web frameworks. 

LuaX's parser is written specifically for LuaX, and isn't intended
to support other frameworks, as opposed to languages like JSX that target a wide
gamut of rendering frameworks.

This document is fairly exhaustive, and as such most users will only need to
refer to sections of it or skim its contents.



## LuaX syntax

First, let's take a look at LuaX's syntax. It is similar to JSX, which users of
React & Vue will be familiar with. This article will not provide code
examples -- for those, see [components](./components.md)

Like HTML, LuaX syntax consists of components and attributes, though we'll refer
to attributes as 'properties' in keeping with the terminology used in LuaX's
internal code. However, the power of LuaX is that valid lua code can be inserted
into these statements, whereas HTML is more or less static. This is achieved by
converting the LuaX syntax to vanilla Lua, using special characters to determine
which values are just strings, and which are 'literals', or lua code blocks.

A LuaX statement has the form:
```
 An element or functional component name
 |
 |                         Property name
 |                         |
<some-ui-library.container label="Container" onclick={function () end}>
                                 |                   |
                                 |                   A 'literal' (lua code block)
                                 |
                                 Property value
    (child elements)
</some-ui-library.container>
```
Transpiled, it will look something like:
```
LuaX.create_element("some-ui-library.container", {
    label = "Container",
    onclick = function () end
    children = {
        (child elements)
    }
})
```



### Specifying components

The standard enforced by JSX is relatively simple: if an element name contains
an uppercase letter, it is a component as opposed to some native element. This
works flawlessly in the world of HTML, as all elements are lowercase. LuaX
cannot make this same assumption, as some user interface frameworks provide
components whose names contain capital letters, such as
[Gtk](https://www.gtk.org/). In order to determine what is a 'native' element
and what is a LuaX component, the LuaX Parser will either use local variable
lookup or a 'global' component lookup.

#### Global component lookup

If all loaded `NativeElement` implementations provide a list of components which
they provide, then the Parser will refer against the list to determine which
element names are defined by UI libraries, and which refer to function
components.

#### Local variable lookup

If a list of all provided components is not made available to the parser (use
lua's `warn("@on")` to see any LuaX warnings), the parser will default to local mode.
The parser will refer against a list of locally defined variables to determine
which element names are defined by UI libraries, and which refer to function
components. While parsing inline LuaX, these variables are collected via
`debug.getlocal`. If the code is being handled statically, then the
[lua-parser](https://github.com/thenumbernine/lua-parser.git) library is used to
search for variable names.

#### Forcing the parser to ignore a local variable

In some cases, you may find that the LuaX parser is running in local mode, and a
variable exists whose name conflicts with the name of an element that your UI
library of choice provides. In order to circumvent this issue, prepend "LuaX."
onto the name of the element. For instance, `<Gtk.Box ...` becomes `<LuaX.Gtk.Box ...`

#### Dynamically selecting components

In some cases, you may wish to switch between two different container components
while maintaining their child content. In order to achieve this, simply define a
local variable that holds which component you wish to render. 
```lua
-- You can switch freely between native elements and LuaX components
local MyComponent = some_condition and "my-ui-library.container" or MyContainerComponent
return <MyComponent ...
```



### Properties

Element properties are expected to be whitespace-separated, after the component
name. There are 3 valid property definitions: `key="value"` where "value" will
be passed as a string, `key` where `key=true` is inferred, and `key={value}` or
`key="{value}"` where value is handled as a literal. Literals will be expanded
upon, but for now we can think of the curly braces {} as a cue to the LuaX parser
to treat whatever is contained within them as lua code, as opposed to a plain
string. Lua-style comments are also supported here.



### Child content

As with HTML, elements may contain other elements or text, but LuaX also allows
literal values. Additionally, HTML-style comments and Lua-style comments are
both supported here.

#### Child elements

Specifying a child element is easy. Simply nest a LuaX statement within another:
```
<Container>
    <Child>
    </Child>
</Container>
```

#### Child text and Child literals

Displaying text in LuaX is simple as well. Like we saw in the section in
properties, we may use the curly braces {} to signify that a portion of child
text content is a literal, which is a block of lua code. Unlike literal property
values, non-falsey, non-element values will be cast using `tostring()`, so they
will always display without an error. `nil` and `false` values will not be
rendered. LuaX elements passed as literals will be displayed as if they were
defined as children directly.
```
<Text>
    Hello {name}!
</Text>
```

#### Childless elements

If you wish to display a component without specifying children, LuaX provides
syntactic sugar to avoid rewriting the component's name in its end tag.
`<MyComponent />` is equivalent to `<MyComponent></MyComponent>`



### Literals

Curly braces {} within an element's property values or child content signify to
the LuaX parser that the enclosed value should be handled as a block of Lua
code. The [Properties](#properties) and [Child text and Child
literals](#child-text-and-child-literals) sections of this document provide more
context as to how literal values in each case are handled. This section intends
to provide understanding as to how literals are parsed. 

The literal parser does not check its contained lua content for validity,
instead only checking for a matching end brace. Of course, braces may be
contained within the literal value. The parser tracks uses of brackets, braces,
and strings, in order to properly determine the ending position of the literal.



### Comments

The LuaX parser supports comments in most locations. Before we provide a list of
valid comment locations, we will define some terminology.

**Lua-style comments** refer to comments of the form `-- I am a comment!` and
`--[[ I am a comment! ]]`

**HTML-style comments** refer to comments of the form `<!--I am a comment!-->`

The parser allows different comment formats under different conditions:
- While parsing properties, the parser supports Lua-style comments
- While parsing literals, the parser supports Lua-style comments
- While parsing child content, the parser supports Lua-style and HTML-style comments



### Fragments

In some cases, you may wish to create a component which returns multiple
elements. By default, this is not allowed, as the LuaX parser expects LuaX
expressions to be wrapped with a single parent element. Fragments can aid you in
these situations. Fragments can be rendered using either the `LuaX.Fragment`
component, or a bit of syntactic sugar: `<>...</>` generates Fragments for you,
where `...` is the child content. The `LuaX.Fragment` dependency of this syntax
will be handled automatically for you when transpiling LuaX code.


<!--
## Inline Transpilation

## The Transpilation API

## CLI Transpilation
-->