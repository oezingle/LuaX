
const express = require("express")
const morgan = require('morgan')

const app = express()
const port = 3000

app.use(morgan("tiny"))

app.use(express.static('public'))

app.listen(port, () => {
  console.log(`LuaX app on port ${port}`)
})
