---@meta

---@class C_XML.Node
---@field type "document"|"text"|"comment"|"element"|"pi"
---@field name string
---@field parent XML.Node
---@field kids XML.Node[]?

---@class XML.Node.Document : C_XML.Node
---@field type "document"
---@field root XML.Node
---@field parent nil

---@class XML.Node.Text : C_XML.Node
---@field type "text"
---@field value string

---@class XML.Node.Comment : C_XML.Node
---@field type "comment"
---@field value string

---@class XML.Node.Element : C_XML.Node
---@field type "element"
---@field attr XML.Attribute[]

---@alias XML.Attribute { type: "attribute", name: string, value: string, nsURI: string, nsPrefix: string, parent: XML.Attribute[] }

---@alias XML.Node C_XML.Node | XML.Node.Text | XML.Node.Document | XML.Node.Comment | XML.Node.Element
