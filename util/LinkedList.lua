do local folder_of_this_file
local module_arg={...}
if module_arg[1] ~= (arg or {})[1] then folder_of_this_file=module_arg[1] .. "."
local is_implicit_init=module_arg[2]:match(module_arg[1] .. "[/\\]init%.lua")
if  not is_implicit_init then folder_of_this_file=folder_of_this_file:match"(.+%.)[^.]+" or "" end else folder_of_this_file=arg[0]:gsub("[^%./\\]+%..+$","")
do local sep=package.path:sub(1,1)
local pwd=sep == "/" and os.getenv"PWD" or io.popen("cd","r"):read"a"
for _ in folder_of_this_file:gmatch"%.%." do pwd=pwd:gsub("[/\\][^/\\]+[/\\]?$","") end
pwd=pwd .. sep
package.path=package.path .. string.format(";%s?.lua;%s?%sinit.lua",pwd,pwd,sep) end
folder_of_this_file=folder_of_this_file:gsub("[/\\]","."):gsub("^%.+","") end
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"
local LinkedListNode=class"LinkedListNode"
function LinkedListNode:init(value) self.value=value end
function LinkedListNode:set_next(node) self.next=node
return self end
function LinkedListNode:set_prev(node) self.prev=node
return self end
local LinkedList=class"LinkedList"
function LinkedList:init() self.head=nil
self.tail=nil end
function LinkedList:prepend(value) local node=LinkedListNode(value):set_next(self.head)
if self.head then self.head:set_prev(node) end
self.head=node
if  not self.tail then self.tail=self.head end
return self end
function LinkedList:append(value) local node=LinkedListNode(value):set_prev(self.tail)
if self.tail then self.tail:set_next(node) end
self.tail=node
if  not self.head then self.head=self.tail end
return self end
function LinkedList:push(value) return self:prepend(value) end
function LinkedList:pop() local first=self.head
if  not first then return nil end
self.head=first.next
if self.head then self.head:set_prev(nil) end
return first.value end
function LinkedList:filter_remove(filter) local node=self.head
if  not node then return self end
while  not self._filter_node(node,filter) do node=node.next
if  not node then return self end end
local prev=node.prev
if self.tail == node then self.tail=prev end
local next=node.next
if self.head == node then self.head=next end
if prev then prev:set_next(next) end
if next then next:set_prev(prev) end
return self end
function LinkedList:enqueue(value) return self:append(value) end
function LinkedList:dequeue() return self:pop() end
function LinkedList:is_empty() return self.head == nil end
function LinkedList._filter_node(node,filter) if node == nil or filter == nil then return true end
local value=node.value
if type(filter) == "function" then return filter(value) elseif type(filter) == "table" then if type(value) ~= "table" then return false end
for k,v in pairs(filter) do if value[k] ~= v then return false end end
return true else return value == filter end end
function LinkedList:first(filter) local node=self.head
if  not node then return nil end
while  not self._filter_node(node,filter) do node=node.next
if  not node then return nil end end
return node.value end
function LinkedList:filter(filter) local list={}
local node=self.head
while node do if self._filter_node(node,filter) then table.insert(list,node.value) end
node=node.next end
return list end
function LinkedList:__pairs() return self:iterator() end
function LinkedList:iterator() local i=0
local node=self.head
return function () if  not node then return nil,nil end
local value=node.value
node=node.next
i=i + 1
return i,value end end
function LinkedList:to_table() return self:filter() end
return LinkedList