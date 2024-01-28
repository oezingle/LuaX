---@meta

---@class C_SLAXML.Node
---@field type "document"|"text"|"comment"|"element"|"pi"
---@field name string
---@field parent SLAXML.Node
---@field kids SLAXML.Node[]?

---@class SLAXML.Node.Document : C_SLAXML.Node
---@field type "document"
---@field root SLAXML.Node
---@field parent nil

---@class SLAXML.Node.Text : C_SLAXML.Node
---@field type "text"
---@field value string

---@class SLAXML.Node.Comment : C_SLAXML.Node
---@field type "comment"
---@field value string

---@class SLAXML.Node.Element : C_SLAXML.Node
---@field type "element"
---@field attr SLAXML.Attribute[]

---@alias SLAXML.Attribute { type: "attribute", name: string, value: string, nsURI: string, nsPrefix: string, parent: SLAXML.Attribute[] }

---@alias SLAXML.Node C_SLAXML.Node | SLAXML.Node.Text | SLAXML.Node.Document | SLAXML.Node.Comment | SLAXML.Node.Element
