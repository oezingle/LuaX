local function get_default_indent(text,pos) local subtext=text:sub(1,pos or  # text):match"\n([^\n]-)$" or ""
local default_indent=subtext:match"^%s*"
return default_indent or "" end
return get_default_indent