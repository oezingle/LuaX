
# XML formatting matters in LuaX - why?

In both vanilla HTML and React, formatting text nodes using characters such as newlines and indentations has no effect on the final output. LuaX does not follow this standard, but for good reason. 

HTML has special characters and tags such as `&nbsp;` and `<br />`. These can be rendered within LuaX without trouble, but many interface libraries don't have a drop-in replacement. In order to ensure that LuaX's core library is agnostic to whatever interface library Components are defined in, the XML parser implementation we use takes context clues from the XML code inputted into it and uses those clues to maintain the formatting of the text inside.
