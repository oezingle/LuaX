
-- https://stackoverflow.com/questions/37949298/how-do-i-get-directory-path-given-a-file-name-in-lua-which-is-platform-indepen
local sep = package.config:sub(1, 1)

return sep
